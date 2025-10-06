import { NotificationType, NotificationStatus, NotificationPriority } from './notification.types';
export declare class CreateNotificationInput {
    userId: string;
    type: NotificationType;
    status?: NotificationStatus;
    priority?: NotificationPriority;
    title: string;
    message: string;
    data?: string;
}
export declare class UpdateNotificationInput {
    type?: NotificationType;
    status?: NotificationStatus;
    priority?: NotificationPriority;
    title?: string;
    message?: string;
    data?: string;
}
