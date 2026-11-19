import { Type } from 'class-transformer';
import {
  IsArray,
  IsBoolean,
  IsNumber,
  IsOptional,
  IsString,
  MinLength,
  ValidateNested,
} from 'class-validator';
import { LangBodyDto } from './common.dto';

export class AddTestDto extends LangBodyDto {
  @IsString()
  @MinLength(1)
  testTypeId: string;
}

export class CubeResultDataItemDto {
  @IsOptional()
  @IsString()
  name?: string;

  @IsOptional()
  @IsString()
  value?: string;

  @IsOptional()
  @IsString()
  unit?: string;

  @IsOptional()
  @IsString()
  class?: string;

  @IsOptional()
  @IsNumber()
  validity?: number;
}

export class SubmitCubeDataDto {
  @IsString()
  @MinLength(1)
  testTypeId: string;

  @IsOptional()
  @IsString()
  rapidTestId?: string;

  @IsOptional()
  @IsArray()
  rawData?: number[];

  @IsOptional()
  @IsString()
  deviceSerial?: string;

  @IsOptional()
  @IsNumber()
  measurementTimestamp?: number;

  @IsOptional()
  @IsString()
  result?: string;

  @IsOptional()
  @IsArray()
  @ValidateNested({ each: true })
  @Type(() => CubeResultDataItemDto)
  resultData?: CubeResultDataItemDto[];
}

export class FinalizeTestDto {
  @IsString()
  @MinLength(1)
  rapidTestId: string;

  @IsBoolean()
  agreementGiven: boolean;
}

export class RapidTestMediaUploadDto {
  /** Ignored: the stored extension is derived from the detected file type. */
  @IsOptional()
  @IsString()
  fileExtension?: string;

  @IsString()
  @MinLength(1)
  rapidTestId: string;
}

export class IdentificationPhotoUploadDto extends RapidTestMediaUploadDto {
  @IsString()
  @MinLength(1)
  type: string;
}
