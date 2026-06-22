import { IsString, MinLength } from 'class-validator';

export class NotificationIdDto {
  @IsString()
  @MinLength(1)
  notificationId: string;
}

export class PushTokenDto {
  @IsString()
  @MinLength(1)
  pushToken: string;
}
