import { Injectable } from '@nestjs/common';
import { PrismaService } from './prisma.service';
import { CreatePaymentInput, UpdatePaymentInput } from '../graphql/types/payment.input';
import { PaymentStatus, PaymentMethod } from '../graphql/types/payment.type';

@Injectable()
export class PaymentService {
  constructor(private prisma: PrismaService) {}

  private readonly includeRelations = {
    user: true,
  };

  private mapPaymentMethod(method: string): PaymentMethod {
    switch (method) {
      case 'CREDIT_CARD':
        return PaymentMethod.CREDIT_CARD;
      case 'PAYPAL':
        return PaymentMethod.PAYPAL;
      case 'BANK_TRANSFER':
        return PaymentMethod.BANK_TRANSFER;
      case 'CRYPTO':
        return PaymentMethod.CRYPTO;
      default:
        return PaymentMethod.CREDIT_CARD;
    }
  }

  private mapPaymentStatus(status: string): PaymentStatus {
    switch (status) {
      case 'PENDING':
        return PaymentStatus.PENDING;
      case 'COMPLETED':
        return PaymentStatus.COMPLETED;
      case 'FAILED':
        return PaymentStatus.FAILED;
      case 'REFUNDED':
        return PaymentStatus.REFUNDED;
      case 'CANCELLED':
        return PaymentStatus.CANCELLED;
      default:
        return PaymentStatus.PENDING;
    }
  }

  private mapPaymentToGraphQL(payment: any) {
    return {
      ...payment,
      method: this.mapPaymentMethod(payment.method),
      status: this.mapPaymentStatus(payment.status),
    };
  }

  async findAll() {
    const payments = await this.prisma.payment.findMany({
      include: this.includeRelations
    });
    return payments.map(payment => this.mapPaymentToGraphQL(payment));
  }

  async findOne(id: string) {
    const payment = await this.prisma.payment.findUnique({
      where: { id },
      include: this.includeRelations
    });
    return payment ? this.mapPaymentToGraphQL(payment) : null;
  }

  async findByUserId(userId: string) {
    const payments = await this.prisma.payment.findMany({
      where: { userId },
      include: this.includeRelations
    });
    return payments.map(payment => this.mapPaymentToGraphQL(payment));
  }

  async create(data: CreatePaymentInput) {
    const payment = await this.prisma.payment.create({
      data: {
        userId: data.userId,
        amount: data.amount,
        currency: data.currency,
        method: data.paymentMethod as any,
        status: 'PENDING' as any,
        transactionId: data.transactionId,
        description: `Payment for ${data.amount} ${data.currency}`,
      },
      include: this.includeRelations
    });
    return this.mapPaymentToGraphQL(payment);
  }

  async update(id: string, data: UpdatePaymentInput) {
    const updateData: any = {};
    
    if (data.amount !== undefined) updateData.amount = data.amount;
    if (data.currency !== undefined) updateData.currency = data.currency;
    if (data.status !== undefined) updateData.status = data.status as any;
    if (data.paymentMethod !== undefined) updateData.method = data.paymentMethod as any;
    if (data.transactionId !== undefined) updateData.transactionId = data.transactionId;
    
    const payment = await this.prisma.payment.update({
      where: { id },
      data: updateData,
      include: this.includeRelations
    });
    return this.mapPaymentToGraphQL(payment);
  }

  async remove(id: string) {
    const payment = await this.prisma.payment.delete({
      where: { id },
      include: this.includeRelations
    });
    return this.mapPaymentToGraphQL(payment);
  }

  async updateStatus(id: string, status: PaymentStatus) {
    const payment = await this.prisma.payment.update({
      where: { id },
      data: { status: status as any },
      include: this.includeRelations
    });
    return this.mapPaymentToGraphQL(payment);
  }
} 