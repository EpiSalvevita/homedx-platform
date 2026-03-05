import { Field, InputType } from '@nestjs/graphql';
import { IsString, IsOptional, IsDate, IsEnum } from 'class-validator';
import { TestKitType, TestKitStatus } from './test-kit.types';

@InputType()
export class CreateTestKitInput {
  @Field()
  @IsString()
  serialNumber: string;

  @Field(() => TestKitType)
  @IsEnum(TestKitType)
  type: TestKitType;

  @Field()
  @IsString()
  manufacturer: string;

  @Field()
  @IsString()
  model: string;

  @Field()
  @IsString()
  batchNumber: string;

  @Field()
  @IsDate()
  expirationDate: Date;

  @Field(() => TestKitStatus, { nullable: true })
  @IsOptional()
  @IsEnum(TestKitStatus)
  status?: TestKitStatus;

  @Field({ nullable: true })
  @IsOptional()
  @IsString()
  userId?: string;
}

@InputType()
export class UpdateTestKitInput {
  @Field({ nullable: true })
  @IsOptional()
  @IsString()
  serialNumber?: string;

  @Field(() => TestKitType, { nullable: true })
  @IsOptional()
  @IsEnum(TestKitType)
  type?: TestKitType;

  @Field({ nullable: true })
  @IsOptional()
  @IsString()
  manufacturer?: string;

  @Field({ nullable: true })
  @IsOptional()
  @IsString()
  model?: string;

  @Field({ nullable: true })
  @IsOptional()
  @IsString()
  batchNumber?: string;

  @Field({ nullable: true })
  @IsOptional()
  @IsDate()
  expirationDate?: Date;

  @Field(() => TestKitStatus, { nullable: true })
  @IsOptional()
  @IsEnum(TestKitStatus)
  status?: TestKitStatus;

  @Field({ nullable: true })
  @IsOptional()
  @IsString()
  userId?: string;
} 