import { Field, ObjectType, registerEnumType } from '@nestjs/graphql';
import { User } from './user.type';
import { TestKit } from './test-kit.types';

export enum TestResult {
  POSITIVE = 'POSITIVE',
  NEGATIVE = 'NEGATIVE',
  INVALID = 'INVALID',
  INCONCLUSIVE = 'INCONCLUSIVE'
}

export enum TestStatus {
  PENDING = 'PENDING',
  IN_PROGRESS = 'IN_PROGRESS',
  COMPLETED = 'COMPLETED',
  FAILED = 'FAILED'
}

registerEnumType(TestResult, {
  name: 'TestResult',
  description: 'Rapid test result enumeration',
});

registerEnumType(TestStatus, {
  name: 'TestStatus',
  description: 'Rapid test status enumeration',
});

@ObjectType()
export class RapidTest {
  @Field()
  id: string;

  @Field()
  userId: string;

  @Field()
  testKitId: string;

  @Field()
  testDate: Date;

  @Field(() => TestStatus)
  status: TestStatus;

  @Field(() => TestResult, { nullable: true })
  result?: TestResult;

  @Field({ nullable: true })
  resultImageUrl?: string;

  @Field({ nullable: true })
  notes?: string;

  @Field()
  createdAt: Date;

  @Field()
  updatedAt: Date;

  @Field({ nullable: true })
  completedAt?: Date;

  // Relations
  @Field(() => User)
  user: User;

  @Field(() => TestKit)
  testKit: TestKit;
}

@ObjectType()
export class SubmitTestResponse {
  @Field()
  success: boolean;

  @Field({ nullable: true })
  validation?: string;
} 