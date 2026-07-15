import {
  BadRequestException,
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
import {
  QuestionnaireModuleDef,
  QuestionnairePackageDef,
  formDepthFromAnswers,
  validateAnswersForModule,
} from '../utils/questionnaire-branching';

const PATIENT_MODULES = new Set(['A', 'C']);
const DOCTOR_MODULES = new Set(['B', 'D']);

export interface QuestionnaireModuleSummary {
  moduleId: string;
  title: string;
  targetGroup: string;
  timing?: string;
  purpose?: string;
  moduleVersion: string;
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
}

@Injectable()
export class QuestionnaireService {
  private readonly logger = new Logger(QuestionnaireService.name);
  private packageDef: QuestionnairePackageDef | null = null;

  constructor(
    private readonly prisma: PrismaService,
    private readonly auditLogService: AuditLogService,
  ) {}

  private loadPackage(): QuestionnairePackageDef {
    if (this.packageDef) return this.packageDef;
    const candidates = [
      join(process.cwd(), 'data', 'questionnaires', 'rheumacheck_questionnaires_v6_2.forms.json'),
      join(__dirname, '..', 'data', 'questionnaires', 'rheumacheck_questionnaires_v6_2.forms.json'),
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
      throw new Error('Questionnaire definition file not found');
    }
    this.packageDef = JSON.parse(raw) as QuestionnairePackageDef;
    return this.packageDef;
  }

  getPackageMeta() {
    const pkg = this.loadPackage();
    return {
      project: pkg.project,
      packageVersion: pkg.package_version,
      language: pkg.language,
      formDepths: pkg.form_depths ?? ['kurz', 'voll'],
      defaultFormDepth: pkg.default_form_depth ?? 'kurz',
    };
  }

  private moduleVersionForAnswers(
    packageVersion: string,
    answers: Record<string, unknown>,
  ): string {
    return `${packageVersion}-${formDepthFromAnswers(answers)}`;
  }

  private getModule(moduleId: string): QuestionnaireModuleDef {
    const pkg = this.loadPackage();
    const module = pkg.modules.find((m) => m.module_id === moduleId);
    if (!module) {
      throw new NotFoundException(`Questionnaire module ${moduleId} not found`);
    }
    return module;
  }

  assertModuleAllowedForRole(moduleId: string, role: string) {
    const isDoctor = role === 'DOCTOR';
    if (PATIENT_MODULES.has(moduleId) && isDoctor) {
      throw new ForbiddenException('This questionnaire is for patients only');
    }
    if (DOCTOR_MODULES.has(moduleId) && !isDoctor) {
      throw new ForbiddenException('This questionnaire is for physicians only');
    }
  }

  private resolveRespondentType(moduleId: string, role: string): string {
    if (moduleId === 'A' || moduleId === 'C') return 'patient';
    if (role === 'DOCTOR') return 'physician';
    return 'test_user';
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
    };
  }

  async listModules(userId: string, role: string): Promise<QuestionnaireModuleSummary[]> {
    const pkg = this.loadPackage();
    const isDoctor = role === 'DOCTOR';
    const allowed = pkg.modules.filter((m) =>
      isDoctor ? DOCTOR_MODULES.has(m.module_id) : PATIENT_MODULES.has(m.module_id),
    );

    const existing = await this.prisma.questionnaireSubmission.findMany({
      where: { userId },
      orderBy: { updatedAt: 'desc' },
    });

    return allowed.map((m) => {
      const rows = existing.filter((e) => e.moduleId === m.module_id);
      const draft = rows.find((r) => r.status === QuestionnaireSubmissionStatus.DRAFT);
      const submitted = rows.find((r) => r.status === QuestionnaireSubmissionStatus.SUBMITTED);
      return {
        moduleId: m.module_id,
        title: m.title,
        targetGroup: m.target_group,
        timing: m.timing,
        purpose: m.purpose,
        moduleVersion: pkg.package_version,
        hasDraft: !!draft,
        hasSubmitted: !!submitted,
        submissionId: draft?.id ?? submitted?.id,
      };
    });
  }

  getDefinition(moduleId: string, role: string) {
    this.assertModuleAllowedForRole(moduleId, role);
    const pkg = this.loadPackage();
    const module = this.getModule(moduleId);
    return {
      packageVersion: pkg.package_version,
      language: pkg.language,
      module,
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
  }) {
    this.assertModuleAllowedForRole(params.moduleId, params.role);
    const pkg = this.loadPackage();
    const module = this.getModule(params.moduleId);

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
          linkedRapidTestId: params.linkedRapidTestId,
          status: QuestionnaireSubmissionStatus.SUBMITTED,
        },
      });
      if (existingSubmitted && existingSubmitted.id !== params.submissionId) {
        throw new BadRequestException('A submission already exists for this test');
      }
    }

    const consent = this.mapConsentStatus(params.consentStatus);
    const respondentType = this.resolveRespondentType(params.moduleId, params.role);
    const moduleVersion = this.moduleVersionForAnswers(
      pkg.package_version,
      params.answers,
    );

    if (params.submissionId) {
      const existing = await this.prisma.questionnaireSubmission.findUnique({
        where: { id: params.submissionId },
      });
      if (!existing || existing.userId !== params.userId) {
        throw new NotFoundException('Draft not found');
      }
      if (existing.status !== QuestionnaireSubmissionStatus.DRAFT) {
        throw new BadRequestException('Submission is already finalized');
      }
      const updated = await this.prisma.questionnaireSubmission.update({
        where: { id: params.submissionId },
        data: {
          answers: params.answers as object,
          consentStatus: consent,
          linkedRapidTestId: params.linkedRapidTestId ?? existing.linkedRapidTestId,
          moduleVersion,
          respondentType,
        },
      });
      return this.toItem(updated);
    }

    const existingDraft = await this.prisma.questionnaireSubmission.findFirst({
      where: {
        userId: params.userId,
        moduleId: params.moduleId,
        status: QuestionnaireSubmissionStatus.DRAFT,
        linkedRapidTestId: params.linkedRapidTestId ?? null,
      },
    });
    if (existingDraft) {
      const updated = await this.prisma.questionnaireSubmission.update({
        where: { id: existingDraft.id },
        data: {
          answers: params.answers as object,
          consentStatus: consent,
          moduleVersion,
          respondentType,
        },
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
        language: pkg.language,
        answers: params.answers as object,
        linkedRapidTestId: params.linkedRapidTestId,
      },
    });
    return this.toItem(created);
  }

  async submit(params: {
    userId: string;
    role: string;
    moduleId: string;
    answers: Record<string, unknown>;
    submissionId?: string;
    linkedRapidTestId?: string;
    consentStatus?: string;
  }) {
    this.assertModuleAllowedForRole(params.moduleId, params.role);
    const module = this.getModule(params.moduleId);
    const validationErrors = validateAnswersForModule(module, params.answers);
    if (validationErrors.length > 0) {
      throw new BadRequestException(validationErrors.join('; '));
    }

    const draft = await this.saveDraft(params);
    const updated = await this.prisma.questionnaireSubmission.update({
      where: { id: draft.id },
      data: {
        status: QuestionnaireSubmissionStatus.SUBMITTED,
        submittedAt: new Date(),
      },
    });

    try {
      await this.auditLogService.create({
        userId: params.userId,
        action: 'CREATE',
        entityType: 'QUESTIONNAIRE_SUBMISSION',
        entityId: updated.id,
        description: `Questionnaire ${updated.moduleId} v${updated.moduleVersion} submitted`,
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
    if (params.submissionId) {
      const row = await this.prisma.questionnaireSubmission.findUnique({
        where: { id: params.submissionId },
      });
      if (!row || row.userId !== params.userId) {
        throw new NotFoundException('Submission not found');
      }
      this.assertModuleAllowedForRole(row.moduleId, params.role);
      return this.toItem(row);
    }

    if (!params.moduleId) {
      throw new BadRequestException('moduleId or submissionId required');
    }
    this.assertModuleAllowedForRole(params.moduleId, params.role);

    const row = await this.prisma.questionnaireSubmission.findFirst({
      where: {
        userId: params.userId,
        moduleId: params.moduleId,
        linkedRapidTestId: params.linkedRapidTestId ?? null,
      },
      orderBy: { updatedAt: 'desc' },
    });
    if (!row) {
      throw new NotFoundException('Submission not found');
    }
    return this.toItem(row);
  }

  async exportSubmissions(moduleId?: string) {
    const rows = await this.prisma.questionnaireSubmission.findMany({
      where: {
        status: QuestionnaireSubmissionStatus.SUBMITTED,
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
