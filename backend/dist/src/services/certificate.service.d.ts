import { PrismaService } from './prisma.service';
export declare class CertificateService {
    private prisma;
    constructor(prisma: PrismaService);
    private mapCertificateType;
    private mapCertificateStatus;
    private mapCertificateToGraphQL;
    findAll(): Promise<any[]>;
    findOne(id: string): Promise<any>;
    findByCertificateNumber(certificateNumber: string): Promise<any>;
    findByRapidTestId(rapidTestId: string): Promise<any>;
    findByUserId(userId: string): Promise<any[]>;
    findValidByUserId(userId: string): Promise<any[]>;
    create(data: any): Promise<any>;
    update(id: string, data: any): Promise<any>;
    remove(id: string): Promise<any>;
    issue(id: string): Promise<any>;
    revoke(id: string, reason: string): Promise<any>;
    generateQRCode(id: string): Promise<string>;
    generatePDF(id: string): Promise<string>;
}
