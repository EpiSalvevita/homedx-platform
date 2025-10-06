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
exports.UpdateNotificationInput = exports.CreateNotificationInput = void 0;
const graphql_1 = require("@nestjs/graphql");
const class_validator_1 = require("class-validator");
const notification_types_1 = require("./notification.types");
let CreateNotificationInput = class CreateNotificationInput {
};
exports.CreateNotificationInput = CreateNotificationInput;
__decorate([
    (0, graphql_1.Field)(),
    (0, class_validator_1.IsString)(),
    __metadata("design:type", String)
], CreateNotificationInput.prototype, "userId", void 0);
__decorate([
    (0, graphql_1.Field)(() => notification_types_1.NotificationType),
    (0, class_validator_1.IsEnum)(notification_types_1.NotificationType),
    __metadata("design:type", String)
], CreateNotificationInput.prototype, "type", void 0);
__decorate([
    (0, graphql_1.Field)(() => notification_types_1.NotificationStatus, { nullable: true }),
    (0, class_validator_1.IsOptional)(),
    (0, class_validator_1.IsEnum)(notification_types_1.NotificationStatus),
    __metadata("design:type", String)
], CreateNotificationInput.prototype, "status", void 0);
__decorate([
    (0, graphql_1.Field)(() => notification_types_1.NotificationPriority, { nullable: true }),
    (0, class_validator_1.IsOptional)(),
    (0, class_validator_1.IsEnum)(notification_types_1.NotificationPriority),
    __metadata("design:type", String)
], CreateNotificationInput.prototype, "priority", void 0);
__decorate([
    (0, graphql_1.Field)(),
    (0, class_validator_1.IsString)(),
    __metadata("design:type", String)
], CreateNotificationInput.prototype, "title", void 0);
__decorate([
    (0, graphql_1.Field)(),
    (0, class_validator_1.IsString)(),
    __metadata("design:type", String)
], CreateNotificationInput.prototype, "message", void 0);
__decorate([
    (0, graphql_1.Field)({ nullable: true }),
    (0, class_validator_1.IsOptional)(),
    (0, class_validator_1.IsString)(),
    __metadata("design:type", String)
], CreateNotificationInput.prototype, "data", void 0);
exports.CreateNotificationInput = CreateNotificationInput = __decorate([
    (0, graphql_1.InputType)()
], CreateNotificationInput);
let UpdateNotificationInput = class UpdateNotificationInput {
};
exports.UpdateNotificationInput = UpdateNotificationInput;
__decorate([
    (0, graphql_1.Field)(() => notification_types_1.NotificationType, { nullable: true }),
    (0, class_validator_1.IsOptional)(),
    (0, class_validator_1.IsEnum)(notification_types_1.NotificationType),
    __metadata("design:type", String)
], UpdateNotificationInput.prototype, "type", void 0);
__decorate([
    (0, graphql_1.Field)(() => notification_types_1.NotificationStatus, { nullable: true }),
    (0, class_validator_1.IsOptional)(),
    (0, class_validator_1.IsEnum)(notification_types_1.NotificationStatus),
    __metadata("design:type", String)
], UpdateNotificationInput.prototype, "status", void 0);
__decorate([
    (0, graphql_1.Field)(() => notification_types_1.NotificationPriority, { nullable: true }),
    (0, class_validator_1.IsOptional)(),
    (0, class_validator_1.IsEnum)(notification_types_1.NotificationPriority),
    __metadata("design:type", String)
], UpdateNotificationInput.prototype, "priority", void 0);
__decorate([
    (0, graphql_1.Field)({ nullable: true }),
    (0, class_validator_1.IsOptional)(),
    (0, class_validator_1.IsString)(),
    __metadata("design:type", String)
], UpdateNotificationInput.prototype, "title", void 0);
__decorate([
    (0, graphql_1.Field)({ nullable: true }),
    (0, class_validator_1.IsOptional)(),
    (0, class_validator_1.IsString)(),
    __metadata("design:type", String)
], UpdateNotificationInput.prototype, "message", void 0);
__decorate([
    (0, graphql_1.Field)({ nullable: true }),
    (0, class_validator_1.IsOptional)(),
    (0, class_validator_1.IsString)(),
    __metadata("design:type", String)
], UpdateNotificationInput.prototype, "data", void 0);
exports.UpdateNotificationInput = UpdateNotificationInput = __decorate([
    (0, graphql_1.InputType)()
], UpdateNotificationInput);
//# sourceMappingURL=notification.input.js.map