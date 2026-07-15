import { Test, TestingModule } from '@nestjs/testing';
import { INestApplication } from '@nestjs/common';
import { JwtService } from '@nestjs/jwt';
import * as bcrypt from 'bcrypt';
import * as request from 'supertest';
import { AppModule } from '../src/app.module';
import { PrismaService } from '../src/services/prisma.service';
import { bootstrapTestApp } from './test-app';

const TEST_JWT_SECRET = process.env.JWT_SECRET || 'test-jwt-secret-for-e2e';
const API = '/gg-homedx-json/gg-api/v1';

describe('Questionnaires (e2e)', () => {
  let app: INestApplication;
  let moduleFixture: TestingModule;
  let prisma: PrismaService;
  let patientToken: string;
  let doctorToken: string;

  const patientId = 'quest-e2e-patient';
  const doctorUserId = 'quest-e2e-doctor-user';
  const doctorProfileId = 'quest-e2e-doctor-profile';
  const patientEmail = 'quest-e2e-patient@homedx.local';
  const doctorEmail = 'quest-e2e-doctor@homedx.local';

  beforeAll(async () => {
    process.env.JWT_SECRET = TEST_JWT_SECRET;

    moduleFixture = await Test.createTestingModule({
      imports: [AppModule],
    }).compile();

    app = moduleFixture.createNestApplication({ rawBody: true });
    bootstrapTestApp(app);
    await app.init();

    prisma = moduleFixture.get(PrismaService);
    const passwordHash = await bcrypt.hash('Test123!', 10);

    await prisma.user.upsert({
      where: { email: patientEmail },
      create: {
        id: patientId,
        email: patientEmail,
        password: passwordHash,
        firstName: 'Pat',
        lastName: 'Quest',
        role: 'USER',
      },
      update: { role: 'USER' },
    });

    await prisma.user.upsert({
      where: { email: doctorEmail },
      create: {
        id: doctorUserId,
        email: doctorEmail,
        password: passwordHash,
        firstName: 'Doc',
        lastName: 'Quest',
        role: 'DOCTOR',
      },
      update: { role: 'DOCTOR' },
    });

    await prisma.doctorProfile.upsert({
      where: { userId: doctorUserId },
      create: {
        id: doctorProfileId,
        userId: doctorUserId,
        specialization: 'Rheumatologie',
        isActive: true,
      },
      update: { isActive: true },
    });

    const jwt = moduleFixture.get(JwtService);
    patientToken = jwt.sign({ sub: patientId, email: patientEmail });
    doctorToken = jwt.sign({ sub: doctorUserId, email: doctorEmail });
  });

  afterAll(async () => {
    await prisma.questionnaireSubmission.deleteMany({
      where: { userId: { in: [patientId, doctorUserId] } },
    });
    await app.close();
  });

  it('patient can list modules A and C', async () => {
    const res = await request(app.getHttpServer())
      .post(`${API}/get-questionnaire-modules`)
      .set('Authorization', `Bearer ${patientToken}`)
      .send({})
      .expect(201);

    expect(res.body.success).toBe(true);
    const ids = (res.body.modules as Array<{ moduleId: string }>).map((m) => m.moduleId);
    expect(ids).toContain('A');
    expect(ids).toContain('C');
    expect(ids).not.toContain('B');
  });

  it('doctor can list modules B and D', async () => {
    const res = await request(app.getHttpServer())
      .post(`${API}/get-questionnaire-modules`)
      .set('Authorization', `Bearer ${doctorToken}`)
      .send({})
      .expect(201);

    const ids = (res.body.modules as Array<{ moduleId: string }>).map((m) => m.moduleId);
    expect(ids).toContain('B');
    expect(ids).toContain('D');
    expect(ids).not.toContain('A');
  });

  it('patient submits module A with consent', async () => {
    const res = await request(app.getHttpServer())
      .post(`${API}/submit-questionnaire`)
      .set('Authorization', `Bearer ${patientToken}`)
      .send({
        moduleId: 'A',
        consentStatus: 'yes',
        answers: {
          A_consent_info_read: 'ja',
          A_joint_pain: 'nein',
        },
      })
      .expect(201);

    expect(res.body.success).toBe(true);
    expect(res.body.submission.status).toBe('submitted');
    expect(res.body.submission.moduleId).toBe('A');
  });

  it('doctor submits module B', async () => {
    const res = await request(app.getHttpServer())
      .post(`${API}/submit-questionnaire`)
      .set('Authorization', `Bearer ${doctorToken}`)
      .send({
        moduleId: 'B',
        answers: {
          B_specialty: ['Rheumatologie'],
        },
      })
      .expect(201);

    expect(res.body.success).toBe(true);
    expect(res.body.submission.moduleId).toBe('B');
  });

  it('patient cannot submit module B', async () => {
    const res = await request(app.getHttpServer())
      .post(`${API}/submit-questionnaire`)
      .set('Authorization', `Bearer ${patientToken}`)
      .send({
        moduleId: 'B',
        answers: { B_specialty: ['Hausarztpraxis'] },
      })
      .expect(201);

    expect(res.body.success).toBe(false);
  });

  it('draft can be saved and resumed', async () => {
    const draftRes = await request(app.getHttpServer())
      .post(`${API}/save-questionnaire-draft`)
      .set('Authorization', `Bearer ${patientToken}`)
      .send({
        moduleId: 'C',
        consentStatus: 'yes',
        answers: { C_used_app: 'ja' },
      })
      .expect(201);

    expect(draftRes.body.success).toBe(true);
    const submissionId = draftRes.body.submission.id as string;

    const getRes = await request(app.getHttpServer())
      .post(`${API}/get-questionnaire-submission`)
      .set('Authorization', `Bearer ${patientToken}`)
      .send({ submissionId })
      .expect(201);

    expect(getRes.body.submission.answers.C_used_app).toBe('ja');
  });
});
