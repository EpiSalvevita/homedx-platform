import { Body, Controller, Post, Request, UseGuards } from '@nestjs/common';
import { DoctorService } from '../services/doctor.service';
import { AppointmentService } from '../services/appointment.service';
import { JwtAuthGuard } from '../auth/jwt-auth.guard';
import { RolesGuard } from '../auth/roles.guard';
import { Roles } from '../auth/roles.decorator';
import {
  AppointmentIdDto,
  BookAppointmentDto,
  CancelAppointmentDto,
  DoctorSlotsDto,
  GetDoctorsDto,
  SetDoctorAvailabilityDto,
} from '../dto/mobile/appointment.dto';
import { sanitizeMobileError } from '../util/mobile-error.util';
import { MobileUserHelper } from './mobile-user.helper';
import {
  AppointmentResponse,
  AppointmentsResponse,
  AvailabilityResponse,
  BookAppointmentResponse,
  DoctorSlotsResponse,
  DoctorsResponse,
  MOBILE_API_PATH,
  VideoCallTokenResponse,
} from './mobile.types';

@Controller(MOBILE_API_PATH)
export class MobileAppointmentController {
  constructor(
    private readonly doctorService: DoctorService,
    private readonly appointmentService: AppointmentService,
    private readonly mobileUserHelper: MobileUserHelper,
  ) {}

  @Post('get-doctors')
  @UseGuards(JwtAuthGuard)
  async getDoctors(@Body() body: GetDoctorsDto): Promise<DoctorsResponse> {
    try {
      const doctors = await this.doctorService.listDoctors(body.testTypeId);
      return { success: true, doctors };
    } catch (error) {
      return sanitizeMobileError(error, 'Failed to get doctors');
    }
  }

  @Post('get-doctor-slots')
  @UseGuards(JwtAuthGuard)
  async getDoctorSlots(@Body() body: DoctorSlotsDto): Promise<DoctorSlotsResponse> {
    try {
      const from = body.from ? new Date(body.from) : undefined;
      const to = body.to ? new Date(body.to) : undefined;
      const slots = await this.doctorService.getAvailableSlots(body.doctorId, from, to);
      return { success: true, slots };
    } catch (error) {
      return sanitizeMobileError(error, 'Failed to get doctor slots');
    }
  }

  @Post('book-appointment')
  @UseGuards(JwtAuthGuard)
  async bookAppointment(
    @Request() req: { user?: { sub: string } },
    @Body() body: BookAppointmentDto,
  ): Promise<BookAppointmentResponse> {
    try {
      const userId = req.user?.sub;
      if (!userId) {
        return { success: false, error: 'Invalid token' };
      }
      const appointment = await this.appointmentService.bookAppointment({
        patientId: userId,
        doctorId: body.doctorId,
        appointmentTime: new Date(body.appointmentTime),
        type: body.type ?? 'online',
        notes: body.notes,
        testTypeId: body.testTypeId,
      });
      return {
        success: true,
        appointmentId: appointment.id,
        appointmentTime: appointment.scheduledAt.toISOString(),
      };
    } catch (error) {
      return sanitizeMobileError(error, 'Failed to book appointment');
    }
  }

  @Post('list-appointments')
  @UseGuards(JwtAuthGuard)
  async listAppointments(@Request() req: { user?: { sub: string } }): Promise<AppointmentsResponse> {
    try {
      const userId = req.user?.sub;
      if (!userId) {
        return { success: false, error: 'Invalid token' };
      }
      const role = await this.mobileUserHelper.resolveUserRole(userId);
      const appointments = await this.appointmentService.listAppointments(userId, role);
      return { success: true, appointments };
    } catch (error) {
      return sanitizeMobileError(error, 'Failed to list appointments');
    }
  }

  @Post('get-appointment')
  @UseGuards(JwtAuthGuard)
  async getAppointment(
    @Request() req: { user?: { sub: string } },
    @Body() body: AppointmentIdDto,
  ): Promise<AppointmentResponse> {
    try {
      const userId = req.user?.sub;
      if (!userId) {
        return { success: false, error: 'Invalid request' };
      }
      const role = await this.mobileUserHelper.resolveUserRole(userId);
      const appointment = await this.appointmentService.getAppointment(
        body.appointmentId,
        userId,
        role,
      );
      return { success: true, appointment };
    } catch (error) {
      return sanitizeMobileError(error, 'Failed to get appointment');
    }
  }

  @Post('cancel-appointment')
  @UseGuards(JwtAuthGuard)
  async cancelAppointment(
    @Request() req: { user?: { sub: string } },
    @Body() body: CancelAppointmentDto,
  ): Promise<AppointmentResponse> {
    try {
      const userId = req.user?.sub;
      if (!userId) {
        return { success: false, error: 'Invalid request' };
      }
      const role = await this.mobileUserHelper.resolveUserRole(userId);
      const appointment = await this.appointmentService.cancelAppointment(
        body.appointmentId,
        userId,
        role,
        body.message,
      );
      return { success: true, appointment };
    } catch (error) {
      return sanitizeMobileError(error, 'Failed to cancel appointment');
    }
  }

  @Post('get-video-call-token')
  @UseGuards(JwtAuthGuard)
  async getVideoCallToken(
    @Request() req: { user?: { sub: string } },
    @Body() body: AppointmentIdDto,
  ): Promise<VideoCallTokenResponse> {
    try {
      const userId = req.user?.sub;
      if (!userId) {
        return { success: false, error: 'Invalid request' };
      }
      const role = await this.mobileUserHelper.resolveUserRole(userId);
      const result = await this.appointmentService.getVideoCallToken(
        body.appointmentId,
        userId,
        role,
      );
      return { success: true, ...result };
    } catch (error) {
      return sanitizeMobileError(error, 'Failed to get video call token');
    }
  }

  @Post('get-doctor-availability')
  @UseGuards(JwtAuthGuard, RolesGuard)
  @Roles('DOCTOR')
  async getDoctorAvailability(@Request() req: { user?: { sub: string } }): Promise<AvailabilityResponse> {
    try {
      const userId = req.user?.sub;
      if (!userId) {
        return { success: false, error: 'Invalid token' };
      }
      const availability = await this.doctorService.getAvailability(userId);
      return { success: true, availability };
    } catch (error) {
      return sanitizeMobileError(error, 'Failed to get availability');
    }
  }

  @Post('set-doctor-availability')
  @UseGuards(JwtAuthGuard, RolesGuard)
  @Roles('DOCTOR')
  async setDoctorAvailability(
    @Request() req: { user?: { sub: string } },
    @Body() body: SetDoctorAvailabilityDto,
  ): Promise<AvailabilityResponse> {
    try {
      const userId = req.user?.sub;
      if (!userId) {
        return { success: false, error: 'Invalid token' };
      }
      const availability = await this.doctorService.setAvailability(
        userId,
        body.availability ?? [],
      );
      return { success: true, availability };
    } catch (error) {
      return sanitizeMobileError(error, 'Failed to set availability');
    }
  }
}
