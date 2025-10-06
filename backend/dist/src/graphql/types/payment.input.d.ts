export declare class CreatePaymentInput {
    userId: string;
    amount: number;
    currency: string;
    paymentMethod: string;
    rapidTestId?: string;
    transactionId?: string;
    paymentIntentId?: string;
}
export declare class UpdatePaymentInput {
    amount?: number;
    currency?: string;
    status?: string;
    paymentMethod?: string;
    transactionId?: string;
    paymentIntentId?: string;
}
