import { Field, ObjectType, registerEnumType } from '@nestjs/graphql';
import { User } from './user.type';
import { RapidTest } from './rapid-test.type';

export enum CertificateType {
  TEST_RESULT = 'TEST_RESULT',
  VACCINATION = 'VACCINATION',
  RECOVERY = 'RECOVERY',
  MEDICAL_CLEARANCE = 'MEDICAL_CLEARANCE'
}

export enum CertificateStatus {
  DRAFT = 'DRAFT',
  ISSUED = 'ISSUED',
  EXPIRED = 'EXPIRED',
  REVOKED = 'REVOKED'
}

registerEnumType(CertificateType, {
  name: 'CertificateType',
  description: 'Certificate type enumeration',
});

registerEnumType(CertificateStatus, {
  name: 'CertificateStatus',
  description: 'Certificate status enumeration',
});

@ObjectType()
export class Certificate {
  @Field()
  id: string;

  @Field()
  userId: string;

  @Field()
  rapidTestId: string;

  @Field(() => CertificateType)
  type: CertificateType;

  @Field(() => CertificateStatus)
  status: CertificateStatus;

  @Field()
  certificateNumber: string;

  @Field()
  issuedAt: Date;

  @Field()
  validFrom: Date;

  @Field()
  validUntil: Date;

  @Field({ nullable: true })
  qrCodeUrl?: string;

  @Field({ nullable: true })
  pdfUrl?: string;

  @Field({ nullable: true })
  revokedAt?: Date;

  @Field({ nullable: true })
  revokedReason?: string;

  @Field()
  createdAt: Date;

  @Field()
  updatedAt: Date;

  // Relations
  @Field(() => User)
  user: User;

  @Field(() => RapidTest)
  rapidTest: RapidTest;
}

@ObjectType()
export class CertificatePdf {
  @Field()
  url: string;

  @Field()
  language: string;
}

@ObjectType()
export class CertificateWithPdf {
  @Field()
  id: string;

  @Field(() => CertificatePdf, { nullable: true })
  pdf?: CertificatePdf;
}

@ObjectType()
export class UpdateCertificateLanguageResponse {
  @Field()
  success: boolean;

  @Field(() => CertificateWithPdf, { nullable: true })
  certificate?: CertificateWithPdf;

  @Field({ nullable: true })
  message?: string;
}

@ObjectType()
export class DownloadCertificatePdfResponse {
  @Field()
  success: boolean;

  @Field({ nullable: true })
  pdf?: string;

  @Field({ nullable: true })
  message?: string;
} 