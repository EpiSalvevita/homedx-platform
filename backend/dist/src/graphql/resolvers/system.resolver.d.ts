import { BackendStatus, PaymentAmount, SystemResponse } from '../types/system.types';
export declare class SystemResolver {
    backendStatus(): Promise<BackendStatus>;
    paymentAmount(): Promise<PaymentAmount>;
    countryCodes(): Promise<string[]>;
    profileImage(): Promise<string>;
    qrCode(): Promise<string>;
    createPaymentIntent(): Promise<SystemResponse>;
    resetAuthentication(): Promise<SystemResponse>;
    resetCWALink(): Promise<SystemResponse>;
}
