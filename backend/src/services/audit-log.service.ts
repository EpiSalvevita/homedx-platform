import { Injectable } from '@nestjs/common';
import { PrismaService } from './prisma.service';
import { AuditAction, AuditEntityType } from '../graphql/types/audit-log.types';

@Injectable()
export class AuditLogService {
  constructor(private prisma: PrismaService) {}

  private mapAuditAction(action: string): AuditAction {
    switch (action) {
      case 'CREATE': return AuditAction.CREATE;
      case 'UPDATE': return AuditAction.UPDATE;
      case 'DELETE': return AuditAction.DELETE;
      case 'LOGIN': return AuditAction.LOGIN;
      case 'LOGOUT': return AuditAction.LOGOUT;
      case 'VIEW': return AuditAction.VIEW;
      case 'EXPORT': return AuditAction.EXPORT;
      default: return AuditAction.VIEW;
    }
  }

  private mapAuditEntityType(entityType: string): AuditEntityType {
    switch (entityType) {
      case 'USER': return AuditEntityType.USER;
      case 'RAPID_TEST': return AuditEntityType.RAPID_TEST;
      case 'TEST_KIT': return AuditEntityType.TEST_KIT;
      case 'PAYMENT': return AuditEntityType.PAYMENT;
      case 'CERTIFICATE': return AuditEntityType.CERTIFICATE;
      case 'LICENSE': return AuditEntityType.LICENSE;
      default: return AuditEntityType.USER;
    }
  }

  private mapAuditLogToGraphQL(auditLog: any) {
    return {
      ...auditLog,
      action: this.mapAuditAction(auditLog.action),
      entityType: this.mapAuditEntityType(auditLog.entityType),
    };
  }

  async findAll() {
    const logs = await this.prisma.auditLog.findMany({
      include: { user: true },
      orderBy: { createdAt: 'desc' },
    });
    return logs.map(log => this.mapAuditLogToGraphQL(log));
  }

  async findOne(id: string) {
    const log = await this.prisma.auditLog.findUnique({
      where: { id },
      include: { user: true },
    });
    return log ? this.mapAuditLogToGraphQL(log) : null;
  }

  async findByUserId(userId: string) {
    const logs = await this.prisma.auditLog.findMany({
      where: { userId },
      include: { user: true },
      orderBy: { createdAt: 'desc' },
    });
    return logs.map(log => this.mapAuditLogToGraphQL(log));
  }

  async findByEntity(entityType: string, entityId: string) {
    const logs = await this.prisma.auditLog.findMany({
      where: { entityType: entityType as any, entityId },
      include: { user: true },
      orderBy: { createdAt: 'desc' },
    });
    return logs.map(log => this.mapAuditLogToGraphQL(log));
  }

  async findByAction(action: string) {
    const logs = await this.prisma.auditLog.findMany({
      where: { action: action as any },
      include: { user: true },
      orderBy: { createdAt: 'desc' },
    });
    return logs.map(log => this.mapAuditLogToGraphQL(log));
  }

  async findByDateRange(startDate: Date, endDate: Date) {
    const logs = await this.prisma.auditLog.findMany({
      where: { createdAt: { gte: startDate, lte: endDate } },
      include: { user: true },
      orderBy: { createdAt: 'desc' },
    });
    return logs.map(log => this.mapAuditLogToGraphQL(log));
  }

  async create(data: any) {
    const log = await this.prisma.auditLog.create({
      data,
      include: { user: true },
    });
    return this.mapAuditLogToGraphQL(log);
  }

  async update(id: string, data: any) {
    const log = await this.prisma.auditLog.update({
      where: { id },
      data,
      include: { user: true },
    });
    return this.mapAuditLogToGraphQL(log);
  }

  async remove(id: string) {
    const log = await this.prisma.auditLog.delete({
      where: { id },
      include: { user: true },
    });
    return this.mapAuditLogToGraphQL(log);
  }
} 