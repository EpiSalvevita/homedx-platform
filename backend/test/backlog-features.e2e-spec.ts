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

describe('Backlog features (e2e)', () => {
  let app: INestApplication;
  let moduleFixture: TestingModule;
  let token: string;
  const userId = 'backlog-e2e-user';
  const email = 'backlog-e2e@homedx.local';

  beforeAll(async () => {
    process.env.JWT_SECRET = TEST_JWT_SECRET;

    moduleFixture = await Test.createTestingModule({
      imports: [AppModule],
    }).compile();

    app = moduleFixture.createNestApplication({ rawBody: true });
    bootstrapTestApp(app);
    await app.init();

    const prisma = moduleFixture.get(PrismaService);
    const passwordHash = await bcrypt.hash('Test123!', 10);
    await prisma.user.upsert({
      where: { email },
      create: {
        id: userId,
        email,
        password: passwordHash,
        firstName: 'Backlog',
        lastName: 'Tester',
      },
      update: { firstName: 'Backlog', lastName: 'Tester' },
    });

    const jwt = moduleFixture.get(JwtService);
    token = jwt.sign({ sub: userId, email });
  });

  afterAll(async () => {
    await app.close();
  });

  it('add-test returns rapidTestId', async () => {
    const res = await request(app.getHttpServer())
      .post(`${API}/add-test`)
      .set('Authorization', `Bearer ${token}`)
      .send({ testTypeId: 'crp' });

    expect(res.status).toBeLessThan(300);
    expect(res.body.success).toBe(true);
    expect(res.body.rapidTestId).toBeDefined();
  });

  it('list-payments returns payments array', async () => {
    await request(app.getHttpServer())
      .post(`${API}/create-payment`)
      .set('Authorization', `Bearer ${token}`)
      .send({
        amount: 10,
        currency: 'EUR',
        paymentMethod: 'CREDIT_CARD',
      });

    const res = await request(app.getHttpServer())
      .post(`${API}/list-payments`)
      .set('Authorization', `Bearer ${token}`)
      .send({});

    expect(res.body.success).toBe(true);
    expect(Array.isArray(res.body.payments)).toBe(true);
  });

  it('get-unread-notification-count returns number', async () => {
    const res = await request(app.getHttpServer())
      .post(`${API}/get-unread-notification-count`)
      .set('Authorization', `Bearer ${token}`)
      .send({});

    expect(res.body.success).toBe(true);
    expect(typeof res.body.count).toBe('number');
  });
});
