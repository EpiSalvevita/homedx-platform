import { Notification } from '../types/notification.types';
import { CreateNotificationInput, UpdateNotificationInput } from '../types/notification.input';
import { NotificationService } from '../../services/notification.service';
export declare class NotificationResolver {
    private readonly notificationService;
    constructor(notificationService: NotificationService);
    notifications(): Promise<Notification[]>;
    notification(id: string): Promise<Notification | null>;
    userNotifications(userId: string): Promise<Notification[]>;
    unreadNotifications(userId: string): Promise<Notification[]>;
    unreadNotificationCount(userId: string): Promise<number>;
    createNotification(input: CreateNotificationInput): Promise<Notification>;
    updateNotification(id: string, input: UpdateNotificationInput): Promise<Notification>;
    removeNotification(id: string): Promise<Notification>;
    markNotificationAsRead(id: string): Promise<Notification>;
    markAllNotificationsAsRead(userId: string): Promise<Notification[]>;
    archiveNotification(id: string): Promise<Notification>;
}
