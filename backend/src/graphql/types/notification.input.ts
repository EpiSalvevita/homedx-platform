import { Field, InputType } from '@nestjs/graphql';
import { IsString, IsOptional, IsEnum } from 'class-validator';
import { NotificationType, NotificationStatus, NotificationPriority } from './notification.types';

@InputType()
export class CreateNotificationInput {
  @Field()
  @IsString()
  userId: string;

  @Field(() => NotificationType)
  @IsEnum(NotificationType)
  type: NotificationType;

  @Field(() => NotificationStatus, { nullable: true })
  @IsOptional()
  @IsEnum(NotificationStatus)
  status?: NotificationStatus;

  @Field(() => NotificationPriority, { nullable: true })
  @IsOptional()
  @IsEnum(NotificationPriority)
  priority?: NotificationPriority;

  @Field()
  @IsString()
  title: string;

  @Field()
  @IsString()
  message: string;

  @Field({ nullable: true })
  @IsOptional()
  @IsString()
  data?: string;
}

@InputType()
export class UpdateNotificationInput {
  @Field(() => NotificationType, { nullable: true })
  @IsOptional()
  @IsEnum(NotificationType)
  type?: NotificationType;

  @Field(() => NotificationStatus, { nullable: true })
  @IsOptional()
  @IsEnum(NotificationStatus)
  status?: NotificationStatus;

  @Field(() => NotificationPriority, { nullable: true })
  @IsOptional()
  @IsEnum(NotificationPriority)
  priority?: NotificationPriority;

  @Field({ nullable: true })
  @IsOptional()
  @IsString()
  title?: string;

  @Field({ nullable: true })
  @IsOptional()
  @IsString()
  message?: string;

  @Field({ nullable: true })
  @IsOptional()
  @IsString()
  data?: string;
} 