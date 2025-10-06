import { PrismaService } from './prisma.service';
export declare class TestKitService {
    private prisma;
    constructor(prisma: PrismaService);
    private mapTestKitType;
    private mapTestKitStatus;
    private mapTestKitToGraphQL;
    findAll(): Promise<any[]>;
    findOne(id: string): Promise<any>;
    findBySerialNumber(serialNumber: string): Promise<any>;
    findAvailable(): Promise<any[]>;
    findByUserId(userId: string): Promise<any[]>;
    create(data: any): Promise<any>;
    update(id: string, data: any): Promise<any>;
    remove(id: string): Promise<any>;
    assignToUser(id: string, userId: string): Promise<any>;
    markAsUsed(id: string): Promise<any>;
}
