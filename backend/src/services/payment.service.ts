import { Injectable } from '@nestjs/common';
import { PaymentStatus, PaymentMethod, Prisma } from '@prisma/client';
import { PrismaService } from './prisma.service';
import { CreatePaymentInput, UpdatePaymentInput } from '../dto/payment.dto';

@Injectable()
export class PaymentService {
  constructor(private prisma: PrismaService) {}

  private readonly includeRelations = {
    user: true,
  };

  async findAll() {
    return this.prisma.payment.findMany({
      include: this.includeRelations,
    });
  }

  async findOne(id: string) {
    return this.prisma.payment.findUnique({
      where: { id },
      include: this.includeRelations,
    });
  }

  async findByUserId(userId: string) {
    return this.prisma.payment.findMany({
      where: { userId },
      include: this.includeRelations,
    });
  }

  async create(data: CreatePaymentInput) {
    return this.prisma.payment.create({
      data: {
        userId: data.userId,
        amount: data.amount,
        currency: data.currency,
        method: data.paymentMethod as PaymentMethod,
        status: 'PENDING',
        transactionId: data.transactionId,
        rapidTestId: data.rapidTestId,
        stripePaymentIntentId: data.paymentIntentId,
        paypalOrderId: data.paypalOrderId,
        description: `Payment for ${data.amount} ${data.currency}`,
      },
      include: this.includeRelations,
    });
  }

  async update(id: string, data: UpdatePaymentInput) {
    const updateData: Prisma.PaymentUpdateInput = {};

    if (data.amount !== undefined) updateData.amount = data.amount;
    if (data.currency !== undefined) updateData.currency = data.currency;
    if (data.status !== undefined) {
      updateData.status = data.status as PaymentStatus;
    }
    if (data.paymentMethod !== undefined) {
      updateData.method = data.paymentMethod as PaymentMethod;
    }
    if (data.transactionId !== undefined) updateData.transactionId = data.transactionId;
    if (data.paymentIntentId !== undefined) {
      updateData.stripePaymentIntentId = data.paymentIntentId;
    }
    if (data.paypalOrderId !== undefined) updateData.paypalOrderId = data.paypalOrderId;
    if (data.rapidTestId !== undefined) {
      (updateData as Prisma.PaymentUncheckedUpdateInput).rapidTestId =
        data.rapidTestId;
    }

    return this.prisma.payment.update({
      where: { id },
      data: updateData,
      include: this.includeRelations,
    });
  }

  async remove(id: string) {
    return this.prisma.payment.delete({
      where: { id },
      include: this.includeRelations,
    });
  }

  async updateStatus(id: string, status: PaymentStatus) {
    return this.prisma.payment.update({
      where: { id },
      data: { status },
      include: this.includeRelations,
    });
  }
}
