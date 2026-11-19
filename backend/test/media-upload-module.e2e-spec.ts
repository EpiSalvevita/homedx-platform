import { Test } from '@nestjs/testing';
import { ExecutionContext, INestApplication } from '@nestjs/common';
import * as request from 'supertest';
import * as fs from 'fs';
import * as os from 'os';
import * as path from 'path';

import { TestsModule } from '../src/modules/tests/tests.module';
import { PrismaModule } from '../src/modules/prisma/prisma.module';
import { CommonModule } from '../src/modules/common/common.module';
import { JwtAuthGuard } from '../src/auth/jwt-auth.guard';
import { PrismaService } from '../src/services/prisma.service';
import { bootstrapTestApp } from './test-app';

const API = '/gg-homedx-json/gg-api/v1';
const PNG = Buffer.concat([
  Buffer.from([0x89, 0x50, 0x4e, 0x47, 0x0d, 0x0a, 0x1a, 0x0a]),
  Buffer.alloc(64),
]);

// Builds the real TestsModule (controller, interceptor options, real
// MobileTestService ownership check); only Prisma and the guard are faked.
// This proves the multer limits are applied in the wired application, not just
// in a hand-assembled controller module.
describe('Media upload via the real TestsModule (e2e)', () => {
  let app: INestApplication;
  let tmpRoot: string;
  let originalCwd: string;
  const prisma = {
    rapidTest: {
      findUnique: jest.fn(async ({ where }: { where: { id: string } }) =>
        where.id === 'rt-own' ? { id: 'rt-own', userId: 'u1', status: 'PENDING' } : null,
      ),
      update: jest.fn(async () => ({})),
    },
  };

  beforeAll(async () => {
    originalCwd = process.cwd();
    tmpRoot = fs.mkdtempSync(path.join(os.tmpdir(), 'hdx-upload-mod-e2e-'));
    process.chdir(tmpRoot);
    process.env.HOMEDX_VIDEO_TMP_DIR = path.join(tmpRoot, 'video-tmp');
    const moduleRef = await Test.createTestingModule({ imports: [PrismaModule, CommonModule, TestsModule] })
      .overrideProvider(PrismaService)
      .useValue(prisma)
      .overrideGuard(JwtAuthGuard)
      .useValue({
        canActivate: (ctx: ExecutionContext) => {
          ctx.switchToHttp().getRequest().user = { sub: 'u1' };
          return true;
        },
      })
      .compile();
    app = moduleRef.createNestApplication();
    bootstrapTestApp(app);
    await app.init();
  });

  afterAll(async () => {
    await app.close();
    delete process.env.HOMEDX_VIDEO_TMP_DIR;
    process.chdir(originalCwd);
    fs.rmSync(tmpRoot, { recursive: true, force: true });
  });

  const stored = () => {
    const dir = path.join(tmpRoot, 'uploads', 'photos');
    return fs.existsSync(dir) ? fs.readdirSync(dir) : [];
  };

  it('stores a valid photo for the owner and updates the test', async () => {
    const res = await request(app.getHttpServer())
      .post(`${API}/add-rapid-test-photo`)
      .field('rapidTestId', 'rt-own')
      .attach('media', PNG, { filename: 'p.png', contentType: 'image/png' });
    expect(res.body.success).toBe(true);
    expect(stored()).toContain(res.body.objectName);
    expect(prisma.rapidTest.update).toHaveBeenCalled();
  });

  it('rejects an oversize photo at the multer layer and stores nothing', async () => {
    const before = stored().length;
    const big = Buffer.concat([PNG, Buffer.alloc(11 * 1024 * 1024)]);
    const res = await request(app.getHttpServer())
      .post(`${API}/add-rapid-test-photo`)
      .field('rapidTestId', 'rt-own')
      .attach('media', big, { filename: 'big.png', contentType: 'image/png' })
      .ok(() => true);
    // The mobile exception filter maps multer's 413 to the sanitized
    // "File too large". The service-level check would instead answer
    // "File size exceeds ...", so this proves the interceptor limit is applied
    // in the wired module.
    expect(res.body.error).toBe('File too large');
    expect(res.body.success).not.toBe(true);
    expect(stored().length).toBe(before);
  });

  it('rejects a foreign rapidTestId with zero files written', async () => {
    const before = stored().length;
    const res = await request(app.getHttpServer())
      .post(`${API}/add-rapid-test-photo`)
      .field('rapidTestId', 'rt-other')
      .attach('media', PNG, { filename: 'p.png', contentType: 'image/png' });
    expect(res.body.success).toBe(false);
    expect(stored().length).toBe(before);
  });
});
