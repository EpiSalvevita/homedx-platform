import { PrismaService } from './prisma.service';
export declare class NotificationService {
    private prisma;
    constructor(prisma: PrismaService);
    private mapNotificationType;
    private mapNotificationStatus;
    private mapNotificationPriority;
    private mapNotificationToGraphQL;
    findAll(): Promise<any[]>;
    findOne(id: string): Promise<any>;
    findByUserId(userId: string): Promise<any[]>;
    findUnreadByUserId(userId: string): Promise<any[]>;
    countUnreadByUserId(userId: string): Promise<number>;
    create(data: any): Promise<any>;
    update(id: string, data: any): Promise<any>;
    remove(id: string): Promise<any>;
    markAsRead(id: string): Promise<any>;
    markAllAsRead(userId: string): Promise<any[]>;
    archive(id: string): Promise<any>;
}
