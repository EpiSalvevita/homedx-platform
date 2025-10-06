import { Resolver, Query, Mutation, Args } from '@nestjs/graphql';
// import { UseGuards } from '@nestjs/common';
import { Notification } from '../types/notification.types';
import { CreateNotificationInput, UpdateNotificationInput } from '../types/notification.input';
import { NotificationService } from '../../services/notification.service';
// import { JwtAuthGuard } from '../../auth/jwt-auth.guard';

@Resolver(() => Notification)
export class NotificationResolver {
  constructor(private readonly notificationService: NotificationService) {}

  @Query(() => [Notification])
  // @UseGuards(JwtAuthGuard)
  async notifications(): Promise<Notification[]> {
    return this.notificationService.findAll();
  }

  @Query(() => Notification, { nullable: true })
  // @UseGuards(JwtAuthGuard)
  async notification(@Args('id') id: string): Promise<Notification | null> {
    return this.notificationService.findOne(id);
  }

  @Query(() => [Notification])
  // @UseGuards(JwtAuthGuard)
  async userNotifications(@Args('userId') userId: string): Promise<Notification[]> {
    return this.notificationService.findByUserId(userId);
  }

  @Query(() => [Notification])
  // @UseGuards(JwtAuthGuard)
  async unreadNotifications(@Args('userId') userId: string): Promise<Notification[]> {
    return this.notificationService.findUnreadByUserId(userId);
  }

  @Query(() => Number)
  // @UseGuards(JwtAuthGuard)
  async unreadNotificationCount(@Args('userId') userId: string): Promise<number> {
    return this.notificationService.countUnreadByUserId(userId);
  }

  @Mutation(() => Notification)
  // @UseGuards(JwtAuthGuard)
  async createNotification(@Args('input') input: CreateNotificationInput): Promise<Notification> {
    return this.notificationService.create(input);
  }

  @Mutation(() => Notification)
  // @UseGuards(JwtAuthGuard)
  async updateNotification(
    @Args('id') id: string,
    @Args('input') input: UpdateNotificationInput,
  ): Promise<Notification> {
    return this.notificationService.update(id, input);
  }

  @Mutation(() => Notification)
  // @UseGuards(JwtAuthGuard)
  async removeNotification(@Args('id') id: string): Promise<Notification> {
    return this.notificationService.remove(id);
  }

  @Mutation(() => Notification)
  // @UseGuards(JwtAuthGuard)
  async markNotificationAsRead(@Args('id') id: string): Promise<Notification> {
    return this.notificationService.markAsRead(id);
  }

  @Mutation(() => [Notification])
  // @UseGuards(JwtAuthGuard)
  async markAllNotificationsAsRead(@Args('userId') userId: string): Promise<Notification[]> {
    return this.notificationService.markAllAsRead(userId);
  }

  @Mutation(() => Notification)
  // @UseGuards(JwtAuthGuard)
  async archiveNotification(@Args('id') id: string): Promise<Notification> {
    return this.notificationService.archive(id);
  }
} 