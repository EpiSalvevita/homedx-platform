import { Field, ObjectType, registerEnumType } from '@nestjs/graphql';
import { User } from './user.type';

export enum NotificationType {
  TEST_RESULT = 'TEST_RESULT',
  CERTIFICATE_READY = 'CERTIFICATE_READY',
  PAYMENT_SUCCESS = 'PAYMENT_SUCCESS',
  PAYMENT_FAILED = 'PAYMENT_FAILED',
  SYSTEM_UPDATE = 'SYSTEM_UPDATE',
  SECURITY_ALERT = 'SECURITY_ALERT'
}

export enum NotificationStatus {
  UNREAD = 'UNREAD',
  READ = 'READ',
  ARCHIVED = 'ARCHIVED'
}

export enum NotificationPriority {
  LOW = 'LOW',
  MEDIUM = 'MEDIUM',
  HIGH = 'HIGH',
  URGENT = 'URGENT'
}

registerEnumType(NotificationType, {
  name: 'NotificationType',
  description: 'Notification type enumeration',
});

registerEnumType(NotificationStatus, {
  name: 'NotificationStatus',
  description: 'Notification status enumeration',
});

registerEnumType(NotificationPriority, {
  name: 'NotificationPriority',
  description: 'Notification priority enumeration',
});

@ObjectType()
export class Notification {
  @Field()
  id: string;

  @Field()
  userId: string;

  @Field(() => NotificationType)
  type: NotificationType;

  @Field(() => NotificationStatus)
  status: NotificationStatus;

  @Field(() => NotificationPriority)
  priority: NotificationPriority;

  @Field()
  title: string;

  @Field()
  message: string;

  @Field({ nullable: true })
  data?: string;

  @Field({ nullable: true })
  readAt?: Date;

  @Field({ nullable: true })
  archivedAt?: Date;

  @Field()
  createdAt: Date;

  @Field()
  updatedAt: Date;

  // Relations
  @Field(() => User)
  user: User;
} 