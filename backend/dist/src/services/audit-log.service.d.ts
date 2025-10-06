import { PrismaService } from './prisma.service';
export declare class AuditLogService {
    private prisma;
    constructor(prisma: PrismaService);
    private mapAuditAction;
    private mapAuditEntityType;
    private mapAuditLogToGraphQL;
    findAll(): Promise<any[]>;
    findOne(id: string): Promise<any>;
    findByUserId(userId: string): Promise<any[]>;
    findByEntity(entityType: string, entityId: string): Promise<any[]>;
    findByAction(action: string): Promise<any[]>;
    findByDateRange(startDate: Date, endDate: Date): Promise<any[]>;
    create(data: any): Promise<any>;
    update(id: string, data: any): Promise<any>;
    remove(id: string): Promise<any>;
}
