import {
  IsIn,
  IsObject,
  IsOptional,
  IsString,
  MinLength,
} from 'class-validator';

export class QuestionnaireModuleIdDto {
  @IsString()
  @IsIn(['A', 'B', 'C', 'D'])
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
}

export class SubmitQuestionnaireDto extends SaveQuestionnaireDraftDto {}

export class GetQuestionnaireSubmissionDto {
  @IsOptional()
  @IsString()
  @MinLength(1)
  submissionId?: string;

  @IsOptional()
  @IsString()
  @IsIn(['A', 'B', 'C', 'D'])
  moduleId?: string;

  @IsOptional()
  @IsString()
  linkedRapidTestId?: string;
}

export class ExportQuestionnaireSubmissionsDto {
  @IsOptional()
  @IsString()
  @IsIn(['A', 'B', 'C', 'D'])
  moduleId?: string;
}
