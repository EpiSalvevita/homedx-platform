import { Test, TestingModule } from '@nestjs/testing';
import { INestApplication } from '@nestjs/common';
import * as request from 'supertest';
import { AppModule } from '../src/app.module';
import { bootstrapTestApp } from './test-app';

const TEST_JWT_SECRET = 'test-jwt-secret-for-e2e';
const API = '/gg-homedx-json/gg-api/v1';

describe('Mobile REST API (e2e)', () => {
  let app: INestApplication;

  beforeEach(async () => {
    process.env.JWT_SECRET = TEST_JWT_SECRET;
    process.env.NODE_ENV = 'test';

    const moduleFixture: TestingModule = await Test.createTestingModule({
      imports: [AppModule],
    }).compile();

    app = moduleFixture.createNestApplication({ rawBody: true });
    bootstrapTestApp(app);
    await app.init();
  });

  afterEach(async () => {
    await app.close();
  });

  it('get-be-status-flags is public', () => {
    return request(app.getHttpServer())
      .post(`${API}/get-be-status-flags`)
      .send({})
      .expect(201)
      .expect((res) => {
        expect(res.body.success).toBe(true);
        expect(res.body.online).toBe(true);
      });
  });

  it('create-payment requires authentication', () => {
    return request(app.getHttpServer())
      .post(`${API}/create-payment`)
      .send({
        amount: 10,
        currency: 'EUR',
        paymentMethod: 'CREDIT_CARD',
      })
      .expect(401);
  });

  it('login rejects missing credentials with validation errors', () => {
    return request(app.getHttpServer())
      .post(`${API}/login`)
      .send({})
      .expect(201)
      .expect((res) => {
        expect(res.body.success).toBe(false);
        expect(res.body.error).toBe('Invalid request');
        expect(res.body.validation).toBeDefined();
        expect(res.body.validation.length).toBeGreaterThan(0);
      });
  });

  it('register-account rejects invalid email with validation errors', () => {
    return request(app.getHttpServer())
      .post(`${API}/register-account`)
      .send({
        firstname: 'Test',
        lastname: 'User',
        email: 'not-an-email',
        password: 'secret12',
      })
      .expect(201)
      .expect((res) => {
        expect(res.body.success).toBe(false);
        expect(res.body.error).toBe('Invalid request');
        expect(res.body.validation).toBeDefined();
        expect(res.body.validation.length).toBeGreaterThan(0);
      });
  });
});
