import { Field, InputType } from '@nestjs/graphql';
import { IsString, IsOptional, IsDate, IsEnum, IsUrl } from 'class-validator';
import { CertificateType, CertificateStatus } from './certificate.types';

@InputType()
export class CreateCertificateInput {
  @Field()
  @IsString()
  userId: string;

  @Field()
  @IsString()
  rapidTestId: string;

  @Field(() => CertificateType)
  @IsEnum(CertificateType)
  type: CertificateType;

  @Field(() => CertificateStatus, { nullable: true })
  @IsOptional()
  @IsEnum(CertificateStatus)
  status?: CertificateStatus;

  @Field()
  @IsString()
  certificateNumber: string;

  @Field()
  @IsDate()
  issuedAt: Date;

  @Field()
  @IsDate()
  validFrom: Date;

  @Field()
  @IsDate()
  validUntil: Date;

  @Field({ nullable: true })
  @IsOptional()
  @IsUrl()
  qrCodeUrl?: string;

  @Field({ nullable: true })
  @IsOptional()
  @IsUrl()
  pdfUrl?: string;
}

@InputType()
export class UpdateCertificateInput {
  @Field(() => CertificateType, { nullable: true })
  @IsOptional()
  @IsEnum(CertificateType)
  type?: CertificateType;

  @Field(() => CertificateStatus, { nullable: true })
  @IsOptional()
  @IsEnum(CertificateStatus)
  status?: CertificateStatus;

  @Field({ nullable: true })
  @IsOptional()
  @IsDate()
  issuedAt?: Date;

  @Field({ nullable: true })
  @IsOptional()
  @IsDate()
  validFrom?: Date;

  @Field({ nullable: true })
  @IsOptional()
  @IsDate()
  validUntil?: Date;

  @Field({ nullable: true })
  @IsOptional()
  @IsUrl()
  qrCodeUrl?: string;

  @Field({ nullable: true })
  @IsOptional()
  @IsUrl()
  pdfUrl?: string;

  @Field({ nullable: true })
  @IsOptional()
  @IsDate()
  revokedAt?: Date;

  @Field({ nullable: true })
  @IsOptional()
  @IsString()
  revokedReason?: string;
} 