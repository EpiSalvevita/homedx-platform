import { PrismaService } from './prisma.service';
export declare class LicenseService {
    private prisma;
    constructor(prisma: PrismaService);
    private mapLicenseStatus;
    private mapLicenseToGraphQL;
    findAll(): Promise<any[]>;
    findOne(id: string): Promise<any>;
    findByUserId(userId: string): Promise<any[]>;
    findByLicenseKey(licenseKey: string): Promise<any>;
    create(data: any): Promise<any>;
    update(id: string, data: any): Promise<any>;
    remove(id: string): Promise<any>;
    incrementUsesCount(id: string): Promise<any>;
}
