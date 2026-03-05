import { Field, ObjectType, registerEnumType } from '@nestjs/graphql';
import { User } from './user.type';

export enum TestKitType {
  COVID_19 = 'COVID_19',
  FLU = 'FLU',
  STREP_THROAT = 'STREP_THROAT',
  PREGNANCY = 'PREGNANCY',
  DRUG_TEST = 'DRUG_TEST'
}

export enum TestKitStatus {
  AVAILABLE = 'AVAILABLE',
  USED = 'USED',
  EXPIRED = 'EXPIRED',
  DAMAGED = 'DAMAGED'
}

registerEnumType(TestKitType, {
  name: 'TestKitType',
  description: 'Test kit type enumeration',
});

registerEnumType(TestKitStatus, {
  name: 'TestKitStatus',
  description: 'Test kit status enumeration',
});

@ObjectType()
export class TestKit {
  @Field()
  id: string;

  @Field()
  serialNumber: string;

  @Field(() => TestKitType)
  type: TestKitType;

  @Field()
  manufacturer: string;

  @Field()
  model: string;

  @Field()
  batchNumber: string;

  @Field()
  expirationDate: Date;

  @Field(() => TestKitStatus)
  status: TestKitStatus;

  @Field({ nullable: true })
  userId?: string;

  @Field({ nullable: true })
  purchasedAt?: Date;

  @Field({ nullable: true })
  usedAt?: Date;

  @Field()
  createdAt: Date;

  @Field()
  updatedAt: Date;

  // Relations
  @Field(() => User, { nullable: true })
  user?: User;
} 