import { Module } from '@nestjs/common';
import { NotificationService } from '../../services/notification.service';
import { MobileNotificationService } from '../../services/mobile-notification.service';
import { PushService } from '../../services/push.service';
import { MobileNotificationController } from '../../controllers/mobile-notification.controller';

@Module({
  controllers: [MobileNotificationController],
  providers: [NotificationService, MobileNotificationService, PushService],
  exports: [NotificationService, MobileNotificationService, PushService],
})
export class NotificationsModule {}
