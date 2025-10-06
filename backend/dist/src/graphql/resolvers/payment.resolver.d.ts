import { Payment, PaymentStatus } from '../types/payment.type';
import { CreatePaymentInput, UpdatePaymentInput } from '../types/payment.input';
import { PaymentService } from '../../services/payment.service';
export declare class PaymentResolver {
    private readonly paymentService;
    constructor(paymentService: PaymentService);
    payments(): Promise<Payment[]>;
    payment(id: string): Promise<Payment | null>;
    userPayments(userId: string): Promise<Payment[]>;
    createPayment(input: CreatePaymentInput): Promise<Payment>;
    updatePayment(id: string, input: UpdatePaymentInput): Promise<Payment>;
    removePayment(id: string): Promise<Payment>;
    updatePaymentStatus(id: string, status: PaymentStatus): Promise<Payment>;
}
