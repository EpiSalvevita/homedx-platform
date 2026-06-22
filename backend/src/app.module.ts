import { Module } from '@nestjs/common';
import { APP_GUARD } from '@nestjs/core';
import { JwtModule } from '@nestjs/jwt';
import { PassportModule } from '@nestjs/passport';
import { MulterModule } from '@nestjs/platform-express';
import { PrismaService } from './services/prisma.service';
import { UserService } from './services/user.service';
import { LicenseService } from './services/license.service';
import { AuthService } from './services/auth.service';
import { PaymentService } from './services/payment.service';
import { RapidTestService } from './services/rapid-test.service';
import { TestKitService } from './services/test-kit.service';
import { CertificateService } from './services/certificate.service';
import { AuditLogService } from './services/audit-log.service';
import { NotificationService } from './services/notification.service';
import { FileUploadService } from './services/file-upload.service';
import { LegalPageService } from './services/legal-page.service';
import { StripeService } from './services/stripe.service';
import { PayPalService } from './services/paypal.service';
import { JwtStrategy } from './auth/jwt.strategy';
import { MobileController } from './controllers/mobile.controller';
import { WebhooksController } from './controllers/webhooks.controller';
import { JwtAuthGuard } from './auth/jwt-auth.guard';
import { RolesGuard } from './auth/roles.guard';
import { getJwtSecret } from './config/env.config';
import { DoctorService } from './services/doctor.service';
import { AppointmentService } from './services/appointment.service';
import { VideoService } from './services/video.service';
import { CubeService } from './services/cube.service';
import { MobilePaymentService } from './services/mobile-payment.service';
import { MobileTestService } from './services/mobile-test.service';
import { MobileCertificateService } from './services/mobile-certificate.service';
import { MobileNotificationService } from './services/mobile-notification.service';
import { PushService } from './services/push.service';

@Module({
  imports: [
    PassportModule,
    MulterModule.register({
      dest: './uploads',
    }),
    JwtModule.register({
      secret: getJwtSecret(),
      signOptions: { expiresIn: '24h' },
    }),
  ],
  controllers: [MobileController, WebhooksController],
  providers: [
    PrismaService,
    UserService,
    LicenseService,
    AuthService,
    PaymentService,
    RapidTestService,
    TestKitService,
    CertificateService,
    AuditLogService,
    NotificationService,
    FileUploadService,
    LegalPageService,
    StripeService,
    PayPalService,
    DoctorService,
    AppointmentService,
    VideoService,
    CubeService,
    MobilePaymentService,
    MobileTestService,
    MobileCertificateService,
    MobileNotificationService,
    PushService,
    JwtStrategy,
    JwtAuthGuard,
    RolesGuard,
    {
      provide: APP_GUARD,
      useClass: JwtAuthGuard,
    },
  ],
})
export class AppModule {}
