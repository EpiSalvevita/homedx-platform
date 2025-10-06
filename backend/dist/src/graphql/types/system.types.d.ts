export declare class SystemFlag {
    key: string;
    value: string;
}
export declare class BackendStatus {
    maintenance: boolean;
    version: string;
    flags: SystemFlag[];
    paymentIsActive: boolean;
    stripe: boolean;
    cwa: boolean;
    cwaLaive: boolean;
    certificatePdf: boolean;
}
export declare class PaymentAmount {
    amount: number;
    reducedAmount: number;
    discount: number;
    discountType: string;
}
export declare class SystemResponse {
    success: boolean;
    secret?: string;
    message?: string;
}
