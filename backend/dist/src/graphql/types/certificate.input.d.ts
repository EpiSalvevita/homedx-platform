import { CertificateType, CertificateStatus } from './certificate.types';
export declare class CreateCertificateInput {
    userId: string;
    rapidTestId: string;
    type: CertificateType;
    status?: CertificateStatus;
    certificateNumber: string;
    issuedAt: Date;
    validFrom: Date;
    validUntil: Date;
    qrCodeUrl?: string;
    pdfUrl?: string;
}
export declare class UpdateCertificateInput {
    type?: CertificateType;
    status?: CertificateStatus;
    issuedAt?: Date;
    validFrom?: Date;
    validUntil?: Date;
    qrCodeUrl?: string;
    pdfUrl?: string;
    revokedAt?: Date;
    revokedReason?: string;
}
