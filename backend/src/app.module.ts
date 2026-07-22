import { Module } from '@nestjs/common';
import { APP_GUARD } from '@nestjs/core';
import { MulterModule } from '@nestjs/platform-express';
import { ThrottlerGuard, ThrottlerModule } from '@nestjs/throttler';
import { JwtAuthGuard } from './auth/jwt-auth.guard';
import { PrismaModule } from './modules/prisma/prisma.module';
import { CommonModule } from './modules/common/common.module';
import { AuthModule } from './modules/auth/auth.module';
import { TestsModule } from './modules/tests/tests.module';
import { PaymentsModule } from './modules/payments/payments.module';
import { AppointmentsModule } from './modules/appointments/appointments.module';
import { CertificatesModule } from './modules/certificates/certificates.module';
import { NotificationsModule } from './modules/notifications/notifications.module';
import { QuestionnairesModule } from './modules/questionnaires/questionnaires.module';
import { LegalModule } from './modules/legal/legal.module';

const isTestEnv = process.env.NODE_ENV === 'test' || process.env.JEST_WORKER_ID !== undefined;

@Module({
  imports: [
    ThrottlerModule.forRoot([
      {
        name: 'default',
        ttl: 60000,
        limit: isTestEnv ? 10000 : 120,
      },
    ]),
    MulterModule.register({
      dest: './uploads',
      limits: { fileSize: 10 * 1024 * 1024 },
    }),
    PrismaModule,
    CommonModule,
    AuthModule,
    NotificationsModule,
    CertificatesModule,
    TestsModule,
    PaymentsModule,
    AppointmentsModule,
    QuestionnairesModule,
    LegalModule,
  ],
  providers: [
    {
      provide: APP_GUARD,
      useClass: JwtAuthGuard,
    },
    {
      provide: APP_GUARD,
      useClass: ThrottlerGuard,
    },
  ],
})
export class AppModule {}
