import { Injectable } from '@nestjs/common';
import { PrismaService } from './prisma.service';
import { NotificationType, NotificationStatus, NotificationPriority } from '../graphql/types/notification.types';

@Injectable()
export class NotificationService {
  constructor(private prisma: PrismaService) {}

  private mapNotificationType(type: string): NotificationType {
    switch (type) {
      case 'TEST_RESULT': return NotificationType.TEST_RESULT;
      case 'CERTIFICATE_READY': return NotificationType.CERTIFICATE_READY;
      case 'PAYMENT_SUCCESS': return NotificationType.PAYMENT_SUCCESS;
      case 'PAYMENT_FAILED': return NotificationType.PAYMENT_FAILED;
      case 'SYSTEM_UPDATE': return NotificationType.SYSTEM_UPDATE;
      case 'SECURITY_ALERT': return NotificationType.SECURITY_ALERT;
      default: return NotificationType.SYSTEM_UPDATE;
    }
  }

  private mapNotificationStatus(status: string): NotificationStatus {
    switch (status) {
      case 'UNREAD': return NotificationStatus.UNREAD;
      case 'READ': return NotificationStatus.READ;
      case 'ARCHIVED': return NotificationStatus.ARCHIVED;
      default: return NotificationStatus.UNREAD;
    }
  }

  private mapNotificationPriority(priority: string): NotificationPriority {
    switch (priority) {
      case 'LOW': return NotificationPriority.LOW;
      case 'MEDIUM': return NotificationPriority.MEDIUM;
      case 'HIGH': return NotificationPriority.HIGH;
      case 'URGENT': return NotificationPriority.URGENT;
      default: return NotificationPriority.MEDIUM;
    }
  }

  private mapNotificationToGraphQL(notification: any) {
    return {
      ...notification,
      type: this.mapNotificationType(notification.type),
      status: this.mapNotificationStatus(notification.status),
      priority: this.mapNotificationPriority(notification.priority),
    };
  }

  async findAll() {
    const notifications = await this.prisma.notification.findMany({
      include: { user: true },
      orderBy: { createdAt: 'desc' },
    });
    return notifications.map(notification => this.mapNotificationToGraphQL(notification));
  }

  async findOne(id: string) {
    const notification = await this.prisma.notification.findUnique({
      where: { id },
      include: { user: true },
    });
    return notification ? this.mapNotificationToGraphQL(notification) : null;
  }

  async findByUserId(userId: string) {
    const notifications = await this.prisma.notification.findMany({
      where: { userId },
      include: { user: true },
      orderBy: { createdAt: 'desc' },
    });
    return notifications.map(notification => this.mapNotificationToGraphQL(notification));
  }

  async findUnreadByUserId(userId: string) {
    const notifications = await this.prisma.notification.findMany({
      where: { userId, status: 'UNREAD' },
      include: { user: true },
      orderBy: { createdAt: 'desc' },
    });
    return notifications.map(notification => this.mapNotificationToGraphQL(notification));
  }

  async countUnreadByUserId(userId: string) {
    return this.prisma.notification.count({
      where: { userId, status: 'UNREAD' },
    });
  }

  async create(data: any) {
    const notification = await this.prisma.notification.create({
      data: data as any,
      include: { user: true },
    });
    return this.mapNotificationToGraphQL(notification);
  }

  async update(id: string, data: any) {
    const notification = await this.prisma.notification.update({
      where: { id },
      data: data as any,
      include: { user: true },
    });
    return this.mapNotificationToGraphQL(notification);
  }

  async remove(id: string) {
    const notification = await this.prisma.notification.delete({
      where: { id },
      include: { user: true },
    });
    return this.mapNotificationToGraphQL(notification);
  }

  async markAsRead(id: string) {
    const notification = await this.prisma.notification.update({
      where: { id },
      data: {
        status: 'READ' as any,
        readAt: new Date(),
      },
      include: { user: true },
    });
    return this.mapNotificationToGraphQL(notification);
  }

  async markAllAsRead(userId: string) {
    await this.prisma.notification.updateMany({
      where: { userId, status: 'UNREAD' },
      data: {
        status: 'READ' as any,
        readAt: new Date(),
      },
    });

    return this.findByUserId(userId);
  }

  async archive(id: string) {
    const notification = await this.prisma.notification.update({
      where: { id },
      data: {
        status: 'ARCHIVED' as any,
        archivedAt: new Date(),
      },
      include: { user: true },
    });
    return this.mapNotificationToGraphQL(notification);
  }
} 