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
var __param = (this && this.__param) || function (paramIndex, decorator) {
    return function (target, key) { decorator(target, key, paramIndex); }
};
Object.defineProperty(exports, "__esModule", { value: true });
exports.NotificationResolver = void 0;
const graphql_1 = require("@nestjs/graphql");
const notification_types_1 = require("../types/notification.types");
const notification_input_1 = require("../types/notification.input");
const notification_service_1 = require("../../services/notification.service");
let NotificationResolver = class NotificationResolver {
    constructor(notificationService) {
        this.notificationService = notificationService;
    }
    async notifications() {
        return this.notificationService.findAll();
    }
    async notification(id) {
        return this.notificationService.findOne(id);
    }
    async userNotifications(userId) {
        return this.notificationService.findByUserId(userId);
    }
    async unreadNotifications(userId) {
        return this.notificationService.findUnreadByUserId(userId);
    }
    async unreadNotificationCount(userId) {
        return this.notificationService.countUnreadByUserId(userId);
    }
    async createNotification(input) {
        return this.notificationService.create(input);
    }
    async updateNotification(id, input) {
        return this.notificationService.update(id, input);
    }
    async removeNotification(id) {
        return this.notificationService.remove(id);
    }
    async markNotificationAsRead(id) {
        return this.notificationService.markAsRead(id);
    }
    async markAllNotificationsAsRead(userId) {
        return this.notificationService.markAllAsRead(userId);
    }
    async archiveNotification(id) {
        return this.notificationService.archive(id);
    }
};
exports.NotificationResolver = NotificationResolver;
__decorate([
    (0, graphql_1.Query)(() => [notification_types_1.Notification]),
    __metadata("design:type", Function),
    __metadata("design:paramtypes", []),
    __metadata("design:returntype", Promise)
], NotificationResolver.prototype, "notifications", null);
__decorate([
    (0, graphql_1.Query)(() => notification_types_1.Notification, { nullable: true }),
    __param(0, (0, graphql_1.Args)('id')),
    __metadata("design:type", Function),
    __metadata("design:paramtypes", [String]),
    __metadata("design:returntype", Promise)
], NotificationResolver.prototype, "notification", null);
__decorate([
    (0, graphql_1.Query)(() => [notification_types_1.Notification]),
    __param(0, (0, graphql_1.Args)('userId')),
    __metadata("design:type", Function),
    __metadata("design:paramtypes", [String]),
    __metadata("design:returntype", Promise)
], NotificationResolver.prototype, "userNotifications", null);
__decorate([
    (0, graphql_1.Query)(() => [notification_types_1.Notification]),
    __param(0, (0, graphql_1.Args)('userId')),
    __metadata("design:type", Function),
    __metadata("design:paramtypes", [String]),
    __metadata("design:returntype", Promise)
], NotificationResolver.prototype, "unreadNotifications", null);
__decorate([
    (0, graphql_1.Query)(() => Number),
    __param(0, (0, graphql_1.Args)('userId')),
    __metadata("design:type", Function),
    __metadata("design:paramtypes", [String]),
    __metadata("design:returntype", Promise)
], NotificationResolver.prototype, "unreadNotificationCount", null);
__decorate([
    (0, graphql_1.Mutation)(() => notification_types_1.Notification),
    __param(0, (0, graphql_1.Args)('input')),
    __metadata("design:type", Function),
    __metadata("design:paramtypes", [notification_input_1.CreateNotificationInput]),
    __metadata("design:returntype", Promise)
], NotificationResolver.prototype, "createNotification", null);
__decorate([
    (0, graphql_1.Mutation)(() => notification_types_1.Notification),
    __param(0, (0, graphql_1.Args)('id')),
    __param(1, (0, graphql_1.Args)('input')),
    __metadata("design:type", Function),
    __metadata("design:paramtypes", [String, notification_input_1.UpdateNotificationInput]),
    __metadata("design:returntype", Promise)
], NotificationResolver.prototype, "updateNotification", null);
__decorate([
    (0, graphql_1.Mutation)(() => notification_types_1.Notification),
    __param(0, (0, graphql_1.Args)('id')),
    __metadata("design:type", Function),
    __metadata("design:paramtypes", [String]),
    __metadata("design:returntype", Promise)
], NotificationResolver.prototype, "removeNotification", null);
__decorate([
    (0, graphql_1.Mutation)(() => notification_types_1.Notification),
    __param(0, (0, graphql_1.Args)('id')),
    __metadata("design:type", Function),
    __metadata("design:paramtypes", [String]),
    __metadata("design:returntype", Promise)
], NotificationResolver.prototype, "markNotificationAsRead", null);
__decorate([
    (0, graphql_1.Mutation)(() => [notification_types_1.Notification]),
    __param(0, (0, graphql_1.Args)('userId')),
    __metadata("design:type", Function),
    __metadata("design:paramtypes", [String]),
    __metadata("design:returntype", Promise)
], NotificationResolver.prototype, "markAllNotificationsAsRead", null);
__decorate([
    (0, graphql_1.Mutation)(() => notification_types_1.Notification),
    __param(0, (0, graphql_1.Args)('id')),
    __metadata("design:type", Function),
    __metadata("design:paramtypes", [String]),
    __metadata("design:returntype", Promise)
], NotificationResolver.prototype, "archiveNotification", null);
exports.NotificationResolver = NotificationResolver = __decorate([
    (0, graphql_1.Resolver)(() => notification_types_1.Notification),
    __metadata("design:paramtypes", [notification_service_1.NotificationService])
], NotificationResolver);
//# sourceMappingURL=notification.resolver.js.map