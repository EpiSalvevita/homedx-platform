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
exports.UpdateAuditLogInput = exports.CreateAuditLogInput = void 0;
const graphql_1 = require("@nestjs/graphql");
const class_validator_1 = require("class-validator");
const audit_log_types_1 = require("./audit-log.types");
let CreateAuditLogInput = class CreateAuditLogInput {
};
exports.CreateAuditLogInput = CreateAuditLogInput;
__decorate([
    (0, graphql_1.Field)(),
    (0, class_validator_1.IsString)(),
    __metadata("design:type", String)
], CreateAuditLogInput.prototype, "userId", void 0);
__decorate([
    (0, graphql_1.Field)(() => audit_log_types_1.AuditAction),
    (0, class_validator_1.IsEnum)(audit_log_types_1.AuditAction),
    __metadata("design:type", String)
], CreateAuditLogInput.prototype, "action", void 0);
__decorate([
    (0, graphql_1.Field)(() => audit_log_types_1.AuditEntityType),
    (0, class_validator_1.IsEnum)(audit_log_types_1.AuditEntityType),
    __metadata("design:type", String)
], CreateAuditLogInput.prototype, "entityType", void 0);
__decorate([
    (0, graphql_1.Field)({ nullable: true }),
    (0, class_validator_1.IsOptional)(),
    (0, class_validator_1.IsString)(),
    __metadata("design:type", String)
], CreateAuditLogInput.prototype, "entityId", void 0);
__decorate([
    (0, graphql_1.Field)({ nullable: true }),
    (0, class_validator_1.IsOptional)(),
    (0, class_validator_1.IsString)(),
    __metadata("design:type", String)
], CreateAuditLogInput.prototype, "oldValues", void 0);
__decorate([
    (0, graphql_1.Field)({ nullable: true }),
    (0, class_validator_1.IsOptional)(),
    (0, class_validator_1.IsString)(),
    __metadata("design:type", String)
], CreateAuditLogInput.prototype, "newValues", void 0);
__decorate([
    (0, graphql_1.Field)({ nullable: true }),
    (0, class_validator_1.IsOptional)(),
    (0, class_validator_1.IsString)(),
    __metadata("design:type", String)
], CreateAuditLogInput.prototype, "ipAddress", void 0);
__decorate([
    (0, graphql_1.Field)({ nullable: true }),
    (0, class_validator_1.IsOptional)(),
    (0, class_validator_1.IsString)(),
    __metadata("design:type", String)
], CreateAuditLogInput.prototype, "userAgent", void 0);
__decorate([
    (0, graphql_1.Field)({ nullable: true }),
    (0, class_validator_1.IsOptional)(),
    (0, class_validator_1.IsString)(),
    __metadata("design:type", String)
], CreateAuditLogInput.prototype, "description", void 0);
exports.CreateAuditLogInput = CreateAuditLogInput = __decorate([
    (0, graphql_1.InputType)()
], CreateAuditLogInput);
let UpdateAuditLogInput = class UpdateAuditLogInput {
};
exports.UpdateAuditLogInput = UpdateAuditLogInput;
__decorate([
    (0, graphql_1.Field)({ nullable: true }),
    (0, class_validator_1.IsOptional)(),
    (0, class_validator_1.IsString)(),
    __metadata("design:type", String)
], UpdateAuditLogInput.prototype, "oldValues", void 0);
__decorate([
    (0, graphql_1.Field)({ nullable: true }),
    (0, class_validator_1.IsOptional)(),
    (0, class_validator_1.IsString)(),
    __metadata("design:type", String)
], UpdateAuditLogInput.prototype, "newValues", void 0);
__decorate([
    (0, graphql_1.Field)({ nullable: true }),
    (0, class_validator_1.IsOptional)(),
    (0, class_validator_1.IsString)(),
    __metadata("design:type", String)
], UpdateAuditLogInput.prototype, "ipAddress", void 0);
__decorate([
    (0, graphql_1.Field)({ nullable: true }),
    (0, class_validator_1.IsOptional)(),
    (0, class_validator_1.IsString)(),
    __metadata("design:type", String)
], UpdateAuditLogInput.prototype, "userAgent", void 0);
__decorate([
    (0, graphql_1.Field)({ nullable: true }),
    (0, class_validator_1.IsOptional)(),
    (0, class_validator_1.IsString)(),
    __metadata("design:type", String)
], UpdateAuditLogInput.prototype, "description", void 0);
exports.UpdateAuditLogInput = UpdateAuditLogInput = __decorate([
    (0, graphql_1.InputType)()
], UpdateAuditLogInput);
//# sourceMappingURL=audit-log.input.js.map