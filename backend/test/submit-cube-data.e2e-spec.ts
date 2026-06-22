import { Test, TestingModule } from '@nestjs/testing';
import {
  ExecutionContext,
  INestApplication,
  UnauthorizedException,
} from '@nestjs/common';
import { JwtService } from '@nestjs/jwt';
import * as request from 'supertest';

import { MobileTestController } from '../src/controllers/mobile-test.controller';
import { JwtAuthGuard } from '../src/auth/jwt-auth.guard';
import { AuthService } from '../src/services/auth.service';
import { UserService } from '../src/services/user.service';
import { RapidTestService } from '../src/services/rapid-test.service';
import { FileUploadService } from '../src/services/file-upload.service';
import { DoctorService } from '../src/services/doctor.service';
import { AppointmentService } from '../src/services/appointment.service';
import { MobilePaymentService } from '../src/services/mobile-payment.service';
import { MobileTestService } from '../src/services/mobile-test.service';
import { MobileCertificateService } from '../src/services/mobile-certificate.service';
import { MobileNotificationService } from '../src/services/mobile-notification.service';
import { CubeService } from '../src/services/cube.service';
import { PrismaService } from '../src/services/prisma.service';
import { bootstrapTestApp } from './test-app';

const ENDPOINT = '/gg-homedx-json/gg-api/v1/submit-cube-data';
const TEST_USER_ID = 'user-abc';

/**
 * Captures the args MobileController.submitCubeData passes to Prisma so we
 * can assert on the persisted shape (notes payload, testDate, etc.) without
 * hitting a real Postgres.
 */
function createPrismaMock() {
  const testKits: any[] = [];
  const rapidTests: any[] = [];

  return {
    testKit: {
      findFirst: jest.fn(async () =>
        testKits.find((k) => k.status === 'AVAILABLE') ?? null,
      ),
      create: jest.fn(async ({ data }: { data: any }) => {
        const kit = { id: `kit-${testKits.length + 1}`, ...data };
        testKits.push(kit);
        return kit;
      }),
    },
    rapidTest: {
      create: jest.fn(async ({ data }: { data: any }) => {
        const test = { id: `test-${rapidTests.length + 1}`, ...data };
        rapidTests.push(test);
        return test;
      }),
      findUnique: jest.fn(async ({ where }: { where: { id: string } }) =>
        rapidTests.find((t) => t.id === where.id) ?? null,
      ),
      update: jest.fn(async ({ where, data }: { where: { id: string }; data: any }) => {
        const idx = rapidTests.findIndex((t) => t.id === where.id);
        if (idx >= 0) {
          rapidTests[idx] = { ...rapidTests[idx], ...data };
          return rapidTests[idx];
        }
        return null;
      }),
    },
    _testKits: testKits,
    _rapidTests: rapidTests,
  };
}

type PrismaMock = ReturnType<typeof createPrismaMock>;

async function buildApp(options?: {
  guard?: { canActivate: (ctx: ExecutionContext) => boolean };
}): Promise<{ app: INestApplication; prisma: PrismaMock }> {
  const prisma = createPrismaMock();

  const guard =
    options?.guard ?? {
      canActivate: (ctx: ExecutionContext) => {
        ctx.switchToHttp().getRequest().user = { sub: TEST_USER_ID };
        return true;
      },
    };

  const moduleRef: TestingModule = await Test.createTestingModule({
    controllers: [MobileTestController],
    providers: [
      CubeService,
      { provide: PrismaService, useValue: prisma },
      { provide: AuthService, useValue: {} },
      { provide: UserService, useValue: {} },
      { provide: RapidTestService, useValue: {} },
      { provide: FileUploadService, useValue: {} },
      { provide: DoctorService, useValue: {} },
      { provide: AppointmentService, useValue: {} },
      { provide: MobilePaymentService, useValue: {} },
      { provide: MobileTestService, useValue: {} },
      {
        provide: MobileCertificateService,
        useValue: { issueForRapidTest: jest.fn(async () => null) },
      },
      {
        provide: MobileNotificationService,
        useValue: { notifyUser: jest.fn(async () => undefined) },
      },
      { provide: JwtService, useValue: {} },
    ],
  })
    .overrideGuard(JwtAuthGuard)
    .useValue(guard)
    .compile();

  const app = moduleRef.createNestApplication();
  bootstrapTestApp(app);
  await app.init();
  return { app, prisma };
}

describe('CubeService metadata parsing', () => {
  const service = new CubeService(
    {} as never,
    { issueForRapidTest: async () => null } as never,
    { notifyUser: async () => undefined } as never,
  );

  it('prefers structured columns over legacy notes JSON', () => {
    const parsed = service.parseCubeMetadata({
      testTypeId: 'crp',
      cubeResultData: [{ name: 'CRP', value: '5', class: 'NEGATIVE' }],
      notes: JSON.stringify({
        testTypeId: 'legacy-only',
        resultData: [{ name: 'Old', value: '1' }],
      }),
    });

    expect(parsed.testTypeId).toBe('crp');
    expect(parsed.resultData).toHaveLength(1);
    expect(parsed.resultData[0].name).toBe('CRP');
  });

  it('falls back to notes JSON when structured columns are empty', () => {
    const parsed = service.parseCubeMetadata({
      notes: JSON.stringify({
        testTypeId: 'rheumacheck',
        resultData: [{ name: 'Rheuma', value: '2.1', class: 'POS' }],
      }),
    });

    expect(parsed.testTypeId).toBe('rheumacheck');
    expect(parsed.resultData[0].class).toBe('POS');
  });
});

describe('POST /submit-cube-data (e2e)', () => {
  let app: INestApplication;
  let prisma: PrismaMock;

  beforeEach(async () => {
    ({ app, prisma } = await buildApp());
  });

  afterEach(async () => {
    await app.close();
  });

  it('persists a positive Cube result and echoes resultData', async () => {
    const resultData = [
      {
        name: 'Rheuma',
        value: '1.23',
        unit: 'mg/L',
        class: 'POSITIVE',
        validity: 1,
      },
    ];

    const response = await request(app.getHttpServer())
      .post(ENDPOINT)
      .send({
        testTypeId: 'rheumacheck',
        deviceSerial: 'SN-007',
        measurementTimestamp: 1_700_000_000_000,
        result: 'POSITIVE',
        resultData,
      })
      .expect(201);

    expect(response.body.success).toBe(true);
    expect(response.body.testId).toBeDefined();
    expect(response.body.result).toBe('POSITIVE');
    expect(response.body.resultData).toEqual(resultData);

    expect(prisma.rapidTest.create).toHaveBeenCalledTimes(1);
    const created = prisma._rapidTests[0];
    expect(created.userId).toBe(TEST_USER_ID);
    expect(created.status).toBe('COMPLETED');
    expect(created.result).toBe('POSITIVE');
    expect(created.testDate.getTime()).toBe(1_700_000_000_000);
    expect(created.testTypeId).toBe('rheumacheck');
    expect(created.source).toBe('cube');
    expect(created.deviceSerial).toBe('SN-007');
    expect(created.cubeResultData).toEqual(resultData);

    const notes = JSON.parse(created.notes);
    expect(notes.source).toBe('cube');
    expect(notes.testTypeId).toBe('rheumacheck');
    expect(notes.deviceSerial).toBe('SN-007');
    expect(notes.measurementTimestamp).toBe(1_700_000_000_000);
    expect(notes.resultData).toEqual(resultData);
  });

  it('falls back to a fresh TestKit when none are available', async () => {
    expect(prisma._testKits).toHaveLength(0);

    await request(app.getHttpServer())
      .post(ENDPOINT)
      .send({ testTypeId: 'covid-rapid', result: 'NEGATIVE' })
      .expect(201);

    expect(prisma.testKit.create).toHaveBeenCalledTimes(1);
    expect(prisma._testKits).toHaveLength(1);
    expect(prisma._testKits[0].manufacturer).toBe('Cube Device');
  });

  it('reuses an existing AVAILABLE TestKit instead of creating one', async () => {
    prisma._testKits.push({
      id: 'pre-existing-kit',
      status: 'AVAILABLE',
      manufacturer: 'Cube Device',
    });

    await request(app.getHttpServer())
      .post(ENDPOINT)
      .send({ testTypeId: 'covid-rapid', result: 'NEGATIVE' })
      .expect(201);

    expect(prisma.testKit.create).not.toHaveBeenCalled();
    expect(prisma._rapidTests[0].testKitId).toBe('pre-existing-kit');
  });

  it('normalizes a "POS" entry inside resultData to POSITIVE', async () => {
    const response = await request(app.getHttpServer())
      .post(ENDPOINT)
      .send({
        testTypeId: 'rheumacheck',
        // No top-level `result` — controller must derive it from class fields.
        resultData: [
          { name: 'Rheuma', value: '0.9', class: 'POS', validity: 1 },
        ],
      })
      .expect(201);

    expect(response.body.success).toBe(true);
    expect(response.body.result).toBe('POSITIVE');
    expect(prisma._rapidTests[0].result).toBe('POSITIVE');
  });

  it('falls back to INCONCLUSIVE when nothing classifies', async () => {
    const response = await request(app.getHttpServer())
      .post(ENDPOINT)
      .send({
        testTypeId: 'rheumacheck',
        resultData: [
          { name: 'Rheuma', value: '0.1', class: '', validity: 0 },
        ],
      })
      .expect(201);

    expect(response.body.result).toBe('INCONCLUSIVE');
    expect(prisma._rapidTests[0].result).toBe('INCONCLUSIVE');
  });

  it('returns success: false when testTypeId is missing', async () => {
    const response = await request(app.getHttpServer())
      .post(ENDPOINT)
      .send({ result: 'POSITIVE' })
      .expect(201);

    expect(response.body.success).toBe(false);
    expect(response.body.error).toBe('Invalid request');
    expect(response.body.validation).toBeDefined();
    expect(prisma.rapidTest.create).not.toHaveBeenCalled();
  });

  it('uses the current time when measurementTimestamp is omitted', async () => {
    const before = Date.now();
    await request(app.getHttpServer())
      .post(ENDPOINT)
      .send({ testTypeId: 'rheumacheck', result: 'NEGATIVE' })
      .expect(201);
    const after = Date.now();

    const created = prisma._rapidTests[0];
    expect(created.testDate).toBeInstanceOf(Date);
    expect(created.testDate.getTime()).toBeGreaterThanOrEqual(before);
    expect(created.testDate.getTime()).toBeLessThanOrEqual(after);
  });
});

describe('POST /submit-cube-data (e2e) — unauthenticated', () => {
  let app: INestApplication;

  beforeEach(async () => {
    ({ app } = await buildApp({
      guard: {
        canActivate: () => {
          throw new UnauthorizedException('No token provided');
        },
      },
    }));
  });

  afterEach(async () => {
    await app.close();
  });

  it('rejects requests without a valid token', async () => {
    await request(app.getHttpServer())
      .post(ENDPOINT)
      .send({ testTypeId: 'rheumacheck', result: 'POSITIVE' })
      .expect(401);
  });
});
