import { AuditAction, AuditEntityType } from './audit-log.types';
export declare class CreateAuditLogInput {
    userId: string;
    action: AuditAction;
    entityType: AuditEntityType;
    entityId?: string;
    oldValues?: string;
    newValues?: string;
    ipAddress?: string;
    userAgent?: string;
    description?: string;
}
export declare class UpdateAuditLogInput {
    oldValues?: string;
    newValues?: string;
    ipAddress?: string;
    userAgent?: string;
    description?: string;
}
