import { Test, TestingModule } from '@nestjs/testing';
import { INestApplication } from '@nestjs/common';
import { JwtService } from '@nestjs/jwt';
import * as bcrypt from 'bcrypt';
import * as request from 'supertest';
import { readFileSync } from 'fs';
import { join } from 'path';
import { AppModule } from '../src/app.module';
import { PrismaService } from '../src/services/prisma.service';
import { bootstrapTestApp } from './test-app';
import { buildForms, V04Form } from '../src/utils/questionnaire-forms';
import {
  evaluateVisibility,
  V04Item,
  V04Package,
} from '../src/utils/questionnaire-v04-engine';

const TEST_JWT_SECRET = process.env.JWT_SECRET || 'test-jwt-secret-for-e2e';
const API = '/gg-homedx-json/gg-api/v1';
const CATALOGUE = join(__dirname, '..', 'data', 'questionnaires', 'rheumacheck_questionnaires_v04.public.json');

/**
 * Builds a synthetic, complete answer set for a form using the catalogue's own
 * visibility and response contracts. Synthetic values only, no clinical content.
 */
function syntheticAnswers(form: V04Form): Record<string, unknown> {
  const items = form.questionnaire.sections.flatMap((s) => s.items);
  const answers: Record<string, unknown> = {};

  for (let pass = 0; pass < 6; pass++) {
    const visible = evaluateVisibility(items, answers);
    for (const item of items) {
      if (!visible.has(item.id)) continue;
      if (answers[item.id] !== undefined) continue;
      const value = syntheticValue(item, answers);
      if (value !== undefined) answers[item.id] = value;
    }
  }
  return answers;
}

function syntheticValue(item: V04Item, answers: Record<string, unknown>): unknown {
  const c = item.responseContract;
  const restricted = item.optionSource?.intersection ?? [];
  const parent = item.optionSource ? (answers[item.optionSource.item] as string[] | undefined) ?? [] : [];
  const allowed = item.options.filter((o) => !restricted.includes(o) || parent.includes(o));

  switch (c.kind) {
    case 'categorical_single':
      return item.options[0];
    case 'categorical_multi':
      return allowed.length ? [allowed[0]] : undefined;
    case 'ranked_codes':
      return item.options.slice(0, c.minimumSelected ?? 1);
    case 'matrix':
      return Object.fromEntries(item.options.map((o) => [o, c.ratings![0]]));
    case 'integer':
      return c.minimum ?? 0;
    case 'string':
      return 'Synthetisches Testbeispiel';
    default:
      return undefined;
  }
}

describe('Questionnaires V04 (e2e)', () => {
  let app: INestApplication;
  let moduleFixture: TestingModule;
  let prisma: PrismaService;
  let patientToken: string;
  let doctorToken: string;
  let forms: V04Form[];

  const patientId = 'quest-e2e-patient';
  const doctorUserId = 'quest-e2e-doctor-user';
  const doctorProfileId = 'quest-e2e-doctor-profile';
  const patientEmail = 'quest-e2e-patient@homedx.local';
  const doctorEmail = 'quest-e2e-doctor@homedx.local';
  const reviewerId = 'quest-e2e-reviewer';
  const reviewerEmail = 'quest-e2e-reviewer@homedx.local';
  let reviewerToken: string;

  const form = (id: string) => forms.find((f) => f.moduleId === id)!;
  const post = (path: string, token: string, body: object) =>
    request(app.getHttpServer()).post(`${API}/${path}`).set('Authorization', `Bearer ${token}`).send(body);

  beforeAll(async () => {
    process.env.JWT_SECRET = TEST_JWT_SECRET;
    forms = buildForms(JSON.parse(readFileSync(CATALOGUE, 'utf8')) as V04Package);

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
        lastName: 'Quest',
        role: 'USER',
      },
      update: { role: 'USER' },
    });

    await prisma.user.upsert({
      where: { email: doctorEmail },
      create: {
        id: doctorUserId,
        email: doctorEmail,
        password: passwordHash,
        firstName: 'Doc',
        lastName: 'Quest',
        role: 'DOCTOR',
      },
      update: { role: 'DOCTOR' },
    });

    await prisma.doctorProfile.upsert({
      where: { userId: doctorUserId },
      create: {
        id: doctorProfileId,
        userId: doctorUserId,
        specialization: 'Rheumatologie',
        isActive: true,
      },
      update: { isActive: true },
    });

    await prisma.user.upsert({
      where: { email: reviewerEmail },
      create: {
        id: reviewerId,
        email: reviewerEmail,
        password: passwordHash,
        firstName: 'Rev',
        lastName: 'Quest',
        role: 'USER',
      },
      update: { role: 'USER' },
    });
    process.env.QUESTIONNAIRE_REVIEWER_USER_IDS = reviewerId;

    const jwt = moduleFixture.get(JwtService);
    reviewerToken = jwt.sign({ sub: reviewerId, email: reviewerEmail });
    patientToken = jwt.sign({ sub: patientId, email: patientEmail });
    doctorToken = jwt.sign({ sub: doctorUserId, email: doctorEmail });
  });

  afterAll(async () => {
    delete process.env.QUESTIONNAIRE_REVIEWER_USER_IDS;
    await prisma.questionnaireSubmission.deleteMany({
      where: { userId: { in: [patientId, doctorUserId, reviewerId] } },
    });
    await app.close();
  });

  it('patient sees A, C and the not-yet-assigned follow-up, never B or D', async () => {
    const res = await post('get-questionnaire-modules', patientToken, {}).expect(201);
    expect(res.body.success).toBe(true);
    const modules = res.body.modules as Array<{ moduleId: string; status: string; catalogueId: string }>;
    expect(modules.map((m) => m.moduleId).sort()).toEqual(['A', 'C', 'CFU']);
    expect(modules.find((m) => m.moduleId === 'CFU')).toMatchObject({
      status: 'not_assigned',
      catalogueId: 'RC-C-FU',
    });
  });

  it('doctor sees B and D only', async () => {
    const res = await post('get-questionnaire-modules', doctorToken, {}).expect(201);
    const ids = (res.body.modules as Array<{ moduleId: string }>).map((m) => m.moduleId).sort();
    expect(ids).toEqual(['B', 'D']);
  });

  it('refuses unknown module ids, including the retired v6.2 keys', async () => {
    for (const moduleId of ['Z', 'RC-A']) {
      const res = await post('get-questionnaire-definition', patientToken, { moduleId }).expect(201);
      expect(res.body.success).toBe(false);
      expect(res.body.error).toBe('Invalid request');
      expect(res.body.validation?.some((m: string) => m.includes('moduleId'))).toBe(true);
    }
  });

  it('refuses the follow-up definition until it is assigned', async () => {
    const res = await post('get-questionnaire-definition', patientToken, { moduleId: 'CFU' }).expect(201);
    expect(res.body.success).toBe(false);
    expect(res.body.error).toBe('NOT_ASSIGNED');
  });

  it('keeps wrong-role access refused in both directions', async () => {
    const patientOnB = await post('submit-questionnaire', patientToken, {
      moduleId: 'B',
      answers: {},
    }).expect(201);
    expect(patientOnB.body.success).toBe(false);

    const doctorOnA = await post('get-questionnaire-definition', doctorToken, { moduleId: 'A' }).expect(201);
    expect(doctorOnA.body.success).toBe(false);
  });

  it('rejects unknown item ids in a draft while keeping valid partial answers', async () => {
    const answers = { ...syntheticAnswers(form('A')) };
    // Keep only the first two answers to simulate an unfinished draft.
    const partial = Object.fromEntries(Object.entries(answers).slice(0, 2));
    const res = await post('save-questionnaire-draft', patientToken, {
      moduleId: 'A',
      answers: { ...partial, 'NOT-AN-ITEM': 'x' },
    }).expect(201);

    expect(res.body.success).toBe(false);
    expect(res.body.validation).toEqual(['NOT-AN-ITEM:unknown_item']);
  });

  it('rejects an invalid value by item id and code, without echoing the value', async () => {
    const res = await post('save-questionnaire-draft', patientToken, {
      moduleId: 'A',
      answers: { A28: '4' },
    }).expect(201);

    expect(res.body.success).toBe(false);
    expect(res.body.validation).toEqual(['A28:invalid_value']);
    expect(JSON.stringify(res.body)).not.toContain('"4"');
  });

  it('requires consent before a patient can submit', async () => {
    const res = await post('submit-questionnaire', patientToken, {
      moduleId: 'A',
      answers: syntheticAnswers(form('A')),
    }).expect(201);

    expect(res.body.success).toBe(false);
    expect(res.body.validation).toEqual(['CONSENT_REQUIRED']);
  });

  it('refuses strict submit with missing required answers', async () => {
    const res = await post('submit-questionnaire', patientToken, {
      moduleId: 'A',
      consentStatus: 'yes',
      answers: { A00: 'Ja' },
    }).expect(201);

    expect(res.body.success).toBe(false);
    expect(res.body.validation?.some((m: string) => m.endsWith(':required'))).toBe(true);
  });

  it('submits a complete synthetic module A and reads back the stored answers', async () => {
    const answers = syntheticAnswers(form('A'));
    const res = await post('submit-questionnaire', patientToken, {
      moduleId: 'A',
      consentStatus: 'yes',
      answers,
    }).expect(201);

    expect(res.body.success).toBe(true);
    expect(res.body.submission.status).toBe('submitted');
    expect(res.body.submission.moduleId).toBe('A');
    expect(res.body.submission.answers).toEqual(answers);

    const readback = await post('get-questionnaire-submission', patientToken, {
      submissionId: res.body.submission.id,
    }).expect(201);
    expect(readback.body.submission.answers).toEqual(answers);
  });

  it('returns the same submission on an idempotent retry', async () => {
    const first = await post('get-questionnaire-modules', patientToken, {}).expect(201);
    const a = (first.body.modules as Array<{ moduleId: string; submissionId?: string }>).find(
      (m) => m.moduleId === 'A',
    );
    expect(a?.submissionId).toBeDefined();

    const retry = await post('submit-questionnaire', patientToken, {
      moduleId: 'A',
      consentStatus: 'yes',
      submissionId: a!.submissionId,
      answers: syntheticAnswers(form('A')),
    }).expect(201);
    expect(retry.body.success).toBe(true);
    expect(retry.body.submission.id).toBe(a!.submissionId);
  });

  it('rejects a save based on a stale revision', async () => {
    const draft = await post('save-questionnaire-draft', patientToken, {
      moduleId: 'C',
      consentStatus: 'not_applicable',
      answers: {},
    }).expect(201);
    expect(draft.body.success).toBe(true);

    const stale = await post('save-questionnaire-draft', patientToken, {
      moduleId: 'C',
      submissionId: draft.body.submission.id,
      expectedUpdatedAt: '2000-01-01T00:00:00.000Z',
      answers: {},
    }).expect(201);
    expect(stale.body.success).toBe(false);
    expect(JSON.stringify(stale.body)).toContain('REVISION_CONFLICT');
  });

  it('submits a complete synthetic module B for a doctor', async () => {
    const res = await post('submit-questionnaire', doctorToken, {
      moduleId: 'B',
      answers: syntheticAnswers(form('B')),
    }).expect(201);
    expect(res.body.success).toBe(true);
    expect(res.body.submission.moduleId).toBe('B');
    expect(res.body.submission.respondentType).toBe('physician');
  });

  it('ignores archived v6.2 rows that share a module id', async () => {
    const legacy = await prisma.questionnaireSubmission.create({
      data: {
        userId: patientId,
        moduleId: 'C',
        moduleVersion: '6.2-kurz',
        respondentType: 'patient',
        status: 'SUBMITTED',
        consentStatus: 'YES',
        answers: { C_used_app: 'ja' },
        submittedAt: new Date(),
      },
    });

    const res = await post('get-questionnaire-submission', patientToken, { submissionId: legacy.id }).expect(201);
    expect(res.body.success).toBe(false);

    const modules = await post('get-questionnaire-modules', patientToken, {}).expect(201);
    const c = (modules.body.modules as Array<{ moduleId: string; hasSubmitted: boolean }>).find(
      (m) => m.moduleId === 'C',
    );
    expect(c?.hasSubmitted).toBe(false);
  });

  it('drops answers to hidden items on draft save', async () => {
    const formA = form('A');
    const items = formA.questionnaire.sections.flatMap((s) => s.items);
    const hidden = items.find((i) => i.visibilityRule && !evaluateVisibility(items, {}).has(i.id));
    expect(hidden).toBeDefined();

    const res = await post('save-questionnaire-draft', patientToken, {
      moduleId: 'A',
      answers: { [hidden!.id]: hidden!.options[0] },
    }).expect(201);
    expect(res.body.success).toBe(true);
    expect(res.body.submission.answers).not.toHaveProperty(hidden!.id);
  });

  it('refuses an update to an existing draft that carries no revision token', async () => {
    await prisma.questionnaireSubmission.deleteMany({
      where: { userId: patientId, moduleId: 'C', status: 'DRAFT' },
    });
    const draft = await post('save-questionnaire-draft', patientToken, {
      moduleId: 'C',
      consentStatus: 'not_applicable',
      answers: {},
    }).expect(201);
    expect(draft.body.success).toBe(true);

    const res = await post('save-questionnaire-draft', patientToken, {
      moduleId: 'C',
      submissionId: draft.body.submission.id,
      answers: {},
    }).expect(201);
    expect(res.body.success).toBe(false);
    expect(JSON.stringify(res.body)).toContain('REVISION_CONFLICT');
  });

  it('lets only one of two concurrent saves on the same revision succeed', async () => {
    await prisma.questionnaireSubmission.deleteMany({
      where: { userId: patientId, moduleId: 'C', status: 'DRAFT' },
    });
    const draft = await post('save-questionnaire-draft', patientToken, {
      moduleId: 'C',
      consentStatus: 'not_applicable',
      answers: {},
    }).expect(201);
    const { id, revision } = draft.body.submission as { id: string; revision: string };

    const [first, second] = await Promise.all(
      [1, 2].map(() =>
        post('save-questionnaire-draft', patientToken, {
          moduleId: 'C',
          submissionId: id,
          expectedUpdatedAt: revision,
          answers: {},
        }).expect(201),
      ),
    );
    const outcomes = [first.body.success, second.body.success].sort();
    expect(outcomes).toEqual([false, true]);
  });

  it('refuses to submit the follow-up, which is not assigned yet', async () => {
    const res = await post('submit-questionnaire', patientToken, {
      moduleId: 'CFU',
      consentStatus: 'yes',
      answers: {},
    }).expect(201);
    expect(res.body.success).toBe(false);
    expect(res.body.error).toBe('NOT_ASSIGNED');
  });

  it('does not finalise an archived v6.2 row through the submit path', async () => {
    const legacy = await prisma.questionnaireSubmission.create({
      data: {
        userId: patientId,
        moduleId: 'A',
        moduleVersion: '6.2-kurz',
        respondentType: 'patient',
        status: 'DRAFT',
        consentStatus: 'YES',
        answers: {},
      },
    });
    const res = await post('submit-questionnaire', patientToken, {
      moduleId: 'A',
      consentStatus: 'yes',
      submissionId: legacy.id,
      answers: syntheticAnswers(form('A')),
    }).expect(201);
    expect(res.body.success).toBe(false);
    const row = await prisma.questionnaireSubmission.findUnique({ where: { id: legacy.id } });
    expect(row?.status).toBe('DRAFT');
  });

  it('lets an allowlisted reviewer open and save the follow-up, but not a patient', async () => {
    const modules = await post('get-questionnaire-modules', reviewerToken, {}).expect(201);
    const cfu = (modules.body.modules as Array<{ moduleId: string; status: string }>).find(
      (m) => m.moduleId === 'CFU',
    );
    expect(cfu?.status).toBe('available');

    const def = await post('get-questionnaire-definition', reviewerToken, { moduleId: 'CFU' }).expect(201);
    expect(def.body.success).toBe(true);

    const save = await post('save-questionnaire-draft', reviewerToken, {
      moduleId: 'CFU',
      consentStatus: 'not_applicable',
      answers: {},
    }).expect(201);
    expect(save.body.success).toBe(true);

    const patientSave = await post('save-questionnaire-draft', patientToken, {
      moduleId: 'CFU',
      answers: {},
    }).expect(201);
    expect(patientSave.body.error).toBe('NOT_ASSIGNED');
  });
});
