import { Injectable } from '@nestjs/common';
import { PrismaService } from './prisma.service';

@Injectable()
export class NotificationService {
  constructor(private prisma: PrismaService) {}

  async findByUserId(userId: string) {
    return this.prisma.notification.findMany({
      where: { userId },
      include: { user: true },
      orderBy: { createdAt: 'desc' },
    });
  }

  async countUnreadByUserId(userId: string) {
    return this.prisma.notification.count({
      where: { userId, status: 'UNREAD' },
    });
  }

  async create(data: Record<string, unknown>) {
    return this.prisma.notification.create({
      data: data as any,
      include: { user: true },
    });
  }

  async markAsRead(id: string) {
    return this.prisma.notification.update({
      where: { id },
      data: {
        status: 'READ' as any,
        readAt: new Date(),
      },
      include: { user: true },
    });
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
}
