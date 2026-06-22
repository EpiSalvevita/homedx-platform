import { Body, Controller, Post, Request, UseGuards } from '@nestjs/common';
import { MobileNotificationService } from '../services/mobile-notification.service';
import { JwtAuthGuard } from '../auth/jwt-auth.guard';
import { NotificationIdDto, PushTokenDto } from '../dto/mobile/notification.dto';
import { sanitizeMobileError } from '../util/mobile-error.util';
import { MOBILE_API_PATH, NotificationCountResponse } from './mobile.types';

@Controller(MOBILE_API_PATH)
export class MobileNotificationController {
  constructor(private readonly mobileNotificationService: MobileNotificationService) {}

  @Post('list-notifications')
  @UseGuards(JwtAuthGuard)
  async listNotifications(@Request() req: { user?: { sub: string } }) {
    try {
      const userId = req.user?.sub;
      if (!userId) {
        return { success: false, error: 'Invalid token' };
      }
      const notifications = await this.mobileNotificationService.listForUser(userId);
      return { success: true, notifications };
    } catch (error) {
      return sanitizeMobileError(error, 'Failed to list notifications');
    }
  }

  @Post('get-unread-notification-count')
  @UseGuards(JwtAuthGuard)
  async getUnreadNotificationCount(
    @Request() req: { user?: { sub: string } },
  ): Promise<NotificationCountResponse> {
    try {
      const userId = req.user?.sub;
      if (!userId) {
        return { success: false, error: 'Invalid token' };
      }
      const count = await this.mobileNotificationService.getUnreadCount(userId);
      return { success: true, count };
    } catch (error) {
      return sanitizeMobileError(error, 'Failed to get notification count');
    }
  }

  @Post('mark-notification-read')
  @UseGuards(JwtAuthGuard)
  async markNotificationRead(
    @Request() req: { user?: { sub: string } },
    @Body() body: NotificationIdDto,
  ) {
    try {
      const userId = req.user?.sub;
      if (!userId) {
        return { success: false, error: 'Invalid token' };
      }
      const notification = await this.mobileNotificationService.markRead(
        userId,
        body.notificationId,
      );
      return { success: true, notification };
    } catch (error) {
      return sanitizeMobileError(error, 'Failed to mark notification read');
    }
  }

  @Post('mark-all-notifications-read')
  @UseGuards(JwtAuthGuard)
  async markAllNotificationsRead(@Request() req: { user?: { sub: string } }) {
    try {
      const userId = req.user?.sub;
      if (!userId) {
        return { success: false, error: 'Invalid token' };
      }
      await this.mobileNotificationService.markAllRead(userId);
      return { success: true };
    } catch (error) {
      return sanitizeMobileError(error, 'Failed to mark notifications read');
    }
  }

  @Post('register-push-token')
  @UseGuards(JwtAuthGuard)
  async registerPushToken(
    @Request() req: { user?: { sub: string } },
    @Body() body: PushTokenDto,
  ) {
    try {
      const userId = req.user?.sub;
      if (!userId) {
        return { success: false, error: 'Invalid token' };
      }
      await this.mobileNotificationService.registerPushToken(userId, body.pushToken);
      return { success: true };
    } catch (error) {
      return sanitizeMobileError(error, 'Failed to register push token');
    }
  }
}
