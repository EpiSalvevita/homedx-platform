import { Module } from '@nestjs/common';
import { DoctorService } from '../../services/doctor.service';
import { AppointmentService } from '../../services/appointment.service';
import { VideoService } from '../../services/video.service';
import { MobileAppointmentController } from '../../controllers/mobile-appointment.controller';
import { NotificationsModule } from '../notifications/notifications.module';

@Module({
  imports: [NotificationsModule],
  controllers: [MobileAppointmentController],
  providers: [DoctorService, AppointmentService, VideoService],
  exports: [DoctorService, AppointmentService, VideoService],
})
export class AppointmentsModule {}
