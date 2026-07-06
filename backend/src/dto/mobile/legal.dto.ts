import { IsEnum, IsOptional, IsString } from 'class-validator';
import { LegalPageType } from '@prisma/client';

export class GetLegalPageDto {
  @IsEnum(LegalPageType)
  type: LegalPageType;

  @IsOptional()
  @IsString()
  language?: string;
}
