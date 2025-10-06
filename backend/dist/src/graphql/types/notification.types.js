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
exports.Notification = exports.NotificationPriority = exports.NotificationStatus = exports.NotificationType = void 0;
const graphql_1 = require("@nestjs/graphql");
const user_type_1 = require("./user.type");
var NotificationType;
(function (NotificationType) {
    NotificationType["TEST_RESULT"] = "TEST_RESULT";
    NotificationType["CERTIFICATE_READY"] = "CERTIFICATE_READY";
    NotificationType["PAYMENT_SUCCESS"] = "PAYMENT_SUCCESS";
    NotificationType["PAYMENT_FAILED"] = "PAYMENT_FAILED";
    NotificationType["SYSTEM_UPDATE"] = "SYSTEM_UPDATE";
    NotificationType["SECURITY_ALERT"] = "SECURITY_ALERT";
})(NotificationType || (exports.NotificationType = NotificationType = {}));
var NotificationStatus;
(function (NotificationStatus) {
    NotificationStatus["UNREAD"] = "UNREAD";
    NotificationStatus["READ"] = "READ";
    NotificationStatus["ARCHIVED"] = "ARCHIVED";
})(NotificationStatus || (exports.NotificationStatus = NotificationStatus = {}));
var NotificationPriority;
(function (NotificationPriority) {
    NotificationPriority["LOW"] = "LOW";
    NotificationPriority["MEDIUM"] = "MEDIUM";
    NotificationPriority["HIGH"] = "HIGH";
    NotificationPriority["URGENT"] = "URGENT";
})(NotificationPriority || (exports.NotificationPriority = NotificationPriority = {}));
(0, graphql_1.registerEnumType)(NotificationType, {
    name: 'NotificationType',
    description: 'Notification type enumeration',
});
(0, graphql_1.registerEnumType)(NotificationStatus, {
    name: 'NotificationStatus',
    description: 'Notification status enumeration',
});
(0, graphql_1.registerEnumType)(NotificationPriority, {
    name: 'NotificationPriority',
    description: 'Notification priority enumeration',
});
let Notification = class Notification {
};
exports.Notification = Notification;
__decorate([
    (0, graphql_1.Field)(),
    __metadata("design:type", String)
], Notification.prototype, "id", void 0);
__decorate([
    (0, graphql_1.Field)(),
    __metadata("design:type", String)
], Notification.prototype, "userId", void 0);
__decorate([
    (0, graphql_1.Field)(() => NotificationType),
    __metadata("design:type", String)
], Notification.prototype, "type", void 0);
__decorate([
    (0, graphql_1.Field)(() => NotificationStatus),
    __metadata("design:type", String)
], Notification.prototype, "status", void 0);
__decorate([
    (0, graphql_1.Field)(() => NotificationPriority),
    __metadata("design:type", String)
], Notification.prototype, "priority", void 0);
__decorate([
    (0, graphql_1.Field)(),
    __metadata("design:type", String)
], Notification.prototype, "title", void 0);
__decorate([
    (0, graphql_1.Field)(),
    __metadata("design:type", String)
], Notification.prototype, "message", void 0);
__decorate([
    (0, graphql_1.Field)({ nullable: true }),
    __metadata("design:type", String)
], Notification.prototype, "data", void 0);
__decorate([
    (0, graphql_1.Field)({ nullable: true }),
    __metadata("design:type", Date)
], Notification.prototype, "readAt", void 0);
__decorate([
    (0, graphql_1.Field)({ nullable: true }),
    __metadata("design:type", Date)
], Notification.prototype, "archivedAt", void 0);
__decorate([
    (0, graphql_1.Field)(),
    __metadata("design:type", Date)
], Notification.prototype, "createdAt", void 0);
__decorate([
    (0, graphql_1.Field)(),
    __metadata("design:type", Date)
], Notification.prototype, "updatedAt", void 0);
__decorate([
    (0, graphql_1.Field)(() => user_type_1.User),
    __metadata("design:type", user_type_1.User)
], Notification.prototype, "user", void 0);
exports.Notification = Notification = __decorate([
    (0, graphql_1.ObjectType)()
], Notification);
//# sourceMappingURL=notification.types.js.map