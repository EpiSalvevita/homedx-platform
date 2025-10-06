import { User } from './user.type';
export declare enum PaymentMethod {
    CREDIT_CARD = "CREDIT_CARD",
    PAYPAL = "PAYPAL",
    BANK_TRANSFER = "BANK_TRANSFER",
    CRYPTO = "CRYPTO"
}
export declare enum PaymentStatus {
    PENDING = "PENDING",
    COMPLETED = "COMPLETED",
    FAILED = "FAILED",
    REFUNDED = "REFUNDED",
    CANCELLED = "CANCELLED"
}
export declare class Payment {
    id: string;
    userId: string;
    amount: number;
    currency: string;
    method: PaymentMethod;
    status: PaymentStatus;
    transactionId?: string;
    description?: string;
    failureReason?: string;
    createdAt: Date;
    updatedAt: Date;
    completedAt?: Date;
    user: User;
}
