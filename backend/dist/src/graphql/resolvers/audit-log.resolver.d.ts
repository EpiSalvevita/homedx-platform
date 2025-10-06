import { AuditLog } from '../types/audit-log.types';
import { CreateAuditLogInput, UpdateAuditLogInput } from '../types/audit-log.input';
import { AuditLogService } from '../../services/audit-log.service';
export declare class AuditLogResolver {
    private readonly auditLogService;
    constructor(auditLogService: AuditLogService);
    auditLogs(): Promise<AuditLog[]>;
    auditLog(id: string): Promise<AuditLog | null>;
    userAuditLogs(userId: string): Promise<AuditLog[]>;
    entityAuditLogs(entityType: string, entityId: string): Promise<AuditLog[]>;
    auditLogsByAction(action: string): Promise<AuditLog[]>;
    auditLogsByDateRange(startDate: Date, endDate: Date): Promise<AuditLog[]>;
    createAuditLog(input: CreateAuditLogInput): Promise<AuditLog>;
    updateAuditLog(id: string, input: UpdateAuditLogInput): Promise<AuditLog>;
    removeAuditLog(id: string): Promise<AuditLog>;
}
