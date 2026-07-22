import { Injectable } from '@nestjs/common';
import { PrismaService } from './prisma.service';
import { AuditAction, AuditEntityType } from '@prisma/client';

@Injectable()
export class AuditLogService {
  constructor(private prisma: PrismaService) {}

  private mapAuditAction(action: string): AuditAction {
    switch (action) {
      case 'CREATE':
        return AuditAction.CREATE;
      case 'UPDATE':
        return AuditAction.UPDATE;
      case 'DELETE':
        return AuditAction.DELETE;
      case 'LOGIN':
        return AuditAction.LOGIN;
      case 'LOGOUT':
        return AuditAction.LOGOUT;
      case 'VIEW':
        return AuditAction.VIEW;
      case 'EXPORT':
        return AuditAction.EXPORT;
      default:
        return AuditAction.VIEW;
    }
  }

  private mapAuditEntityType(entityType: string): AuditEntityType {
    switch (entityType) {
      case 'USER':
        return AuditEntityType.USER;
      case 'RAPID_TEST':
        return AuditEntityType.RAPID_TEST;
      case 'TEST_KIT':
        return AuditEntityType.TEST_KIT;
      case 'PAYMENT':
        return AuditEntityType.PAYMENT;
      case 'CERTIFICATE':
        return AuditEntityType.CERTIFICATE;
      case 'LICENSE':
        return AuditEntityType.LICENSE;
      case 'APPOINTMENT':
        return AuditEntityType.APPOINTMENT;
      case 'QUESTIONNAIRE_SUBMISSION':
        return AuditEntityType.QUESTIONNAIRE_SUBMISSION;
      default:
        return AuditEntityType.USER;
    }
  }

  async create(data: any) {
    return this.prisma.auditLog.create({
      data: {
        ...data,
        action: this.mapAuditAction(String(data.action)),
        entityType: this.mapAuditEntityType(String(data.entityType)),
      },
      include: { user: true },
    });
  }
}
