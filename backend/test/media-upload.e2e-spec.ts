import { Test } from '@nestjs/testing';
import { ExecutionContext, INestApplication } from '@nestjs/common';
import * as request from 'supertest';
import * as fs from 'fs';
import * as os from 'os';
import * as path from 'path';

import { MobileTestController } from '../src/controllers/mobile-test.controller';
import { JwtAuthGuard } from '../src/auth/jwt-auth.guard';
import { RapidTestService } from '../src/services/rapid-test.service';
import { FileUploadService } from '../src/services/file-upload.service';
import { CubeService } from '../src/services/cube.service';
import { MobileTestService } from '../src/services/mobile-test.service';
import { bootstrapTestApp } from './test-app';

const API = '/gg-homedx-json/gg-api/v1';

// Synthetic bytes only: PNG signature and EBML (webm) header plus filler.
const PNG = Buffer.concat([
  Buffer.from([0x89, 0x50, 0x4e, 0x47, 0x0d, 0x0a, 0x1a, 0x0a]),
  Buffer.alloc(64),
]);
const WEBM = Buffer.concat([Buffer.from([0x1a, 0x45, 0xdf, 0xa3]), Buffer.alloc(64)]);

// KNOWN DEFECT (pre-existing, not caused by the dependency upgrade): the media
// endpoints use FileInterceptor (multer memory storage, file.buffer) but
// FileUploadService.uploadFile() expects a GraphQL-upload style object with
// createReadStream(). Every real upload therefore returns success:false
// ("File upload failed"). The happy-path cases below are marked it.failing so
// they document the intended behaviour and flip to a failure (remove
// `.failing`) once the service is fixed. Rejection cases are real assertions.
describe('Media upload endpoints (e2e)', () => {
  let app: INestApplication;
  let tmpRoot: string;
  let originalCwd: string;
  const mobileTestService = {
    attachPhoto: jest.fn(async () => undefined),
    attachVideo: jest.fn(async () => undefined),
    attachIdentificationPhoto: jest.fn(async () => undefined),
  };

  beforeAll(async () => {
    // FileUploadService writes to <cwd>/uploads. Point cwd at a temp dir so
    // backend/uploads/ is never touched.
    originalCwd = process.cwd();
    tmpRoot = fs.mkdtempSync(path.join(os.tmpdir(), 'hdx-upload-e2e-'));
    process.chdir(tmpRoot);

    const moduleRef = await Test.createTestingModule({
      controllers: [MobileTestController],
      providers: [
        FileUploadService,
        { provide: RapidTestService, useValue: {} },
        { provide: CubeService, useValue: {} },
        { provide: MobileTestService, useValue: mobileTestService },
      ],
    })
      .overrideGuard(JwtAuthGuard)
      .useValue({
        canActivate: (ctx: ExecutionContext) => {
          ctx.switchToHttp().getRequest().user = { sub: 'user-upload-1' };
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
    process.chdir(originalCwd);
    fs.rmSync(tmpRoot, { recursive: true, force: true });
  });

  const stored = (sub: string) => {
    const dir = path.join(tmpRoot, 'uploads', sub);
    return fs.existsSync(dir) ? fs.readdirSync(dir) : [];
  };

  it.failing('add-rapid-test-photo stores a synthetic PNG in the temp dir and attaches it', async () => {
    const res = await request(app.getHttpServer())
      .post(`${API}/add-rapid-test-photo`)
      .field('fileExtension', 'png')
      .field('rapidTestId', 'rt-1')
      .attach('media', PNG, { filename: 'p.png', contentType: 'image/png' });
    expect(res.body.success).toBe(true);
    expect(res.body.objectName).toMatch(/^photos_\d+\.png$/);
    expect(stored('photos')).toContain(res.body.objectName);
    expect(mobileTestService.attachPhoto).toHaveBeenCalledWith(
      'user-upload-1',
      'rt-1',
      res.body.objectName,
    );
    expect(
      fs.existsSync(path.join(originalCwd, 'uploads', 'photos', res.body.objectName)),
    ).toBe(false);
  });

  it('add-rapid-test-photo rejects a wrong field name', async () => {
    const before = stored('photos').length;
    const res = await request(app.getHttpServer())
      .post(`${API}/add-rapid-test-photo`)
      .field('fileExtension', 'png')
      .attach('wrongfield', PNG, { filename: 'p.png', contentType: 'image/png' });
    expect(res.body.success).not.toBe(true);
    expect(stored('photos').length).toBe(before);
  });

  it('add-rapid-test-photo rejects non-media bytes (fail closed)', async () => {
    const before = stored('photos').length;
    const res = await request(app.getHttpServer())
      .post(`${API}/add-rapid-test-photo`)
      .field('fileExtension', 'png')
      .attach('media', Buffer.from('not an image'), {
        filename: 'x.png',
        contentType: 'image/png',
      });
    expect(res.body.success).toBe(false);
    expect(stored('photos').length).toBe(before);
  });

  it.failing('add-rapid-test-video stores a synthetic webm', async () => {
    const res = await request(app.getHttpServer())
      .post(`${API}/add-rapid-test-video`)
      .field('fileExtension', 'webm')
      .field('rapidTestId', 'rt-1')
      .attach('media', WEBM, { filename: 'v.webm', contentType: 'video/webm' });
    expect(res.body.success).toBe(true);
    expect(stored('videos')).toContain(res.body.objectName);
    expect(mobileTestService.attachVideo).toHaveBeenCalled();
  });

  it.failing('add-identification-photo stores a synthetic PNG', async () => {
    const res = await request(app.getHttpServer())
      .post(`${API}/add-identification-photo`)
      .field('fileExtension', 'png')
      .field('type', 'front')
      .field('rapidTestId', 'rt-1')
      .attach('media', PNG, { filename: 'i.png', contentType: 'image/png' });
    expect(res.body.success).toBe(true);
    expect(stored('identification')).toContain(res.body.objectName);
    expect(mobileTestService.attachIdentificationPhoto).toHaveBeenCalledWith(
      'user-upload-1',
      'rt-1',
      res.body.objectName,
      'front',
    );
  });
});
