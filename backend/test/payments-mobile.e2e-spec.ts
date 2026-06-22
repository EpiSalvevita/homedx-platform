import { Test, TestingModule } from '@nestjs/testing';
import {
  ExecutionContext,
  INestApplication,
  UnauthorizedException,
} from '@nestjs/common';
import { JwtService } from '@nestjs/jwt';
import * as request from 'supertest';

import { MobileController } from '../src/controllers/mobile.controller';
import { JwtAuthGuard } from '../src/auth/jwt-auth.guard';
import { AuthService } from '../src/services/auth.service';
import { UserService } from '../src/services/user.service';
import { RapidTestService } from '../src/services/rapid-test.service';
import { FileUploadService } from '../src/services/file-upload.service';
import { DoctorService } from '../src/services/doctor.service';
import { AppointmentService } from '../src/services/appointment.service';
import { CubeService } from '../src/services/cube.service';
import { MobilePaymentService } from '../src/services/mobile-payment.service';
import { MobileTestService } from '../src/services/mobile-test.service';
import { MobileCertificateService } from '../src/services/mobile-certificate.service';
import { MobileNotificationService } from '../src/services/mobile-notification.service';
import { PrismaService } from '../src/services/prisma.service';

const BASE = '/gg-homedx-json/gg-api/v1';
const TEST_USER_ID = 'user-pay-1';

async function buildApp(): Promise<INestApplication> {
  const mobilePaymentService = {
    getPaymentAmount: jest.fn(() => ({
      amount: 29.99,
      reducedAmount: 24.99,
      discount: 5,
      discountType: 'percentage',
    })),
    createPayment: jest.fn(async (_userId: string, body: Record<string, unknown>) => ({
      id: 'pay-1',
      userId: TEST_USER_ID,
      amount: body.amount,
      currency: body.currency,
      method: body.paymentMethod,
      status: 'PENDING',
      createdAt: new Date().toISOString(),
      updatedAt: new Date().toISOString(),
    })),
  };

  const moduleRef: TestingModule = await Test.createTestingModule({
    controllers: [MobileController],
    providers: [
      CubeService,
      { provide: PrismaService, useValue: {} },
      { provide: AuthService, useValue: {} },
      { provide: UserService, useValue: {} },
      { provide: RapidTestService, useValue: {} },
      { provide: FileUploadService, useValue: {} },
      { provide: DoctorService, useValue: {} },
      { provide: AppointmentService, useValue: {} },
      { provide: MobilePaymentService, useValue: mobilePaymentService },
      { provide: MobileTestService, useValue: {} },
      { provide: MobileCertificateService, useValue: { issueForRapidTest: jest.fn() } },
      { provide: MobileNotificationService, useValue: { notifyUser: jest.fn() } },
      { provide: JwtService, useValue: {} },
    ],
  })
    .overrideGuard(JwtAuthGuard)
    .useValue({
      canActivate: (ctx: ExecutionContext) => {
        ctx.switchToHttp().getRequest().user = { sub: TEST_USER_ID };
        return true;
      },
    })
    .compile();

  const app = moduleRef.createNestApplication();
  await app.init();
  return app;
}

describe('Mobile payment REST (e2e)', () => {
  let app: INestApplication;

  beforeEach(async () => {
    app = await buildApp();
  });

  afterEach(async () => {
    await app.close();
  });

  it('POST create-payment returns a payment record', async () => {
    const response = await request(app.getHttpServer())
      .post(`${BASE}/create-payment`)
      .send({
        amount: 49.99,
        currency: 'EUR',
        paymentMethod: 'CREDIT_CARD',
      })
      .expect(201);

    expect(response.body.success).toBe(true);
    expect(response.body.payment.id).toBe('pay-1');
    expect(response.body.payment.amount).toBe(49.99);
  });

  it('POST get-payment-amount returns pricing', async () => {
    const response = await request(app.getHttpServer())
      .post(`${BASE}/get-payment-amount`)
      .send({})
      .expect(201);

    expect(response.body.success).toBe(true);
    expect(response.body.amount).toBe(29.99);
    expect(response.body.reducedAmount).toBe(24.99);
  });

  it('POST create-payment rejects unauthenticated requests', async () => {
    const moduleRef: TestingModule = await Test.createTestingModule({
      controllers: [MobileController],
      providers: [
        CubeService,
        { provide: PrismaService, useValue: {} },
        { provide: AuthService, useValue: {} },
        { provide: UserService, useValue: {} },
        { provide: RapidTestService, useValue: {} },
        { provide: FileUploadService, useValue: {} },
        { provide: DoctorService, useValue: {} },
        { provide: AppointmentService, useValue: {} },
        { provide: MobilePaymentService, useValue: {} },
        { provide: MobileTestService, useValue: {} },
        { provide: MobileCertificateService, useValue: {} },
        { provide: MobileNotificationService, useValue: {} },
        { provide: JwtService, useValue: {} },
      ],
    })
      .overrideGuard(JwtAuthGuard)
      .useValue({
        canActivate: () => {
          throw new UnauthorizedException('No token provided');
        },
      })
      .compile();

    const unauthApp = moduleRef.createNestApplication();
    await unauthApp.init();

    const response = await request(unauthApp.getHttpServer())
      .post(`${BASE}/create-payment`)
      .send({
        amount: 10,
        currency: 'EUR',
        paymentMethod: 'PAYPAL',
      })
      .expect(401);

    expect(response.body.message).toMatch(/token|Unauthorized/i);
    await unauthApp.close();
  });
});
