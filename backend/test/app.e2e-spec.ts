import { Test, TestingModule } from '@nestjs/testing';
import { INestApplication } from '@nestjs/common';
import * as request from 'supertest';
import { AppModule } from '../src/app.module';

const TEST_JWT_SECRET = 'test-jwt-secret-for-e2e';
const API = '/gg-homedx-json/gg-api/v1';

describe('Mobile REST API (e2e)', () => {
  let app: INestApplication;

  beforeEach(async () => {
    process.env.JWT_SECRET = TEST_JWT_SECRET;

    const moduleFixture: TestingModule = await Test.createTestingModule({
      imports: [AppModule],
    }).compile();

    app = moduleFixture.createNestApplication();
    await app.init();
  });

  it('get-be-status-flags is public', () => {
    return request(app.getHttpServer())
      .post(`${API}/get-be-status-flags`)
      .send({})
      .expect(201)
      .expect((res) => {
        expect(res.body.success).toBe(true);
        expect(res.body.cwa).toBe(true);
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

  afterEach(async () => {
    await app.close();
  });
});
