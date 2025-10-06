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
exports.AuditLog = exports.AuditEntityType = exports.AuditAction = void 0;
const graphql_1 = require("@nestjs/graphql");
const user_type_1 = require("./user.type");
var AuditAction;
(function (AuditAction) {
    AuditAction["CREATE"] = "CREATE";
    AuditAction["UPDATE"] = "UPDATE";
    AuditAction["DELETE"] = "DELETE";
    AuditAction["LOGIN"] = "LOGIN";
    AuditAction["LOGOUT"] = "LOGOUT";
    AuditAction["VIEW"] = "VIEW";
    AuditAction["EXPORT"] = "EXPORT";
})(AuditAction || (exports.AuditAction = AuditAction = {}));
var AuditEntityType;
(function (AuditEntityType) {
    AuditEntityType["USER"] = "USER";
    AuditEntityType["RAPID_TEST"] = "RAPID_TEST";
    AuditEntityType["TEST_KIT"] = "TEST_KIT";
    AuditEntityType["PAYMENT"] = "PAYMENT";
    AuditEntityType["CERTIFICATE"] = "CERTIFICATE";
    AuditEntityType["LICENSE"] = "LICENSE";
})(AuditEntityType || (exports.AuditEntityType = AuditEntityType = {}));
(0, graphql_1.registerEnumType)(AuditAction, {
    name: 'AuditAction',
    description: 'Audit action enumeration',
});
(0, graphql_1.registerEnumType)(AuditEntityType, {
    name: 'AuditEntityType',
    description: 'Audit entity type enumeration',
});
let AuditLog = class AuditLog {
};
exports.AuditLog = AuditLog;
__decorate([
    (0, graphql_1.Field)(),
    __metadata("design:type", String)
], AuditLog.prototype, "id", void 0);
__decorate([
    (0, graphql_1.Field)(),
    __metadata("design:type", String)
], AuditLog.prototype, "userId", void 0);
__decorate([
    (0, graphql_1.Field)(() => AuditAction),
    __metadata("design:type", String)
], AuditLog.prototype, "action", void 0);
__decorate([
    (0, graphql_1.Field)(() => AuditEntityType),
    __metadata("design:type", String)
], AuditLog.prototype, "entityType", void 0);
__decorate([
    (0, graphql_1.Field)({ nullable: true }),
    __metadata("design:type", String)
], AuditLog.prototype, "entityId", void 0);
__decorate([
    (0, graphql_1.Field)({ nullable: true }),
    __metadata("design:type", String)
], AuditLog.prototype, "oldValues", void 0);
__decorate([
    (0, graphql_1.Field)({ nullable: true }),
    __metadata("design:type", String)
], AuditLog.prototype, "newValues", void 0);
__decorate([
    (0, graphql_1.Field)({ nullable: true }),
    __metadata("design:type", String)
], AuditLog.prototype, "ipAddress", void 0);
__decorate([
    (0, graphql_1.Field)({ nullable: true }),
    __metadata("design:type", String)
], AuditLog.prototype, "userAgent", void 0);
__decorate([
    (0, graphql_1.Field)({ nullable: true }),
    __metadata("design:type", String)
], AuditLog.prototype, "description", void 0);
__decorate([
    (0, graphql_1.Field)(),
    __metadata("design:type", Date)
], AuditLog.prototype, "createdAt", void 0);
__decorate([
    (0, graphql_1.Field)(() => user_type_1.User),
    __metadata("design:type", user_type_1.User)
], AuditLog.prototype, "user", void 0);
exports.AuditLog = AuditLog = __decorate([
    (0, graphql_1.ObjectType)()
], AuditLog);
//# sourceMappingURL=audit-log.types.js.map