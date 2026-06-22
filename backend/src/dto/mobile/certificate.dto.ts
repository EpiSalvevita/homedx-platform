import { IsString, MinLength } from 'class-validator';

export class CertificateIdDto {
  @IsString()
  @MinLength(1)
  certificateId: string;
}
