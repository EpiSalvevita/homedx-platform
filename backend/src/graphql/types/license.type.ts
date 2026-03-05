import { Field, ObjectType, Int, registerEnumType } from '@nestjs/graphql';
import { User } from './user.type';

export enum LicenseStatus {
  ACTIVE = 'ACTIVE',
  EXPIRED = 'EXPIRED',
  REVOKED = 'REVOKED',
}

registerEnumType(LicenseStatus, {
  name: 'LicenseStatus',
  description: 'License status enumeration',
});

@ObjectType()
export class License {
  @Field()
  id: string;

  @Field()
  userId: string;

  @Field(() => Int)
  maxUses: number;

  @Field(() => Int)
  usesCount: number;

  @Field({ nullable: true })
  expiresAt?: Date;

  @Field()
  createdAt: Date;

  @Field()
  updatedAt: Date;

  @Field()
  licenseKey: string;

  @Field({ nullable: true })
  revokedAt?: Date;

  @Field({ nullable: true })
  revokedReason?: string;

  @Field(() => LicenseStatus)
  status: LicenseStatus;

  @Field({ nullable: true })
  description?: string;

  @Field(() => User, { nullable: true })
  user?: User;
} 