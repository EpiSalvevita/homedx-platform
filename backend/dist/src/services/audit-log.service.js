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
exports.AuditLogService = void 0;
const common_1 = require("@nestjs/common");
const prisma_service_1 = require("./prisma.service");
const audit_log_types_1 = require("../graphql/types/audit-log.types");
let AuditLogService = class AuditLogService {
    constructor(prisma) {
        this.prisma = prisma;
    }
    mapAuditAction(action) {
        switch (action) {
            case 'CREATE': return audit_log_types_1.AuditAction.CREATE;
            case 'UPDATE': return audit_log_types_1.AuditAction.UPDATE;
            case 'DELETE': return audit_log_types_1.AuditAction.DELETE;
            case 'LOGIN': return audit_log_types_1.AuditAction.LOGIN;
            case 'LOGOUT': return audit_log_types_1.AuditAction.LOGOUT;
            case 'VIEW': return audit_log_types_1.AuditAction.VIEW;
            case 'EXPORT': return audit_log_types_1.AuditAction.EXPORT;
            default: return audit_log_types_1.AuditAction.VIEW;
        }
    }
    mapAuditEntityType(entityType) {
        switch (entityType) {
            case 'USER': return audit_log_types_1.AuditEntityType.USER;
            case 'RAPID_TEST': return audit_log_types_1.AuditEntityType.RAPID_TEST;
            case 'TEST_KIT': return audit_log_types_1.AuditEntityType.TEST_KIT;
            case 'PAYMENT': return audit_log_types_1.AuditEntityType.PAYMENT;
            case 'CERTIFICATE': return audit_log_types_1.AuditEntityType.CERTIFICATE;
            case 'LICENSE': return audit_log_types_1.AuditEntityType.LICENSE;
            default: return audit_log_types_1.AuditEntityType.USER;
        }
    }
    mapAuditLogToGraphQL(auditLog) {
        return Object.assign(Object.assign({}, auditLog), { action: this.mapAuditAction(auditLog.action), entityType: this.mapAuditEntityType(auditLog.entityType) });
    }
    async findAll() {
        const logs = await this.prisma.auditLog.findMany({
            include: { user: true },
            orderBy: { createdAt: 'desc' },
        });
        return logs.map(log => this.mapAuditLogToGraphQL(log));
    }
    async findOne(id) {
        const log = await this.prisma.auditLog.findUnique({
            where: { id },
            include: { user: true },
        });
        return log ? this.mapAuditLogToGraphQL(log) : null;
    }
    async findByUserId(userId) {
        const logs = await this.prisma.auditLog.findMany({
            where: { userId },
            include: { user: true },
            orderBy: { createdAt: 'desc' },
        });
        return logs.map(log => this.mapAuditLogToGraphQL(log));
    }
    async findByEntity(entityType, entityId) {
        const logs = await this.prisma.auditLog.findMany({
            where: { entityType: entityType, entityId },
            include: { user: true },
            orderBy: { createdAt: 'desc' },
        });
        return logs.map(log => this.mapAuditLogToGraphQL(log));
    }
    async findByAction(action) {
        const logs = await this.prisma.auditLog.findMany({
            where: { action: action },
            include: { user: true },
            orderBy: { createdAt: 'desc' },
        });
        return logs.map(log => this.mapAuditLogToGraphQL(log));
    }
    async findByDateRange(startDate, endDate) {
        const logs = await this.prisma.auditLog.findMany({
            where: { createdAt: { gte: startDate, lte: endDate } },
            include: { user: true },
            orderBy: { createdAt: 'desc' },
        });
        return logs.map(log => this.mapAuditLogToGraphQL(log));
    }
    async create(data) {
        const log = await this.prisma.auditLog.create({
            data,
            include: { user: true },
        });
        return this.mapAuditLogToGraphQL(log);
    }
    async update(id, data) {
        const log = await this.prisma.auditLog.update({
            where: { id },
            data,
            include: { user: true },
        });
        return this.mapAuditLogToGraphQL(log);
    }
    async remove(id) {
        const log = await this.prisma.auditLog.delete({
            where: { id },
            include: { user: true },
        });
        return this.mapAuditLogToGraphQL(log);
    }
};
exports.AuditLogService = AuditLogService;
exports.AuditLogService = AuditLogService = __decorate([
    (0, common_1.Injectable)(),
    __metadata("design:paramtypes", [prisma_service_1.PrismaService])
], AuditLogService);
//# sourceMappingURL=audit-log.service.js.map