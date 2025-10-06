import { User } from './user.type';
import { RapidTest } from './rapid-test.type';
export declare enum CertificateType {
    TEST_RESULT = "TEST_RESULT",
    VACCINATION = "VACCINATION",
    RECOVERY = "RECOVERY",
    MEDICAL_CLEARANCE = "MEDICAL_CLEARANCE"
}
export declare enum CertificateStatus {
    DRAFT = "DRAFT",
    ISSUED = "ISSUED",
    EXPIRED = "EXPIRED",
    REVOKED = "REVOKED"
}
export declare class Certificate {
    id: string;
    userId: string;
    rapidTestId: string;
    type: CertificateType;
    status: CertificateStatus;
    certificateNumber: string;
    issuedAt: Date;
    validFrom: Date;
    validUntil: Date;
    qrCodeUrl?: string;
    pdfUrl?: string;
    revokedAt?: Date;
    revokedReason?: string;
    createdAt: Date;
    updatedAt: Date;
    user: User;
    rapidTest: RapidTest;
}
export declare class CertificatePdf {
    url: string;
    language: string;
}
export declare class CertificateWithPdf {
    id: string;
    pdf?: CertificatePdf;
}
export declare class UpdateCertificateLanguageResponse {
    success: boolean;
    certificate?: CertificateWithPdf;
    message?: string;
}
export declare class DownloadCertificatePdfResponse {
    success: boolean;
    pdf?: string;
    message?: string;
}
