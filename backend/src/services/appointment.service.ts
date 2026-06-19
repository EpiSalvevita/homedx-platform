import {
  BadRequestException,
  ForbiddenException,
  Injectable,
  NotFoundException,
} from '@nestjs/common';
import { PrismaService } from './prisma.service';
import { VideoService } from './video.service';
import { NotificationService } from './notification.service';

const JOIN_WINDOW_BEFORE_MS = 10 * 60 * 1000;
const JOIN_WINDOW_AFTER_MS = 30 * 60 * 1000;

export interface AppointmentListItem {
  id: string;
  doctorId: string;
  doctorName: string;
  patientId: string;
  patientName: string;
  appointmentTime: string;
  type: string;
  status: string;
  notes: string | null;
  durationMin: number;
  canJoin: boolean;
  videoRoomUrl: string | null;
}

@Injectable()
export class AppointmentService {
  constructor(
    private prisma: PrismaService,
    private videoService: VideoService,
    private notificationService: NotificationService,
  ) {}

  async bookAppointment(params: {
    patientId: string;
    doctorId: string;
    appointmentTime: Date;
    type: string;
    notes?: string;
    testTypeId?: string;
  }) {
    const doctor = await this.prisma.doctorProfile.findUnique({
      where: { id: params.doctorId },
      include: { user: true },
    });
    if (!doctor || !doctor.isActive) {
      throw new NotFoundException('Doctor not found');
    }

    const conflict = await this.prisma.appointment.findFirst({
      where: {
        doctorId: params.doctorId,
        scheduledAt: params.appointmentTime,
        status: { in: ['PENDING', 'CONFIRMED'] },
      },
    });
    if (conflict) {
      throw new BadRequestException('Selected slot is no longer available');
    }

    const appointmentType = params.type?.toLowerCase() === 'in-person' ? 'IN_PERSON' : 'ONLINE';
    let videoRoomName: string | null = null;
    let videoRoomUrl: string | null = null;

    if (appointmentType === 'ONLINE') {
      videoRoomName = `homedx-${Date.now()}-${params.patientId.slice(-6)}`;
      const room = await this.videoService.createRoom(videoRoomName);
      videoRoomName = room.roomName;
      videoRoomUrl = room.roomUrl;
    }

    const appointment = await this.prisma.appointment.create({
      data: {
        patientId: params.patientId,
        doctorId: params.doctorId,
        scheduledAt: params.appointmentTime,
        type: appointmentType,
        status: 'CONFIRMED',
        notes: params.notes,
        rapidTestId: params.testTypeId,
        videoRoomName,
        videoRoomUrl,
      },
      include: {
        doctor: { include: { user: true } },
        patient: true,
      },
    });

    await this.notificationService.create({
      userId: params.patientId,
      type: 'APPOINTMENT_CONFIRMED',
      title: 'Termin bestätigt',
      message: `Ihr Online-Termin mit Dr. ${doctor.user.firstName} ${doctor.user.lastName} wurde bestätigt.`,
      data: JSON.stringify({ appointmentId: appointment.id }),
    });

    await this.notificationService.create({
      userId: doctor.userId,
      type: 'APPOINTMENT_CONFIRMED',
      title: 'Neuer Termin',
      message: `Neuer Online-Termin am ${params.appointmentTime.toLocaleString('de-DE')}.`,
      data: JSON.stringify({ appointmentId: appointment.id }),
    });

    return appointment;
  }

  async listAppointments(userId: string, role: string): Promise<AppointmentListItem[]> {
    let where: any = {};

    if (role === 'DOCTOR') {
      const doctorProfile = await this.prisma.doctorProfile.findUnique({
        where: { userId },
      });
      if (!doctorProfile) {
        return [];
      }
      where = { doctorId: doctorProfile.id };
    } else {
      where = { patientId: userId };
    }

    const appointments = await this.prisma.appointment.findMany({
      where,
      include: {
        doctor: { include: { user: true } },
        patient: true,
      },
      orderBy: { scheduledAt: 'asc' },
    });

    return appointments.map((a) => this.toListItem(a));
  }

  async getAppointment(appointmentId: string, userId: string, role: string) {
    const appointment = await this.prisma.appointment.findUnique({
      where: { id: appointmentId },
      include: {
        doctor: { include: { user: true } },
        patient: true,
      },
    });
    if (!appointment) {
      throw new NotFoundException('Appointment not found');
    }

    this.assertCanAccess(appointment, userId, role);
    return this.toListItem(appointment);
  }

  async cancelAppointment(appointmentId: string, userId: string, role: string) {
    const appointment = await this.prisma.appointment.findUnique({
      where: { id: appointmentId },
      include: {
        doctor: { include: { user: true } },
        patient: true,
      },
    });
    if (!appointment) {
      throw new NotFoundException('Appointment not found');
    }

    this.assertCanAccess(appointment, userId, role);

    if (appointment.status === 'CANCELLED' || appointment.status === 'COMPLETED') {
      throw new BadRequestException('Appointment cannot be cancelled');
    }

    const updated = await this.prisma.appointment.update({
      where: { id: appointmentId },
      data: { status: 'CANCELLED' },
      include: {
        doctor: { include: { user: true } },
        patient: true,
      },
    });

    const notifyIds = [appointment.patientId, appointment.doctor.userId];
    for (const notifyUserId of notifyIds) {
      await this.notificationService.create({
        userId: notifyUserId,
        type: 'APPOINTMENT_CANCELLED',
        title: 'Termin storniert',
        message: 'Ein Termin wurde storniert.',
        data: JSON.stringify({ appointmentId }),
      });
    }

    return this.toListItem(updated);
  }

  async getVideoCallToken(appointmentId: string, userId: string, role: string) {
    const appointment = await this.prisma.appointment.findUnique({
      where: { id: appointmentId },
      include: {
        doctor: { include: { user: true } },
        patient: true,
      },
    });
    if (!appointment) {
      throw new NotFoundException('Appointment not found');
    }

    this.assertCanAccess(appointment, userId, role);

    if (appointment.type !== 'ONLINE') {
      throw new BadRequestException('This appointment is not an online consultation');
    }

    if (appointment.status === 'CANCELLED') {
      throw new BadRequestException('Appointment was cancelled');
    }

    if (!this.canJoinNow(appointment.scheduledAt)) {
      throw new BadRequestException('Video call is not available yet');
    }

    if (!appointment.videoRoomName || !appointment.videoRoomUrl) {
      throw new BadRequestException('Video room not configured for this appointment');
    }

    const isDoctor = role === 'DOCTOR';
    const displayName = isDoctor
      ? `Dr. ${appointment.doctor.user.firstName} ${appointment.doctor.user.lastName}`
      : `${appointment.patient.firstName} ${appointment.patient.lastName}`;

    const { token, expiresAt } = await this.videoService.createMeetingToken(
      appointment.videoRoomName,
      displayName,
      isDoctor,
    );

    return {
      roomUrl: appointment.videoRoomUrl,
      joinUrl: this.videoService.buildJoinUrl(appointment.videoRoomUrl, token),
      token,
      expiresAt: expiresAt.toISOString(),
    };
  }

  canJoinNow(scheduledAt: Date): boolean {
    const now = Date.now();
    const start = scheduledAt.getTime() - JOIN_WINDOW_BEFORE_MS;
    const end = scheduledAt.getTime() + JOIN_WINDOW_AFTER_MS;
    return now >= start && now <= end;
  }

  private assertCanAccess(
    appointment: {
      patientId: string;
      doctor: { userId: string };
    },
    userId: string,
    role: string,
  ) {
    const isPatient = appointment.patientId === userId;
    const isDoctor = role === 'DOCTOR' && appointment.doctor.userId === userId;
    const isAdmin = role === 'ADMIN';

    if (!isPatient && !isDoctor && !isAdmin) {
      throw new ForbiddenException('Not authorized for this appointment');
    }
  }

  private toListItem(appointment: {
    id: string;
    doctorId: string;
    patientId: string;
    scheduledAt: Date;
    type: string;
    status: string;
    notes: string | null;
    durationMin: number;
    videoRoomUrl: string | null;
    doctor: { user: { firstName: string; lastName: string } };
    patient: { firstName: string; lastName: string };
  }): AppointmentListItem {
    return {
      id: appointment.id,
      doctorId: appointment.doctorId,
      doctorName: `Dr. ${appointment.doctor.user.firstName} ${appointment.doctor.user.lastName}`,
      patientId: appointment.patientId,
      patientName: `${appointment.patient.firstName} ${appointment.patient.lastName}`,
      appointmentTime: appointment.scheduledAt.toISOString(),
      type: appointment.type === 'IN_PERSON' ? 'in-person' : 'online',
      status: appointment.status.toLowerCase(),
      notes: appointment.notes,
      durationMin: appointment.durationMin,
      canJoin:
        appointment.type === 'ONLINE' &&
        appointment.status === 'CONFIRMED' &&
        this.canJoinNow(appointment.scheduledAt),
      videoRoomUrl: appointment.videoRoomUrl,
    };
  }
}
