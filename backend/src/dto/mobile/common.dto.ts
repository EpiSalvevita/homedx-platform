import { IsOptional, IsString } from 'class-validator';

export class LangBodyDto {
  @IsOptional()
  @IsString()
  lang?: string;
}

export class EmptyBodyDto extends LangBodyDto {}
