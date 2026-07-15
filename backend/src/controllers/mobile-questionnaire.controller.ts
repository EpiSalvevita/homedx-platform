import { Body, Controller, Post, Request, UseGuards } from '@nestjs/common';
import { JwtAuthGuard } from '../auth/jwt-auth.guard';
import { RolesGuard } from '../auth/roles.guard';
import { Roles } from '../auth/roles.decorator';
import {
  ExportQuestionnaireSubmissionsDto,
  GetQuestionnaireSubmissionDto,
  QuestionnaireModuleIdDto,
  SaveQuestionnaireDraftDto,
  SubmitQuestionnaireDto,
} from '../dto/mobile/questionnaire.dto';
import { QuestionnaireService } from '../services/questionnaire.service';
import { sanitizeMobileError } from '../util/mobile-error.util';
import { MobileUserHelper } from './mobile-user.helper';
import { MOBILE_API_PATH, MobileResponse } from './mobile.types';

interface QuestionnaireModulesResponse extends MobileResponse {
  modules?: object[];
  packageVersion?: string;
}

interface QuestionnaireDefinitionResponse extends MobileResponse {
  definition?: object;
  packageVersion?: string;
  language?: string;
}

interface QuestionnaireSubmissionResponse extends MobileResponse {
  submission?: object;
}

interface QuestionnaireExportResponse extends MobileResponse {
  submissions?: object[];
}

@Controller(MOBILE_API_PATH)
export class MobileQuestionnaireController {
  constructor(
    private readonly questionnaireService: QuestionnaireService,
    private readonly mobileUserHelper: MobileUserHelper,
  ) {}

  @Post('get-questionnaire-modules')
  @UseGuards(JwtAuthGuard)
  async getModules(
    @Request() req: { user?: { sub: string } },
  ): Promise<QuestionnaireModulesResponse> {
    try {
      const userId = req.user?.sub;
      if (!userId) return { success: false, error: 'Invalid token' };
      const role = await this.mobileUserHelper.resolveUserRole(userId);
      const modules = await this.questionnaireService.listModules(userId, role);
      const meta = this.questionnaireService.getPackageMeta();
      return { success: true, modules, packageVersion: meta.packageVersion };
    } catch (error) {
      return sanitizeMobileError(error, 'Failed to list questionnaire modules');
    }
  }

  @Post('get-questionnaire-definition')
  @UseGuards(JwtAuthGuard)
  async getDefinition(
    @Request() req: { user?: { sub: string } },
    @Body() body: QuestionnaireModuleIdDto,
  ): Promise<QuestionnaireDefinitionResponse> {
    try {
      const userId = req.user?.sub;
      if (!userId) return { success: false, error: 'Invalid token' };
      const role = await this.mobileUserHelper.resolveUserRole(userId);
      const def = this.questionnaireService.getDefinition(body.moduleId, role);
      return {
        success: true,
        definition: def.module,
        packageVersion: def.packageVersion,
        language: def.language,
      };
    } catch (error) {
      return sanitizeMobileError(error, 'Failed to get questionnaire definition');
    }
  }

  @Post('save-questionnaire-draft')
  @UseGuards(JwtAuthGuard)
  async saveDraft(
    @Request() req: { user?: { sub: string } },
    @Body() body: SaveQuestionnaireDraftDto,
  ): Promise<QuestionnaireSubmissionResponse> {
    try {
      const userId = req.user?.sub;
      if (!userId) return { success: false, error: 'Invalid token' };
      const role = await this.mobileUserHelper.resolveUserRole(userId);
      const submission = await this.questionnaireService.saveDraft({
        userId,
        role,
        moduleId: body.moduleId,
        answers: body.answers,
        submissionId: body.submissionId,
        linkedRapidTestId: body.linkedRapidTestId,
        consentStatus: body.consentStatus,
      });
      return { success: true, submission };
    } catch (error) {
      return sanitizeMobileError(error, 'Failed to save questionnaire draft');
    }
  }

  @Post('submit-questionnaire')
  @UseGuards(JwtAuthGuard)
  async submit(
    @Request() req: { user?: { sub: string } },
    @Body() body: SubmitQuestionnaireDto,
  ): Promise<QuestionnaireSubmissionResponse> {
    try {
      const userId = req.user?.sub;
      if (!userId) return { success: false, error: 'Invalid token' };
      const role = await this.mobileUserHelper.resolveUserRole(userId);
      const submission = await this.questionnaireService.submit({
        userId,
        role,
        moduleId: body.moduleId,
        answers: body.answers,
        submissionId: body.submissionId,
        linkedRapidTestId: body.linkedRapidTestId,
        consentStatus: body.consentStatus,
      });
      return { success: true, submission };
    } catch (error) {
      return sanitizeMobileError(error, 'Failed to submit questionnaire');
    }
  }

  @Post('get-questionnaire-submission')
  @UseGuards(JwtAuthGuard)
  async getSubmission(
    @Request() req: { user?: { sub: string } },
    @Body() body: GetQuestionnaireSubmissionDto,
  ): Promise<QuestionnaireSubmissionResponse> {
    try {
      const userId = req.user?.sub;
      if (!userId) return { success: false, error: 'Invalid token' };
      const role = await this.mobileUserHelper.resolveUserRole(userId);
      const submission = await this.questionnaireService.getSubmission({
        userId,
        role,
        submissionId: body.submissionId,
        moduleId: body.moduleId,
        linkedRapidTestId: body.linkedRapidTestId,
      });
      return { success: true, submission };
    } catch (error) {
      return sanitizeMobileError(error, 'Failed to get questionnaire submission');
    }
  }

  @Post('export-questionnaire-submissions')
  @UseGuards(JwtAuthGuard, RolesGuard)
  @Roles('ADMIN')
  async exportSubmissions(
    @Body() body: ExportQuestionnaireSubmissionsDto,
  ): Promise<QuestionnaireExportResponse> {
    try {
      const submissions = await this.questionnaireService.exportSubmissions(body.moduleId);
      return { success: true, submissions };
    } catch (error) {
      return sanitizeMobileError(error, 'Failed to export questionnaire submissions');
    }
  }
}
