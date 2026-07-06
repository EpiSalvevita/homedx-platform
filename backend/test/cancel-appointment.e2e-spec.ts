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

describe('Cancel appointment (e2e)', () => {
  let app: INestApplication;
  let moduleFixture: TestingModule;
  let prisma: PrismaService;
  let patientToken: string;
  let doctorToken: string;

  const patientId = 'cancel-e2e-patient';
  const doctorUserId = 'cancel-e2e-doctor-user';
  const doctorProfileId = 'cancel-e2e-doctor-profile';
  const patientEmail = 'cancel-e2e-patient@homedx.local';
  const doctorEmail = 'cancel-e2e-doctor@homedx.local';

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
        lastName: 'Cancel',
        role: 'USER',
      },
      update: { firstName: 'Pat', lastName: 'Cancel', role: 'USER' },
    });

    await prisma.user.upsert({
      where: { email: doctorEmail },
      create: {
        id: doctorUserId,
        email: doctorEmail,
        password: passwordHash,
        firstName: 'Doc',
        lastName: 'Cancel',
        role: 'DOCTOR',
      },
      update: { firstName: 'Doc', lastName: 'Cancel', role: 'DOCTOR' },
    });

    await prisma.doctorProfile.upsert({
      where: { userId: doctorUserId },
      create: {
        id: doctorProfileId,
        userId: doctorUserId,
        specialization: 'Allgemeinmedizin',
        isActive: true,
      },
      update: {
        specialization: 'Allgemeinmedizin',
        isActive: true,
      },
    });

    const jwt = moduleFixture.get(JwtService);
    patientToken = jwt.sign({ sub: patientId, email: patientEmail });
    doctorToken = jwt.sign({ sub: doctorUserId, email: doctorEmail });
  });

  afterAll(async () => {
    await app.close();
  });

  async function createAppointment() {
    const scheduledAt = new Date(Date.now() + 48 * 60 * 60 * 1000);
    return prisma.appointment.create({
      data: {
        patientId,
        doctorId: doctorProfileId,
        scheduledAt,
        type: 'ONLINE',
        status: 'CONFIRMED',
        notes: '[e2e] cancel appointment test',
      },
    });
  }

  it('patient cancel sends message notification to doctor only', async () => {
    const appointment = await createAppointment();
    const cancelMessage = 'Leider kann ich den Termin nicht wahrnehmen.';

    const cancelRes = await request(app.getHttpServer())
      .post(`${API}/cancel-appointment`)
      .set('Authorization', `Bearer ${patientToken}`)
      .send({ appointmentId: appointment.id, message: cancelMessage });

    expect(cancelRes.status).toBeLessThan(300);
    expect(cancelRes.body.success).toBe(true);
    expect(cancelRes.body.appointment.status).toBe('cancelled');

    const doctorNotifications = await request(app.getHttpServer())
      .post(`${API}/list-notifications`)
      .set('Authorization', `Bearer ${doctorToken}`)
      .send({});

    expect(doctorNotifications.body.success).toBe(true);
    const doctorMatch = (doctorNotifications.body.notifications as Array<{ type: string; message: string }>).find(
      (n) =>
        n.type === 'APPOINTMENT_CANCELLED' &&
        n.message.includes(cancelMessage) &&
        n.message.includes('Pat Cancel'),
    );
    expect(doctorMatch).toBeDefined();

    const patientNotifications = await request(app.getHttpServer())
      .post(`${API}/list-notifications`)
      .set('Authorization', `Bearer ${patientToken}`)
      .send({});

    const patientMatch = (patientNotifications.body.notifications as Array<{ type: string; message: string }>).find(
      (n) => n.type === 'APPOINTMENT_CANCELLED' && n.message.includes(cancelMessage),
    );
    expect(patientMatch).toBeUndefined();
  });

  it('doctor cancel sends notification to patient', async () => {
    const appointment = await createAppointment();

    const cancelRes = await request(app.getHttpServer())
      .post(`${API}/cancel-appointment`)
      .set('Authorization', `Bearer ${doctorToken}`)
      .send({ appointmentId: appointment.id, message: 'Praxis heute geschlossen.' });

    expect(cancelRes.body.success).toBe(true);

    const patientNotifications = await request(app.getHttpServer())
      .post(`${API}/list-notifications`)
      .set('Authorization', `Bearer ${patientToken}`)
      .send({});

    const patientMatch = (patientNotifications.body.notifications as Array<{ type: string; message: string }>).find(
      (n) =>
        n.type === 'APPOINTMENT_CANCELLED' &&
        n.message.includes('Praxis heute geschlossen.') &&
        n.message.includes('Dr. Doc Cancel'),
    );
    expect(patientMatch).toBeDefined();
  });
});
