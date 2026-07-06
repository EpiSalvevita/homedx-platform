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
  patientGender: string | null;
  appointmentTime: string;
  type: string;
  status: string;
  notes: string | null;
  testTypeId: string | null;
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
    linkedRapidTestId?: string;
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
      if (this.videoService.isConfigured()) {
        const room = await this.videoService.createRoom(videoRoomName);
        videoRoomName = room.roomName;
        videoRoomUrl = room.roomUrl;
      }
    }

    const appointment = await this.prisma.appointment.create({
      data: {
        patientId: params.patientId,
        doctorId: params.doctorId,
        scheduledAt: params.appointmentTime,
        type: appointmentType,
        status: 'CONFIRMED',
        notes: params.notes,
        testTypeId: params.testTypeId,
        linkedRapidTestId: params.linkedRapidTestId,
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

  async cancelAppointment(
    appointmentId: string,
    userId: string,
    role: string,
    message?: string,
  ) {
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

    const isPatient = appointment.patientId === userId;
    const recipientUserId = isPatient ? appointment.doctor.userId : appointment.patientId;
    const cancellerName = isPatient
      ? `${appointment.patient.firstName} ${appointment.patient.lastName}`
      : `Dr. ${appointment.doctor.user.firstName} ${appointment.doctor.user.lastName}`;
    const scheduledLabel = appointment.scheduledAt.toLocaleString('de-DE');
    const trimmedMessage = message?.trim();

    let notificationMessage = isPatient
      ? `${cancellerName} hat den Termin am ${scheduledLabel} storniert.`
      : `${cancellerName} hat Ihren Termin am ${scheduledLabel} storniert.`;

    if (trimmedMessage) {
      notificationMessage += ` Nachricht: ${trimmedMessage}`;
    }

    await this.notificationService.create({
      userId: recipientUserId,
      type: 'APPOINTMENT_CANCELLED',
      title: 'Termin storniert',
      message: notificationMessage,
      data: JSON.stringify({
        appointmentId,
        cancellationMessage: trimmedMessage ?? null,
      }),
    });

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

    if (!this.canJoinNow(appointment.scheduledAt, appointment.durationMin)) {
      throw new BadRequestException('Video call is not available yet');
    }

    if (!this.videoService.isConfigured()) {
      throw new BadRequestException(
        'Videoanrufe sind auf diesem Server nicht konfiguriert (DAILY_API_KEY fehlt).',
      );
    }

    const roomName =
      appointment.videoRoomName ?? `homedx-${appointment.id.slice(-12)}`;
    const room = await this.videoService.ensureRoom(roomName);

    if (
      appointment.videoRoomName !== room.roomName ||
      appointment.videoRoomUrl !== room.roomUrl
    ) {
      await this.prisma.appointment.update({
        where: { id: appointmentId },
        data: {
          videoRoomName: room.roomName,
          videoRoomUrl: room.roomUrl,
        },
      });
    }

    const isDoctor = role === 'DOCTOR';
    const displayName = isDoctor
      ? `Dr. ${appointment.doctor.user.firstName} ${appointment.doctor.user.lastName}`
      : `${appointment.patient.firstName} ${appointment.patient.lastName}`;

    const { token, expiresAt } = await this.videoService.createMeetingToken(
      room.roomName,
      displayName,
      isDoctor,
    );

    return {
      roomUrl: room.roomUrl,
      joinUrl: this.videoService.buildJoinUrl(room.roomUrl, token),
      token,
      expiresAt: expiresAt.toISOString(),
    };
  }

  canJoinNow(scheduledAt: Date, durationMin = 30): boolean {
    const now = Date.now();
    const start = scheduledAt.getTime() - JOIN_WINDOW_BEFORE_MS;
    const end = scheduledAt.getTime() + durationMin * 60 * 1000 + JOIN_WINDOW_AFTER_MS;
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
    testTypeId?: string | null;
    durationMin: number;
    videoRoomUrl: string | null;
    doctor: { user: { firstName: string; lastName: string } };
    patient: { firstName: string; lastName: string; gender: string | null };
  }): AppointmentListItem {
    return {
      id: appointment.id,
      doctorId: appointment.doctorId,
      doctorName: `Dr. ${appointment.doctor.user.firstName} ${appointment.doctor.user.lastName}`,
      patientId: appointment.patientId,
      patientName: `${appointment.patient.firstName} ${appointment.patient.lastName}`,
      patientGender: appointment.patient.gender ?? null,
      appointmentTime: appointment.scheduledAt.toISOString(),
      type: appointment.type === 'IN_PERSON' ? 'in-person' : 'online',
      status: appointment.status.toLowerCase(),
      notes: appointment.notes,
      testTypeId: appointment.testTypeId ?? null,
      durationMin: appointment.durationMin,
      canJoin:
        appointment.type === 'ONLINE' &&
        appointment.status === 'CONFIRMED' &&
        this.canJoinNow(appointment.scheduledAt, appointment.durationMin),
      videoRoomUrl: appointment.videoRoomUrl,
    };
  }
}
