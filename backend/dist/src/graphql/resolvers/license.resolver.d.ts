import { License } from '../types/license.type';
import { ActivateLicenseResponse, AssignCouponResponse } from '../types/license.types';
import { LicenseService } from '../../services/license.service';
export declare class LicenseResolver {
    private readonly licenseService;
    constructor(licenseService: LicenseService);
    licenses(): Promise<License[]>;
    license(id: string): Promise<License | null>;
    userLicenses(userId: string): Promise<License[]>;
    createLicense(userId: string, licenseKey: string, status: string, maxUses: number): Promise<License>;
    updateLicense(id: string, maxUses?: number, status?: string): Promise<License>;
    removeLicense(id: string): Promise<License>;
    incrementLicenseUses(id: string): Promise<License>;
    activateLicense(code: string): Promise<ActivateLicenseResponse>;
    assignCoupon(licenseCode: string): Promise<AssignCouponResponse>;
}
