import { Certificate } from '../types/certificate.types';
import { CreateCertificateInput, UpdateCertificateInput } from '../types/certificate.input';
import { UpdateCertificateLanguageResponse, DownloadCertificatePdfResponse } from '../types/certificate.types';
import { CertificateService } from '../../services/certificate.service';
export declare class CertificateResolver {
    private readonly certificateService;
    constructor(certificateService: CertificateService);
    certificates(): Promise<Certificate[]>;
    certificate(testId: string): Promise<Certificate | null>;
    certificateByNumber(certificateNumber: string): Promise<Certificate | null>;
    userCertificates(userId: string): Promise<Certificate[]>;
    validCertificates(userId: string): Promise<Certificate[]>;
    createCertificate(input: CreateCertificateInput): Promise<Certificate>;
    updateCertificate(id: string, input: UpdateCertificateInput): Promise<Certificate>;
    removeCertificate(id: string): Promise<Certificate>;
    issueCertificate(id: string): Promise<Certificate>;
    revokeCertificate(id: string, reason: string): Promise<Certificate>;
    generateCertificateQR(id: string): Promise<string>;
    generateCertificatePDF(id: string): Promise<string>;
    updateCertificateLanguage(testId: string, language: string): Promise<UpdateCertificateLanguageResponse>;
    downloadCertificatePdf(): Promise<DownloadCertificatePdfResponse>;
}
