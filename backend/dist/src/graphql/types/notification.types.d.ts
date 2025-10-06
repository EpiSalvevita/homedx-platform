import { User } from './user.type';
export declare enum NotificationType {
    TEST_RESULT = "TEST_RESULT",
    CERTIFICATE_READY = "CERTIFICATE_READY",
    PAYMENT_SUCCESS = "PAYMENT_SUCCESS",
    PAYMENT_FAILED = "PAYMENT_FAILED",
    SYSTEM_UPDATE = "SYSTEM_UPDATE",
    SECURITY_ALERT = "SECURITY_ALERT"
}
export declare enum NotificationStatus {
    UNREAD = "UNREAD",
    READ = "READ",
    ARCHIVED = "ARCHIVED"
}
export declare enum NotificationPriority {
    LOW = "LOW",
    MEDIUM = "MEDIUM",
    HIGH = "HIGH",
    URGENT = "URGENT"
}
export declare class Notification {
    id: string;
    userId: string;
    type: NotificationType;
    status: NotificationStatus;
    priority: NotificationPriority;
    title: string;
    message: string;
    data?: string;
    readAt?: Date;
    archivedAt?: Date;
    createdAt: Date;
    updatedAt: Date;
    user: User;
}
