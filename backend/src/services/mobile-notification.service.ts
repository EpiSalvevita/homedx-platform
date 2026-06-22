import { ForbiddenException, Injectable } from '@nestjs/common';
import { NotificationService } from './notification.service';
import { PrismaService } from './prisma.service';
import { PushService } from './push.service';

export interface MobileNotificationRecord {
  id: string;
  type: string;
  status: string;
  priority: string;
  title: string;
  message: string;
  data: string | null;
  readAt: string | null;
  createdAt: string;
}

@Injectable()
export class MobileNotificationService {
  constructor(
    private readonly notificationService: NotificationService,
    private readonly prisma: PrismaService,
    private readonly pushService: PushService,
  ) {}

  async listForUser(userId: string): Promise<MobileNotificationRecord[]> {
    const notifications = await this.notificationService.findByUserId(userId);
    return notifications.map((n) => this.toRecord(n));
  }

  async getUnreadCount(userId: string): Promise<number> {
    return this.notificationService.countUnreadByUserId(userId);
  }

  async markRead(userId: string, notificationId: string): Promise<MobileNotificationRecord> {
    const notification = await this.prisma.notification.findUnique({
      where: { id: notificationId },
    });
    if (!notification || notification.userId !== userId) {
      throw new ForbiddenException('Notification not found');
    }
    const updated = await this.notificationService.markAsRead(notificationId);
    return this.toRecord(updated);
  }

  async markAllRead(userId: string): Promise<number> {
    await this.notificationService.markAllAsRead(userId);
    return 0;
  }

  async registerPushToken(userId: string, pushToken: string): Promise<void> {
    await this.prisma.user.update({
      where: { id: userId },
      data: { pushToken },
    });
  }

  async notifyUser(
    userId: string,
    payload: {
      type: string;
      title: string;
      message: string;
      data?: Record<string, unknown>;
    },
  ): Promise<void> {
    await this.notificationService.create({
      userId,
      type: payload.type,
      status: 'UNREAD',
      priority: 'MEDIUM',
      title: payload.title,
      message: payload.message,
      data: payload.data ? JSON.stringify(payload.data) : null,
    });

    const user = await this.prisma.user.findUnique({ where: { id: userId } });
    if (user?.pushToken) {
      await this.pushService.sendToToken(user.pushToken, {
        title: payload.title,
        body: payload.message,
      });
    }
  }

  private toRecord(notification: {
    id: string;
    type: string;
    status: string;
    priority: string;
    title: string;
    message: string;
    data: string | null;
    readAt: Date | null;
    createdAt: Date;
  }): MobileNotificationRecord {
    return {
      id: notification.id,
      type: notification.type,
      status: notification.status,
      priority: notification.priority,
      title: notification.title,
      message: notification.message,
      data: notification.data,
      readAt: notification.readAt?.toISOString() ?? null,
      createdAt: notification.createdAt.toISOString(),
    };
  }
}
