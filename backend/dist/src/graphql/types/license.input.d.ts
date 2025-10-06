import { LicenseStatus } from './license.type';
export declare class CreateLicenseInput {
    userId: string;
    maxUses: number;
    expiresAt?: Date;
    licenseKey: string;
    status: LicenseStatus;
    description?: string;
}
export declare class UpdateLicenseInput {
    maxUses?: number;
    expiresAt?: Date;
    status?: LicenseStatus;
    revokedAt?: Date;
    revokedReason?: string;
    description?: string;
}
