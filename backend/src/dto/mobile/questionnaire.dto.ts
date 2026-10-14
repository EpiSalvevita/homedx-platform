import {
  IsIn,
  IsISO8601,
  IsObject,
  IsOptional,
  IsString,
  MinLength,
} from 'class-validator';

/** API keys for the RheumaCheck V04 forms. CFU is the optional follow-up. */
export const QUESTIONNAIRE_MODULE_IDS = ['A', 'B', 'C', 'CFU', 'D'] as const;

export class QuestionnaireModuleIdDto {
  @IsString()
  @IsIn(QUESTIONNAIRE_MODULE_IDS as unknown as string[])
  moduleId: string;
}

export class SaveQuestionnaireDraftDto extends QuestionnaireModuleIdDto {
  @IsObject()
  answers: Record<string, unknown>;

  @IsOptional()
  @IsString()
  @MinLength(1)
  submissionId?: string;

  @IsOptional()
  @IsString()
  linkedRapidTestId?: string;

  @IsOptional()
  @IsString()
  @IsIn(['yes', 'no', 'withdrawn', 'not_applicable'])
  consentStatus?: string;

  /** Revision the client last saw. A mismatch is rejected with REVISION_CONFLICT. */
  @IsOptional()
  @IsISO8601()
  expectedUpdatedAt?: string;
}

export class SubmitQuestionnaireDto extends SaveQuestionnaireDraftDto {}

export class GetQuestionnaireSubmissionDto {
  @IsOptional()
  @IsString()
  @MinLength(1)
  submissionId?: string;

  @IsOptional()
  @IsString()
  @IsIn(QUESTIONNAIRE_MODULE_IDS as unknown as string[])
  moduleId?: string;

  @IsOptional()
  @IsString()
  linkedRapidTestId?: string;
}

export class ExportQuestionnaireSubmissionsDto {
  @IsOptional()
  @IsString()
  @IsIn(QUESTIONNAIRE_MODULE_IDS as unknown as string[])
  moduleId?: string;
}
