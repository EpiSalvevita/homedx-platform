"use strict";
var __decorate = (this && this.__decorate) || function (decorators, target, key, desc) {
    var c = arguments.length, r = c < 3 ? target : desc === null ? desc = Object.getOwnPropertyDescriptor(target, key) : desc, d;
    if (typeof Reflect === "object" && typeof Reflect.decorate === "function") r = Reflect.decorate(decorators, target, key, desc);
    else for (var i = decorators.length - 1; i >= 0; i--) if (d = decorators[i]) r = (c < 3 ? d(r) : c > 3 ? d(target, key, r) : d(target, key)) || r;
    return c > 3 && r && Object.defineProperty(target, key, r), r;
};
var __metadata = (this && this.__metadata) || function (k, v) {
    if (typeof Reflect === "object" && typeof Reflect.metadata === "function") return Reflect.metadata(k, v);
};
Object.defineProperty(exports, "__esModule", { value: true });
exports.NotificationService = void 0;
const common_1 = require("@nestjs/common");
const prisma_service_1 = require("./prisma.service");
const notification_types_1 = require("../graphql/types/notification.types");
let NotificationService = class NotificationService {
    constructor(prisma) {
        this.prisma = prisma;
    }
    mapNotificationType(type) {
        switch (type) {
            case 'TEST_RESULT': return notification_types_1.NotificationType.TEST_RESULT;
            case 'CERTIFICATE_READY': return notification_types_1.NotificationType.CERTIFICATE_READY;
            case 'PAYMENT_SUCCESS': return notification_types_1.NotificationType.PAYMENT_SUCCESS;
            case 'PAYMENT_FAILED': return notification_types_1.NotificationType.PAYMENT_FAILED;
            case 'SYSTEM_UPDATE': return notification_types_1.NotificationType.SYSTEM_UPDATE;
            case 'SECURITY_ALERT': return notification_types_1.NotificationType.SECURITY_ALERT;
            default: return notification_types_1.NotificationType.SYSTEM_UPDATE;
        }
    }
    mapNotificationStatus(status) {
        switch (status) {
            case 'UNREAD': return notification_types_1.NotificationStatus.UNREAD;
            case 'READ': return notification_types_1.NotificationStatus.READ;
            case 'ARCHIVED': return notification_types_1.NotificationStatus.ARCHIVED;
            default: return notification_types_1.NotificationStatus.UNREAD;
        }
    }
    mapNotificationPriority(priority) {
        switch (priority) {
            case 'LOW': return notification_types_1.NotificationPriority.LOW;
            case 'MEDIUM': return notification_types_1.NotificationPriority.MEDIUM;
            case 'HIGH': return notification_types_1.NotificationPriority.HIGH;
            case 'URGENT': return notification_types_1.NotificationPriority.URGENT;
            default: return notification_types_1.NotificationPriority.MEDIUM;
        }
    }
    mapNotificationToGraphQL(notification) {
        return Object.assign(Object.assign({}, notification), { type: this.mapNotificationType(notification.type), status: this.mapNotificationStatus(notification.status), priority: this.mapNotificationPriority(notification.priority) });
    }
    async findAll() {
        const notifications = await this.prisma.notification.findMany({
            include: { user: true },
            orderBy: { createdAt: 'desc' },
        });
        return notifications.map(notification => this.mapNotificationToGraphQL(notification));
    }
    async findOne(id) {
        const notification = await this.prisma.notification.findUnique({
            where: { id },
            include: { user: true },
        });
        return notification ? this.mapNotificationToGraphQL(notification) : null;
    }
    async findByUserId(userId) {
        const notifications = await this.prisma.notification.findMany({
            where: { userId },
            include: { user: true },
            orderBy: { createdAt: 'desc' },
        });
        return notifications.map(notification => this.mapNotificationToGraphQL(notification));
    }
    async findUnreadByUserId(userId) {
        const notifications = await this.prisma.notification.findMany({
            where: { userId, status: 'UNREAD' },
            include: { user: true },
            orderBy: { createdAt: 'desc' },
        });
        return notifications.map(notification => this.mapNotificationToGraphQL(notification));
    }
    async countUnreadByUserId(userId) {
        return this.prisma.notification.count({
            where: { userId, status: 'UNREAD' },
        });
    }
    async create(data) {
        const notification = await this.prisma.notification.create({
            data: data,
            include: { user: true },
        });
        return this.mapNotificationToGraphQL(notification);
    }
    async update(id, data) {
        const notification = await this.prisma.notification.update({
            where: { id },
            data: data,
            include: { user: true },
        });
        return this.mapNotificationToGraphQL(notification);
    }
    async remove(id) {
        const notification = await this.prisma.notification.delete({
            where: { id },
            include: { user: true },
        });
        return this.mapNotificationToGraphQL(notification);
    }
    async markAsRead(id) {
        const notification = await this.prisma.notification.update({
            where: { id },
            data: {
                status: 'READ',
                readAt: new Date(),
            },
            include: { user: true },
        });
        return this.mapNotificationToGraphQL(notification);
    }
    async markAllAsRead(userId) {
        await this.prisma.notification.updateMany({
            where: { userId, status: 'UNREAD' },
            data: {
                status: 'READ',
                readAt: new Date(),
            },
        });
        return this.findByUserId(userId);
    }
    async archive(id) {
        const notification = await this.prisma.notification.update({
            where: { id },
            data: {
                status: 'ARCHIVED',
                archivedAt: new Date(),
            },
            include: { user: true },
        });
        return this.mapNotificationToGraphQL(notification);
    }
};
exports.NotificationService = NotificationService;
exports.NotificationService = NotificationService = __decorate([
    (0, common_1.Injectable)(),
    __metadata("design:paramtypes", [prisma_service_1.PrismaService])
], NotificationService);
//# sourceMappingURL=notification.service.js.map