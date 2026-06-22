import { Controller, Post } from '@nestjs/common';
import { APP_GUARD } from '@nestjs/core';
import { ThrottlerGuard, ThrottlerModule } from '@nestjs/throttler';
import { Test, TestingModule } from '@nestjs/testing';
import { INestApplication } from '@nestjs/common';
import * as request from 'supertest';
import { Public } from '../src/auth/public.decorator';
import { bootstrapTestApp } from './test-app';

const API = '/gg-homedx-json/gg-api/v1';

@Controller(API)
class ThrottleProbeController {
  @Public()
  @Post('throttle-probe')
  probe() {
    return { success: true };
  }
}

describe('API throttle (e2e)', () => {
  let app: INestApplication;

  beforeEach(async () => {
    const moduleRef: TestingModule = await Test.createTestingModule({
      imports: [
        ThrottlerModule.forRoot([
          { name: 'default', ttl: 60000, limit: 3 },
        ]),
      ],
      controllers: [ThrottleProbeController],
      providers: [{ provide: APP_GUARD, useClass: ThrottlerGuard }],
    }).compile();

    app = moduleRef.createNestApplication();
    bootstrapTestApp(app);
    await app.init();
  });

  afterEach(async () => {
    await app.close();
  });

  it('returns 429 after exceeding global rate limit', async () => {
    const server = app.getHttpServer();
    for (let i = 0; i < 3; i++) {
      await request(server).post(`${API}/throttle-probe`).send({}).expect(201);
    }

    await request(server).post(`${API}/throttle-probe`).send({}).expect(429);
  });
});
