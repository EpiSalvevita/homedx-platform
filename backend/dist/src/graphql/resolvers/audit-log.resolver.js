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
exports.AuditLogResolver = void 0;
const graphql_1 = require("@nestjs/graphql");
const audit_log_types_1 = require("../types/audit-log.types");
const audit_log_input_1 = require("../types/audit-log.input");
const audit_log_service_1 = require("../../services/audit-log.service");
let AuditLogResolver = class AuditLogResolver {
    constructor(auditLogService) {
        this.auditLogService = auditLogService;
    }
    async auditLogs() {
        return this.auditLogService.findAll();
    }
    async auditLog(id) {
        return this.auditLogService.findOne(id);
    }
    async userAuditLogs(userId) {
        return this.auditLogService.findByUserId(userId);
    }
    async entityAuditLogs(entityType, entityId) {
        return this.auditLogService.findByEntity(entityType, entityId);
    }
    async auditLogsByAction(action) {
        return this.auditLogService.findByAction(action);
    }
    async auditLogsByDateRange(startDate, endDate) {
        return this.auditLogService.findByDateRange(startDate, endDate);
    }
    async createAuditLog(input) {
        return this.auditLogService.create(input);
    }
    async updateAuditLog(id, input) {
        return this.auditLogService.update(id, input);
    }
    async removeAuditLog(id) {
        return this.auditLogService.remove(id);
    }
};
exports.AuditLogResolver = AuditLogResolver;
__decorate([
    (0, graphql_1.Query)(() => [audit_log_types_1.AuditLog]),
    __metadata("design:type", Function),
    __metadata("design:paramtypes", []),
    __metadata("design:returntype", Promise)
], AuditLogResolver.prototype, "auditLogs", null);
__decorate([
    (0, graphql_1.Query)(() => audit_log_types_1.AuditLog, { nullable: true }),
    __param(0, (0, graphql_1.Args)('id')),
    __metadata("design:type", Function),
    __metadata("design:paramtypes", [String]),
    __metadata("design:returntype", Promise)
], AuditLogResolver.prototype, "auditLog", null);
__decorate([
    (0, graphql_1.Query)(() => [audit_log_types_1.AuditLog]),
    __param(0, (0, graphql_1.Args)('userId')),
    __metadata("design:type", Function),
    __metadata("design:paramtypes", [String]),
    __metadata("design:returntype", Promise)
], AuditLogResolver.prototype, "userAuditLogs", null);
__decorate([
    (0, graphql_1.Query)(() => [audit_log_types_1.AuditLog]),
    __param(0, (0, graphql_1.Args)('entityType')),
    __param(1, (0, graphql_1.Args)('entityId')),
    __metadata("design:type", Function),
    __metadata("design:paramtypes", [String, String]),
    __metadata("design:returntype", Promise)
], AuditLogResolver.prototype, "entityAuditLogs", null);
__decorate([
    (0, graphql_1.Query)(() => [audit_log_types_1.AuditLog]),
    __param(0, (0, graphql_1.Args)('action')),
    __metadata("design:type", Function),
    __metadata("design:paramtypes", [String]),
    __metadata("design:returntype", Promise)
], AuditLogResolver.prototype, "auditLogsByAction", null);
__decorate([
    (0, graphql_1.Query)(() => [audit_log_types_1.AuditLog]),
    __param(0, (0, graphql_1.Args)('startDate')),
    __param(1, (0, graphql_1.Args)('endDate')),
    __metadata("design:type", Function),
    __metadata("design:paramtypes", [Date,
        Date]),
    __metadata("design:returntype", Promise)
], AuditLogResolver.prototype, "auditLogsByDateRange", null);
__decorate([
    (0, graphql_1.Mutation)(() => audit_log_types_1.AuditLog),
    __param(0, (0, graphql_1.Args)('input')),
    __metadata("design:type", Function),
    __metadata("design:paramtypes", [audit_log_input_1.CreateAuditLogInput]),
    __metadata("design:returntype", Promise)
], AuditLogResolver.prototype, "createAuditLog", null);
__decorate([
    (0, graphql_1.Mutation)(() => audit_log_types_1.AuditLog),
    __param(0, (0, graphql_1.Args)('id')),
    __param(1, (0, graphql_1.Args)('input')),
    __metadata("design:type", Function),
    __metadata("design:paramtypes", [String, audit_log_input_1.UpdateAuditLogInput]),
    __metadata("design:returntype", Promise)
], AuditLogResolver.prototype, "updateAuditLog", null);
__decorate([
    (0, graphql_1.Mutation)(() => audit_log_types_1.AuditLog),
    __param(0, (0, graphql_1.Args)('id')),
    __metadata("design:type", Function),
    __metadata("design:paramtypes", [String]),
    __metadata("design:returntype", Promise)
], AuditLogResolver.prototype, "removeAuditLog", null);
exports.AuditLogResolver = AuditLogResolver = __decorate([
    (0, graphql_1.Resolver)(() => audit_log_types_1.AuditLog),
    __metadata("design:paramtypes", [audit_log_service_1.AuditLogService])
], AuditLogResolver);
//# sourceMappingURL=audit-log.resolver.js.map