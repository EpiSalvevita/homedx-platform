import { Field, InputType } from '@nestjs/graphql';
import { IsString, IsOptional, IsEnum } from 'class-validator';
import { AuditAction, AuditEntityType } from './audit-log.types';

@InputType()
export class CreateAuditLogInput {
  @Field()
  @IsString()
  userId: string;

  @Field(() => AuditAction)
  @IsEnum(AuditAction)
  action: AuditAction;

  @Field(() => AuditEntityType)
  @IsEnum(AuditEntityType)
  entityType: AuditEntityType;

  @Field({ nullable: true })
  @IsOptional()
  @IsString()
  entityId?: string;

  @Field({ nullable: true })
  @IsOptional()
  @IsString()
  oldValues?: string;

  @Field({ nullable: true })
  @IsOptional()
  @IsString()
  newValues?: string;

  @Field({ nullable: true })
  @IsOptional()
  @IsString()
  ipAddress?: string;

  @Field({ nullable: true })
  @IsOptional()
  @IsString()
  userAgent?: string;

  @Field({ nullable: true })
  @IsOptional()
  @IsString()
  description?: string;
}

@InputType()
export class UpdateAuditLogInput {
  @Field({ nullable: true })
  @IsOptional()
  @IsString()
  oldValues?: string;

  @Field({ nullable: true })
  @IsOptional()
  @IsString()
  newValues?: string;

  @Field({ nullable: true })
  @IsOptional()
  @IsString()
  ipAddress?: string;

  @Field({ nullable: true })
  @IsOptional()
  @IsString()
  userAgent?: string;

  @Field({ nullable: true })
  @IsOptional()
  @IsString()
  description?: string;
} 