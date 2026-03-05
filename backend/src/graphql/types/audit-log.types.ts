import { Field, ObjectType, registerEnumType } from '@nestjs/graphql';
import { User } from './user.type';

export enum AuditAction {
  CREATE = 'CREATE',
  UPDATE = 'UPDATE',
  DELETE = 'DELETE',
  LOGIN = 'LOGIN',
  LOGOUT = 'LOGOUT',
  VIEW = 'VIEW',
  EXPORT = 'EXPORT'
}

export enum AuditEntityType {
  USER = 'USER',
  RAPID_TEST = 'RAPID_TEST',
  TEST_KIT = 'TEST_KIT',
  PAYMENT = 'PAYMENT',
  CERTIFICATE = 'CERTIFICATE',
  LICENSE = 'LICENSE'
}

registerEnumType(AuditAction, {
  name: 'AuditAction',
  description: 'Audit action enumeration',
});

registerEnumType(AuditEntityType, {
  name: 'AuditEntityType',
  description: 'Audit entity type enumeration',
});

@ObjectType()
export class AuditLog {
  @Field()
  id: string;

  @Field()
  userId: string;

  @Field(() => AuditAction)
  action: AuditAction;

  @Field(() => AuditEntityType)
  entityType: AuditEntityType;

  @Field({ nullable: true })
  entityId?: string;

  @Field({ nullable: true })
  oldValues?: string;

  @Field({ nullable: true })
  newValues?: string;

  @Field({ nullable: true })
  ipAddress?: string;

  @Field({ nullable: true })
  userAgent?: string;

  @Field({ nullable: true })
  description?: string;

  @Field()
  createdAt: Date;

  // Relations
  @Field(() => User)
  user: User;
} 