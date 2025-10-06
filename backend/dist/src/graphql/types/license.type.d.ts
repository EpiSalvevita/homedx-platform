import { User } from './user.type';
export declare enum LicenseStatus {
    ACTIVE = "ACTIVE",
    EXPIRED = "EXPIRED",
    REVOKED = "REVOKED"
}
export declare class License {
    id: string;
    userId: string;
    maxUses: number;
    usesCount: number;
    expiresAt?: Date;
    createdAt: Date;
    updatedAt: Date;
    licenseKey: string;
    revokedAt?: Date;
    revokedReason?: string;
    status: LicenseStatus;
    description?: string;
    user?: User;
}
