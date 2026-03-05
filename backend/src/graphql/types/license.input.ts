import { Field, InputType, Int } from '@nestjs/graphql';
import { LicenseStatus } from './license.type';

@InputType()
export class CreateLicenseInput {
  @Field()
  userId: string;

  @Field(() => Int)
  maxUses: number;

  @Field({ nullable: true })
  expiresAt?: Date;

  @Field()
  licenseKey: string;

  @Field(() => LicenseStatus)
  status: LicenseStatus;

  @Field({ nullable: true })
  description?: string;
}

@InputType()
export class UpdateLicenseInput {
  @Field(() => Int, { nullable: true })
  maxUses?: number;

  @Field({ nullable: true })
  expiresAt?: Date;

  @Field(() => LicenseStatus, { nullable: true })
  status?: LicenseStatus;

  @Field({ nullable: true })
  revokedAt?: Date;

  @Field({ nullable: true })
  revokedReason?: string;

  @Field({ nullable: true })
  description?: string;
} 