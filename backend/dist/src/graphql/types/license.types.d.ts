import { License } from './license.type';
export declare class ActivateLicenseResponse {
    success: boolean;
    license?: License;
    message?: string;
}
export declare class AssignCouponResponse {
    success: boolean;
    licenseCode?: string;
    message?: string;
}
