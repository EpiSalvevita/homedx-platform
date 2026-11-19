import { Test } from '@nestjs/testing';
import { ExecutionContext, ForbiddenException, INestApplication } from '@nestjs/common';
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
import { getVideoTempDir } from '../src/config/media-upload.config';
import { bootstrapTestApp } from './test-app';

const API = '/gg-homedx-json/gg-api/v1';

// Synthetic bytes only: magic-number headers plus zero filler.
const PNG = Buffer.concat([
  Buffer.from([0x89, 0x50, 0x4e, 0x47, 0x0d, 0x0a, 0x1a, 0x0a]),
  Buffer.alloc(64),
]);
const WEBM = Buffer.concat([Buffer.from([0x1a, 0x45, 0xdf, 0xa3]), Buffer.alloc(64)]);
const ftyp = (brand: string) =>
  Buffer.concat([Buffer.from([0, 0, 0, 0x18]), Buffer.from('ftyp' + brand, 'latin1'), Buffer.alloc(64)]);
const MP4 = ftyp('isom');
const MOV = ftyp('qt  ');

// Regression guard: the media endpoints use FileInterceptor (multer file) and
// FileUploadService must accept that shape. Before the fix every upload
// returned success:false ("File upload failed").
describe('Media upload endpoints (e2e)', () => {
  let app: INestApplication;
  let tmpRoot: string;
  let originalCwd: string;
  const OWNER = 'user-upload-1';
  const mobileTestService = {
    assertTestOwner: jest.fn(async (rapidTestId: string, userId: string) => {
      if (rapidTestId === 'rt-foreign' || userId !== OWNER) {
        throw new ForbiddenException('Rapid test not found');
      }
    }),
    attachPhoto: jest.fn(async (..._a: unknown[]) => undefined),
    attachVideo: jest.fn(async (..._a: unknown[]) => undefined),
    attachIdentificationPhoto: jest.fn(async (..._a: unknown[]) => undefined),
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
          ctx.switchToHttp().getRequest().user = { sub: OWNER };
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
    fs.rmSync(getVideoTempDir(), { recursive: true, force: true });
  });

  const stored = (sub: string) => {
    const dir = path.join(tmpRoot, 'uploads', sub);
    return fs.existsSync(dir) ? fs.readdirSync(dir) : [];
  };
  const read = (sub: string, name: string) => fs.readFileSync(path.join(tmpRoot, 'uploads', sub, name));
  const tempFiles = () => fs.readdirSync(getVideoTempDir());
  const UUID = '[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}';

  it('add-rapid-test-photo stores a synthetic PNG with exactly the field set the mobile client sends', async () => {
    // Flutter client (test_service.dart / api_service.dart): rapidTestId only.
    const res = await request(app.getHttpServer())
      .post(`${API}/add-rapid-test-photo`)
      .field('rapidTestId', 'rt-1')
      .attach('media', PNG, { filename: 'p.png', contentType: 'image/png' });
    expect(res.body.success).toBe(true);
    expect(res.body.objectName).toMatch(new RegExp(`^photos_${UUID}\\.png$`));
    expect(read('photos', res.body.objectName)).toEqual(PNG);
    expect(mobileTestService.attachPhoto).toHaveBeenCalledWith('user-upload-1', 'rt-1', res.body.objectName);
    expect(fs.existsSync(path.join(originalCwd, 'uploads', 'photos', res.body.objectName))).toBe(false);
  });

  it('still accepts a legacy fileExtension field and ignores it', async () => {
    const res = await request(app.getHttpServer())
      .post(`${API}/add-rapid-test-photo`)
      .field('fileExtension', 'php')
      .field('rapidTestId', 'rt-1')
      .attach('media', PNG, { filename: 'p.php', contentType: 'image/png' });
    expect(res.body.success).toBe(true);
    expect(res.body.objectName).toMatch(/\.png$/);
  });

  it('add-identification-photo stores a synthetic PNG (client field set: rapidTestId + type)', async () => {
    const res = await request(app.getHttpServer())
      .post(`${API}/add-identification-photo`)
      .field('type', 'front')
      .field('rapidTestId', 'rt-1')
      .attach('media', PNG, { filename: 'i.png', contentType: 'image/png' });
    expect(res.body.success).toBe(true);
    expect(read('identification', res.body.objectName)).toEqual(PNG);
    expect(mobileTestService.attachIdentificationPhoto).toHaveBeenCalledWith(
      'user-upload-1',
      'rt-1',
      res.body.objectName,
      'front',
    );
  });

  it.each([
    ['webm', WEBM, 'video/webm', /\.webm$/],
    ['mp4', MP4, 'video/mp4', /\.mp4$/],
    ['mov', MOV, 'video/quicktime', /\.mov$/],
  ])('add-rapid-test-video stores a synthetic %s and removes the temp file', async (_n, bytes, type, ext) => {
    const res = await request(app.getHttpServer())
      .post(`${API}/add-rapid-test-video`)
      .field('rapidTestId', 'rt-1')
      .attach('media', bytes, { filename: 'v', contentType: type });
    expect(res.body.success).toBe(true);
    expect(res.body.objectName).toMatch(new RegExp(`^videos_${UUID}`));
    expect(res.body.objectName).toMatch(ext);
    expect(read('videos', res.body.objectName)).toEqual(bytes);
    expect(mobileTestService.attachVideo).toHaveBeenCalledWith('user-upload-1', 'rt-1', res.body.objectName);
    expect(tempFiles()).toEqual([]);
  });

  it('concurrent uploads get distinct names and keep their own bytes', async () => {
    const a = Buffer.concat([PNG, Buffer.from('AAAA')]);
    const b = Buffer.concat([PNG, Buffer.from('BBBB')]);
    const [ra, rb] = await Promise.all(
      [a, b].map((buf) =>
        request(app.getHttpServer())
          .post(`${API}/add-rapid-test-photo`)
          .field('rapidTestId', 'rt-1')
          .attach('media', buf, { filename: 'p.png', contentType: 'image/png' }),
      ),
    );
    expect(ra.body.success).toBe(true);
    expect(rb.body.success).toBe(true);
    expect(ra.body.objectName).not.toBe(rb.body.objectName);
    expect(read('photos', ra.body.objectName)).toEqual(a);
    expect(read('photos', rb.body.objectName)).toEqual(b);
  });

  it('rejects a wrong field name and stores nothing', async () => {
    const before = stored('photos').length;
    const res = await request(app.getHttpServer())
      .post(`${API}/add-rapid-test-photo`)
      .field('rapidTestId', 'rt-1')
      .attach('wrongfield', PNG, { filename: 'p.png', contentType: 'image/png' });
    expect(res.body.success).not.toBe(true);
    expect(stored('photos').length).toBe(before);
  });

  it('rejects non-media bytes behind a valid field set (magic-byte check)', async () => {
    const before = stored('photos').length;
    const res = await request(app.getHttpServer())
      .post(`${API}/add-rapid-test-photo`)
      .field('rapidTestId', 'rt-1')
      .attach('media', Buffer.from('not an image'), { filename: 'x.png', contentType: 'image/png' });
    expect(res.body.success).toBe(false);
    expect(res.body.error).toMatch(/not allowed/);
    expect(stored('photos').length).toBe(before);
  });

  it('rejects a video container on a photo endpoint and images on the video endpoint', async () => {
    const photosBefore = stored('photos').length;
    const r1 = await request(app.getHttpServer())
      .post(`${API}/add-rapid-test-photo`)
      .field('rapidTestId', 'rt-1')
      .attach('media', MP4, { filename: 'x.png', contentType: 'image/png' });
    expect(r1.body.success).toBe(false);
    expect(stored('photos').length).toBe(photosBefore);

    const videosBefore = stored('videos').length;
    const r2 = await request(app.getHttpServer())
      .post(`${API}/add-rapid-test-video`)
      .field('rapidTestId', 'rt-1')
      .attach('media', Buffer.from('<?php echo 1; ?>'), { filename: 'v.webm', contentType: 'video/webm' });
    expect(r2.body.success).toBe(false);
    expect(stored('videos').length).toBe(videosBefore);
    expect(tempFiles()).toEqual([]);
  });

  it('rejects an oversize image (valid fields, valid magic) and stores nothing', async () => {
    const before = stored('photos').length;
    const big = Buffer.concat([PNG, Buffer.alloc(10 * 1024 * 1024)]);
    const res = await request(app.getHttpServer())
      .post(`${API}/add-rapid-test-photo`)
      .field('rapidTestId', 'rt-1')
      .attach('media', big, { filename: 'big.png', contentType: 'image/png' })
      .ok(() => true);
    expect(res.body.success).not.toBe(true);
    expect(stored('photos').length).toBe(before);
  });

  it('rejects an oversize video, stores nothing and leaves no temp file', async () => {
    const before = stored('videos').length;
    const big = Buffer.concat([MP4, Buffer.alloc(100 * 1024 * 1024)]);
    const res = await request(app.getHttpServer())
      .post(`${API}/add-rapid-test-video`)
      .field('rapidTestId', 'rt-1')
      .attach('media', big, { filename: 'big.mp4', contentType: 'video/mp4' })
      .ok(() => true);
    expect(res.body.success).not.toBe(true);
    expect(stored('videos').length).toBe(before);
    expect(tempFiles()).toEqual([]);
  });

  it("rejects someone else's rapidTestId before writing anything", async () => {
    const calls = mobileTestService.attachPhoto.mock.calls.length;
    const photos = stored('photos').length;
    const videos = stored('videos').length;
    const r1 = await request(app.getHttpServer())
      .post(`${API}/add-rapid-test-photo`)
      .field('rapidTestId', 'rt-foreign')
      .attach('media', PNG, { filename: 'p.png', contentType: 'image/png' });
    expect(r1.body.success).toBe(false);
    const r2 = await request(app.getHttpServer())
      .post(`${API}/add-rapid-test-video`)
      .field('rapidTestId', 'rt-foreign')
      .attach('media', MP4, { filename: 'v.mp4', contentType: 'video/mp4' });
    expect(r2.body.success).toBe(false);
    expect(stored('photos').length).toBe(photos);
    expect(stored('videos').length).toBe(videos);
    expect(mobileTestService.attachPhoto.mock.calls.length).toBe(calls);
    expect(tempFiles()).toEqual([]);
  });

  it('requires rapidTestId (no orphan uploads)', async () => {
    const photos = stored('photos').length;
    const videos = stored('videos').length;
    const r1 = await request(app.getHttpServer())
      .post(`${API}/add-rapid-test-photo`)
      .attach('media', PNG, { filename: 'p.png', contentType: 'image/png' });
    expect(r1.body.success).toBe(false);
    const r2 = await request(app.getHttpServer())
      .post(`${API}/add-rapid-test-video`)
      .attach('media', MP4, { filename: 'v.mp4', contentType: 'video/mp4' });
    expect(r2.body.success).toBe(false);
    expect(stored('photos').length).toBe(photos);
    expect(stored('videos').length).toBe(videos);
    expect(tempFiles()).toEqual([]);
  });

  it('deletes the stored file again when attaching fails', async () => {
    mobileTestService.attachPhoto.mockRejectedValueOnce(new Error('db down'));
    const before = stored('photos').length;
    const res = await request(app.getHttpServer())
      .post(`${API}/add-rapid-test-photo`)
      .field('rapidTestId', 'rt-1')
      .attach('media', PNG, { filename: 'p.png', contentType: 'image/png' });
    expect(res.body.success).toBe(false);
    expect(stored('photos').length).toBe(before);
  });
});
