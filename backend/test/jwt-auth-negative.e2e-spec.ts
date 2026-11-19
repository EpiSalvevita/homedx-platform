import { Test } from '@nestjs/testing';
import { INestApplication } from '@nestjs/common';
import { JwtModule } from '@nestjs/jwt';
import * as request from 'supertest';
import * as jwt from 'jsonwebtoken';

import { MobileTestController } from '../src/controllers/mobile-test.controller';
import { JwtAuthGuard } from '../src/auth/jwt-auth.guard';
import { RapidTestService } from '../src/services/rapid-test.service';
import { FileUploadService } from '../src/services/file-upload.service';
import { CubeService } from '../src/services/cube.service';
import { MobileTestService } from '../src/services/mobile-test.service';
import { PrismaService } from '../src/services/prisma.service';
import { bootstrapTestApp } from './test-app';

const ENDPOINT = '/gg-homedx-json/gg-api/v1/get-last-test';
const USER_ID = 'user-jwt-1';
const SECRET = 'jwt-negative-test-secret';

describe('JwtAuthGuard negative paths (e2e)', () => {
  let app: INestApplication;
  let previousSecret: string | undefined;

  beforeAll(async () => {
    previousSecret = process.env.JWT_SECRET;
    process.env.JWT_SECRET = SECRET;
    const moduleRef = await Test.createTestingModule({
      imports: [JwtModule.register({})],
      controllers: [MobileTestController],
      providers: [
        JwtAuthGuard,
        {
          provide: PrismaService,
          useValue: {
            user: {
              findUnique: jest.fn(async () => ({
                id: USER_ID,
                status: 'ACTIVE',
                role: 'PATIENT',
                email: 'synthetic@example.test',
                tokenVersion: 0,
              })),
            },
          },
        },
        { provide: RapidTestService, useValue: { findByUserId: jest.fn(async () => []) } },
        { provide: FileUploadService, useValue: {} },
        { provide: CubeService, useValue: {} },
        { provide: MobileTestService, useValue: {} },
      ],
    }).compile();
    app = moduleRef.createNestApplication();
    bootstrapTestApp(app);
    await app.init();
  });

  afterAll(async () => {
    await app.close();
    if (previousSecret === undefined) delete process.env.JWT_SECRET;
    else process.env.JWT_SECRET = previousSecret;
  });

  const post = (token?: string) => {
    const r = request(app.getHttpServer()).post(ENDPOINT);
    return (token ? r.set('Authorization', `Bearer ${token}`) : r).send({});
  };

  const expectUnauthorized = (res: request.Response) => {
    expect(res.status).toBe(401);
    expect(res.body).not.toHaveProperty('stack');
    expect(JSON.stringify(res.body)).not.toMatch(/secret|jsonwebtoken|at .*\.js/i);
  };

  const b64 = (o: object) => Buffer.from(JSON.stringify(o)).toString('base64url');

  it('control: valid HS256 token is accepted', async () => {
    const token = jwt.sign({ sub: USER_ID, tv: 0 }, SECRET, { algorithm: 'HS256' });
    const res = await post(token);
    expect(res.status).toBeGreaterThanOrEqual(200);
    expect(res.status).toBeLessThan(300);
    expect(res.body.success).toBe(true);
  });

  it('rejects a request without token', async () => {
    expectUnauthorized(await post());
  });

  it('rejects an expired token', async () => {
    const token = jwt.sign({ sub: USER_ID, tv: 0 }, SECRET, { algorithm: 'HS256', expiresIn: -60 });
    expectUnauthorized(await post(token));
  });

  it('rejects a token signed with the wrong secret', async () => {
    const token = jwt.sign({ sub: USER_ID, tv: 0 }, 'some-other-secret', { algorithm: 'HS256' });
    expectUnauthorized(await post(token));
  });

  it('rejects alg:none tokens', async () => {
    const token = `${b64({ alg: 'none', typ: 'JWT' })}.${b64({ sub: USER_ID, tv: 0 })}.`;
    expectUnauthorized(await post(token));
  });

  it('rejects a non-HS256 algorithm even with the right secret (HS512)', async () => {
    const token = jwt.sign({ sub: USER_ID, tv: 0 }, SECRET, { algorithm: 'HS512' });
    expectUnauthorized(await post(token));
  });

  it('rejects a token whose tokenVersion does not match', async () => {
    const token = jwt.sign({ sub: USER_ID, tv: 5 }, SECRET, { algorithm: 'HS256' });
    expectUnauthorized(await post(token));
  });
});
