import { PrismaService } from './prisma.service';
import { CreatePaymentInput, UpdatePaymentInput } from '../graphql/types/payment.input';
import { PaymentStatus } from '../graphql/types/payment.type';
export declare class PaymentService {
    private prisma;
    constructor(prisma: PrismaService);
    private readonly includeRelations;
    private mapPaymentMethod;
    private mapPaymentStatus;
    private mapPaymentToGraphQL;
    findAll(): Promise<any[]>;
    findOne(id: string): Promise<any>;
    findByUserId(userId: string): Promise<any[]>;
    create(data: CreatePaymentInput): Promise<any>;
    update(id: string, data: UpdatePaymentInput): Promise<any>;
    remove(id: string): Promise<any>;
    updateStatus(id: string, status: PaymentStatus): Promise<any>;
}
