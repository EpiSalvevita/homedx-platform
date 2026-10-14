import {
  BadRequestException,
  ConflictException,
  ForbiddenException,
  Injectable,
  Logger,
  NotFoundException,
} from '@nestjs/common';
import { readFileSync } from 'fs';
import { join } from 'path';
import {
  QuestionnaireConsentStatus,
  QuestionnaireSubmissionStatus,
} from '@prisma/client';
import { PrismaService } from './prisma.service';
import { AuditLogService } from './audit-log.service';
import { buildForms, V04ApiModuleId, V04Form, V04Role } from '../utils/questionnaire-forms';
import {
  V04Package,
  validateAnswers,
  V04ValidationIssue,
} from '../utils/questionnaire-v04-engine';

const CATALOGUE_FILE = 'rheumacheck_questionnaires_v04.public.json';

/**
 * Rows written by this catalogue carry this prefix in moduleVersion. Rows from the
 * previous v6.2 catalogue share moduleIds (A/B/C/D) but not the prefix, so every
 * lookup below excludes them. They stay in the database as archive.
 */
export const QUESTIONNAIRE_VERSION_PREFIX = 'v04:';

const ALLOWED_MODULE_IDS: V04ApiModuleId[] = ['A', 'B', 'C', 'CFU', 'D'];

export interface QuestionnaireModuleSummary {
  moduleId: V04ApiModuleId;
  catalogueId: string;
  title: string;
  targetGroup: string;
  timing?: string;
  moduleVersion: string;
  status: 'not_assigned' | 'available' | 'in_progress' | 'completed';
  hasDraft: boolean;
  hasSubmitted: boolean;
  submissionId?: string;
}

export interface QuestionnaireSubmissionItem {
  id: string;
  moduleId: string;
  moduleVersion: string;
  respondentType: string;
  status: string;
  consentStatus: string;
  language: string;
  answers: Record<string, unknown>;
  linkedRapidTestId: string | null;
  submittedAt: string | null;
  createdAt: string;
  updatedAt: string;
  /** Concurrency token: pass back as expectedUpdatedAt when saving again. */
  revision: string;
}

@Injectable()
export class QuestionnaireService {
  private readonly logger = new Logger(QuestionnaireService.name);
  private forms: V04Form[] | null = null;
  private packageVersion = '';
  private language = 'de-DE';
  private packageStatus = '';

  constructor(
    private readonly prisma: PrismaService,
    private readonly auditLogService: AuditLogService,
  ) {}

  private loadForms(): V04Form[] {
    if (this.forms) return this.forms;
    const candidates = [
      join(process.cwd(), 'data', 'questionnaires', CATALOGUE_FILE),
      join(__dirname, '..', 'data', 'questionnaires', CATALOGUE_FILE),
    ];
    let raw: string | null = null;
    for (const path of candidates) {
      try {
        raw = readFileSync(path, 'utf8');
        break;
      } catch {
        // try next path
      }
    }
    if (!raw) {
      throw new Error('Questionnaire catalogue file not found');
    }
    const pkg = JSON.parse(raw) as V04Package;
    this.forms = buildForms(pkg);
    this.packageVersion = pkg.packageVersion;
    this.language = pkg.locale;
    this.packageStatus = pkg.status;
    return this.forms;
  }

  private get currentVersion(): string {
    this.loadForms();
    return `${QUESTIONNAIRE_VERSION_PREFIX}${this.packageVersion}`;
  }

  getPackageMeta() {
    this.loadForms();
    return {
      packageVersion: this.packageVersion,
      language: this.language,
      status: this.packageStatus,
    };
  }

  private formsForRole(role: string): V04Form[] {
    const wanted: V04Role = role === 'DOCTOR' ? 'professional' : 'patient';
    return this.loadForms().filter((f) => f.role === wanted);
  }

  /** Resolves a module for the caller's role. Unknown or wrong-role modules are refused. */
  private formFor(moduleId: string, role: string): V04Form {
    if (!ALLOWED_MODULE_IDS.includes(moduleId as V04ApiModuleId)) {
      throw new NotFoundException(`Questionnaire module ${moduleId} not found`);
    }
    const form = this.loadForms().find((f) => f.moduleId === moduleId);
    if (!form) {
      throw new NotFoundException(`Questionnaire module ${moduleId} not found`);
    }
    const isDoctor = role === 'DOCTOR';
    if (form.role === 'patient' && isDoctor) {
      throw new ForbiddenException('This questionnaire is for patients only');
    }
    if (form.role === 'professional' && !isDoctor) {
      throw new ForbiddenException('This questionnaire is for physicians only');
    }
    return form;
  }

  /**
   * Internal reviewers are listed in QUESTIONNAIRE_REVIEWER_USER_IDS (comma-separated user ids).
   * Only they may open the follow-up before an invitation mechanism exists.
   */
  isReviewer(userId: string): boolean {
    const raw = process.env.QUESTIONNAIRE_REVIEWER_USER_IDS ?? '';
    return raw
      .split(',')
      .map((id) => id.trim())
      .filter((id) => id.length > 0)
      .includes(userId);
  }

  /** Follow-up has no invitation mechanism yet: only reviewers may answer it. */
  private assertAssigned(form: V04Form, userId: string) {
    if (form.moduleId === 'CFU' && !this.isReviewer(userId)) {
      throw new ForbiddenException('NOT_ASSIGNED');
    }
  }

  private respondentTypeFor(form: V04Form): string {
    return form.role === 'patient' ? 'patient' : 'physician';
  }

  private mapConsentStatus(value?: string): QuestionnaireConsentStatus {
    switch (value) {
      case 'yes':
        return QuestionnaireConsentStatus.YES;
      case 'no':
        return QuestionnaireConsentStatus.NO;
      case 'withdrawn':
        return QuestionnaireConsentStatus.WITHDRAWN;
      default:
        return QuestionnaireConsentStatus.NOT_APPLICABLE;
    }
  }

  private toItem(row: {
    id: string;
    moduleId: string;
    moduleVersion: string;
    respondentType: string;
    status: QuestionnaireSubmissionStatus;
    consentStatus: QuestionnaireConsentStatus;
    language: string;
    answers: unknown;
    linkedRapidTestId: string | null;
    submittedAt: Date | null;
    createdAt: Date;
    updatedAt: Date;
  }): QuestionnaireSubmissionItem {
    return {
      id: row.id,
      moduleId: row.moduleId,
      moduleVersion: row.moduleVersion,
      respondentType: row.respondentType,
      status: row.status.toLowerCase(),
      consentStatus: row.consentStatus.toLowerCase(),
      language: row.language,
      answers: (row.answers as Record<string, unknown>) ?? {},
      linkedRapidTestId: row.linkedRapidTestId,
      submittedAt: row.submittedAt?.toISOString() ?? null,
      createdAt: row.createdAt.toISOString(),
      updatedAt: row.updatedAt.toISOString(),
      revision: row.updatedAt.toISOString(),
    };
  }

  /** Item ids and codes only, never the answer values. Surfaces as the response's validation list. */
  private issueMessages(issues: V04ValidationIssue[]): string[] {
    return issues.map((i) => `${i.itemId}:${i.code}`);
  }

  async listModules(userId: string, role: string): Promise<QuestionnaireModuleSummary[]> {
    const version = this.currentVersion;
    const forms = this.formsForRole(role);
    const reviewer = this.isReviewer(userId);

    const existing = await this.prisma.questionnaireSubmission.findMany({
      where: { userId, moduleVersion: { startsWith: QUESTIONNAIRE_VERSION_PREFIX } },
      orderBy: { updatedAt: 'desc' },
    });

    return forms.map((form) => {
      const rows = existing.filter((e) => e.moduleId === form.moduleId);
      const draft = rows.find((r) => r.status === QuestionnaireSubmissionStatus.DRAFT);
      const submitted = rows.find((r) => r.status === QuestionnaireSubmissionStatus.SUBMITTED);
      let status: QuestionnaireModuleSummary['status'] = 'available';
      if (form.moduleId === 'CFU' && !reviewer) status = 'not_assigned';
      else if (submitted) status = 'completed';
      else if (draft) status = 'in_progress';
      return {
        moduleId: form.moduleId,
        catalogueId: form.catalogueId,
        title: form.questionnaire.title,
        targetGroup: form.questionnaire.audience,
        timing: form.questionnaire.estimatedTime,
        moduleVersion: version,
        status,
        hasDraft: !!draft,
        hasSubmitted: !!submitted,
        submissionId: draft?.id ?? submitted?.id,
      };
    });
  }

  getDefinition(moduleId: string, role: string, userId: string) {
    const form = this.formFor(moduleId, role);
    this.assertAssigned(form, userId);
    this.loadForms();
    return {
      packageVersion: this.packageVersion,
      language: this.language,
      module: {
        moduleId: form.moduleId,
        catalogueId: form.catalogueId,
        ...form.questionnaire,
      },
    };
  }

  async saveDraft(params: {
    userId: string;
    role: string;
    moduleId: string;
    answers: Record<string, unknown>;
    submissionId?: string;
    linkedRapidTestId?: string;
    consentStatus?: string;
    expectedUpdatedAt?: string;
  }) {
    const form = this.formFor(params.moduleId, params.role);
    this.assertAssigned(form, params.userId);

    const result = validateAnswers(form.questionnaire, params.answers, { strict: false });
    if (!result.ok) {
      throw new BadRequestException(this.issueMessages(result.issues));
    }
    const answers = result.cleanAnswers;

    if (params.linkedRapidTestId) {
      const test = await this.prisma.rapidTest.findUnique({
        where: { id: params.linkedRapidTestId },
      });
      if (!test || test.userId !== params.userId) {
        throw new ForbiddenException('Linked rapid test not found');
      }
      const existingSubmitted = await this.prisma.questionnaireSubmission.findFirst({
        where: {
          userId: params.userId,
          moduleId: params.moduleId,
          moduleVersion: this.currentVersion,
          linkedRapidTestId: params.linkedRapidTestId,
          status: QuestionnaireSubmissionStatus.SUBMITTED,
        },
      });
      if (existingSubmitted && existingSubmitted.id !== params.submissionId) {
        throw new BadRequestException('A submission already exists for this test');
      }
    }

    const consent = this.mapConsentStatus(params.consentStatus);
    const respondentType = this.respondentTypeFor(form);
    const moduleVersion = this.currentVersion;

    if (params.submissionId) {
      const existing = await this.prisma.questionnaireSubmission.findUnique({
        where: { id: params.submissionId },
      });
      if (!existing || existing.userId !== params.userId || existing.moduleVersion !== moduleVersion) {
        throw new NotFoundException('Draft not found');
      }
      if (existing.status !== QuestionnaireSubmissionStatus.DRAFT) {
        throw new BadRequestException('Submission is already finalized');
      }
      const updated = await this.updateDraftAtRevision(params.submissionId, params.expectedUpdatedAt, {
        answers: answers as object,
        consentStatus: consent,
        linkedRapidTestId: params.linkedRapidTestId ?? existing.linkedRapidTestId,
        moduleVersion,
        respondentType,
      });
      return this.toItem(updated);
    }

    const existingDraft = await this.prisma.questionnaireSubmission.findFirst({
      where: {
        userId: params.userId,
        moduleId: params.moduleId,
        moduleVersion,
        status: QuestionnaireSubmissionStatus.DRAFT,
        linkedRapidTestId: params.linkedRapidTestId ?? null,
      },
    });
    if (existingDraft) {
      const updated = await this.updateDraftAtRevision(existingDraft.id, params.expectedUpdatedAt, {
        answers: answers as object,
        consentStatus: consent,
        respondentType,
      });
      return this.toItem(updated);
    }

    const created = await this.prisma.questionnaireSubmission.create({
      data: {
        userId: params.userId,
        moduleId: params.moduleId,
        moduleVersion,
        respondentType,
        status: QuestionnaireSubmissionStatus.DRAFT,
        consentStatus: consent,
        language: this.language,
        answers: answers as object,
        linkedRapidTestId: params.linkedRapidTestId,
      },
    });
    return this.toItem(created);
  }

  /**
   * Writes a draft only if it is still a DRAFT at the revision the client based its save on.
   * The condition is part of the UPDATE, so two concurrent saves cannot both succeed.
   * A missing token is refused for existing rows: an unknown base must not overwrite.
   */
  private async updateDraftAtRevision(
    id: string,
    expectedUpdatedAt: string | undefined,
    data: Record<string, unknown>,
  ) {
    if (!expectedUpdatedAt) {
      throw new ConflictException('REVISION_CONFLICT');
    }
    const result = await this.prisma.questionnaireSubmission.updateMany({
      where: {
        id,
        status: QuestionnaireSubmissionStatus.DRAFT,
        updatedAt: new Date(expectedUpdatedAt),
      },
      data,
    });
    if (result.count === 0) {
      throw new ConflictException('REVISION_CONFLICT');
    }
    return this.prisma.questionnaireSubmission.findUniqueOrThrow({ where: { id } });
  }

  async submit(params: {
    userId: string;
    role: string;
    moduleId: string;
    answers: Record<string, unknown>;
    submissionId?: string;
    linkedRapidTestId?: string;
    consentStatus?: string;
    expectedUpdatedAt?: string;
  }) {
    const form = this.formFor(params.moduleId, params.role);
    this.assertAssigned(form, params.userId);

    // Idempotent retry: an already submitted row is returned unchanged.
    if (params.submissionId) {
      const row = await this.prisma.questionnaireSubmission.findUnique({
        where: { id: params.submissionId },
      });
      if (
        row &&
        row.userId === params.userId &&
        row.moduleId === params.moduleId &&
        row.moduleVersion === this.currentVersion &&
        row.status === QuestionnaireSubmissionStatus.SUBMITTED
      ) {
        return this.toItem(row);
      }
    }

    if (form.role === 'patient' && params.consentStatus !== 'yes') {
      throw new BadRequestException('CONSENT_REQUIRED');
    }

    const strict = validateAnswers(form.questionnaire, params.answers, { strict: true });
    if (!strict.ok) {
      throw new BadRequestException(this.issueMessages(strict.issues));
    }

    // Finalize only at the revision this save produced. A save in between would
    // change the answers after validation, so it is refused as a conflict.
    const draft = await this.saveDraft(params);
    const updated = await this.updateDraftAtRevision(draft.id, draft.revision, {
      status: QuestionnaireSubmissionStatus.SUBMITTED,
      submittedAt: new Date(),
    });

    try {
      await this.auditLogService.create({
        userId: params.userId,
        action: 'CREATE',
        entityType: 'QUESTIONNAIRE_SUBMISSION',
        entityId: updated.id,
        description: `Questionnaire ${updated.moduleId} ${updated.moduleVersion} submitted`,
        newValues: JSON.stringify({
          moduleId: updated.moduleId,
          moduleVersion: updated.moduleVersion,
          status: updated.status,
        }),
      });
    } catch (err) {
      this.logger.warn(`Audit log failed for questionnaire ${updated.id}: ${err}`);
    }

    return this.toItem(updated);
  }

  async getSubmission(params: {
    userId: string;
    role: string;
    submissionId?: string;
    moduleId?: string;
    linkedRapidTestId?: string;
  }) {
    const version = this.currentVersion;

    if (params.submissionId) {
      const row = await this.prisma.questionnaireSubmission.findUnique({
        where: { id: params.submissionId },
      });
      if (!row || row.userId !== params.userId || row.moduleVersion !== version) {
        throw new NotFoundException('Submission not found');
      }
      this.formFor(row.moduleId, params.role);
      return this.toItem(row);
    }

    if (!params.moduleId) {
      throw new BadRequestException('moduleId or submissionId required');
    }
    this.formFor(params.moduleId, params.role);

    const row = await this.prisma.questionnaireSubmission.findFirst({
      where: {
        userId: params.userId,
        moduleId: params.moduleId,
        moduleVersion: version,
        linkedRapidTestId: params.linkedRapidTestId ?? null,
      },
      orderBy: { updatedAt: 'desc' },
    });
    if (!row) {
      throw new NotFoundException('Submission not found');
    }
    return this.toItem(row);
  }

  /** Admin export of submissions under the current catalogue. Archived v6.2 rows are excluded. */
  async exportSubmissions(moduleId?: string) {
    const rows = await this.prisma.questionnaireSubmission.findMany({
      where: {
        status: QuestionnaireSubmissionStatus.SUBMITTED,
        moduleVersion: { startsWith: QUESTIONNAIRE_VERSION_PREFIX },
        ...(moduleId ? { moduleId } : {}),
      },
      orderBy: { submittedAt: 'desc' },
      select: {
        id: true,
        userId: true,
        moduleId: true,
        moduleVersion: true,
        respondentType: true,
        consentStatus: true,
        language: true,
        answers: true,
        linkedRapidTestId: true,
        submittedAt: true,
        createdAt: true,
      },
    });

    return rows.map((r) => ({
      id: r.id,
      userId: r.userId,
      moduleId: r.moduleId,
      moduleVersion: r.moduleVersion,
      respondentType: r.respondentType,
      consentStatus: r.consentStatus.toLowerCase(),
      language: r.language,
      answers: r.answers,
      linkedRapidTestId: r.linkedRapidTestId,
      submittedAt: r.submittedAt?.toISOString() ?? null,
      createdAt: r.createdAt.toISOString(),
    }));
  }
}
