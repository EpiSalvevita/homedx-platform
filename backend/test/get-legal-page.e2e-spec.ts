import { Test, TestingModule } from '@nestjs/testing';
import { INestApplication } from '@nestjs/common';
import * as request from 'supertest';

import { MobileLegalController } from '../src/controllers/mobile-legal.controller';
import { LegalPageService } from '../src/services/legal-page.service';
import { bootstrapTestApp } from './test-app';

const ENDPOINT = '/gg-homedx-json/gg-api/v1/get-legal-page';

describe('POST /get-legal-page (e2e)', () => {
  let app: INestApplication;
  let legalPageService: { getLegalPage: jest.Mock };

  beforeEach(async () => {
    legalPageService = { getLegalPage: jest.fn() };

    const moduleRef: TestingModule = await Test.createTestingModule({
      controllers: [MobileLegalController],
      providers: [{ provide: LegalPageService, useValue: legalPageService }],
    }).compile();

    app = moduleRef.createNestApplication();
    bootstrapTestApp(app);
    await app.init();
  });

  afterEach(async () => {
    await app.close();
  });

  it('is public (no auth required) and returns page content', async () => {
    legalPageService.getLegalPage.mockResolvedValueOnce({
      type: 'TERMS_CONDITIONS',
      title: 'Testbedingungen',
      content: 'Lorem ipsum',
      language: 'de',
      version: '1.0',
    });

    const response = await request(app.getHttpServer())
      .post(ENDPOINT)
      .send({ type: 'TERMS_CONDITIONS' })
      .expect(201);

    expect(response.body.success).toBe(true);
    expect(response.body.legalPage.title).toBe('Testbedingungen');
    expect(legalPageService.getLegalPage).toHaveBeenCalledWith('TERMS_CONDITIONS', 'de');
  });

  it('respects the requested language', async () => {
    legalPageService.getLegalPage.mockResolvedValueOnce({
      type: 'PRIVACY_POLICY',
      title: 'Privacy Policy',
      content: 'Lorem ipsum',
      language: 'en',
      version: '1.0',
    });

    await request(app.getHttpServer())
      .post(ENDPOINT)
      .send({ type: 'PRIVACY_POLICY', language: 'en' })
      .expect(201);

    expect(legalPageService.getLegalPage).toHaveBeenCalledWith('PRIVACY_POLICY', 'en');
  });

  it('returns success: false when the page does not exist', async () => {
    legalPageService.getLegalPage.mockResolvedValueOnce(null);

    const response = await request(app.getHttpServer())
      .post(ENDPOINT)
      .send({ type: 'COOKIE_POLICY' })
      .expect(201);

    expect(response.body.success).toBe(false);
  });

  it('rejects an invalid type', async () => {
    const response = await request(app.getHttpServer())
      .post(ENDPOINT)
      .send({ type: 'NOT_A_REAL_TYPE' })
      .expect(201);

    expect(response.body.success).toBe(false);
    expect(response.body.validation).toBeDefined();
  });
});
