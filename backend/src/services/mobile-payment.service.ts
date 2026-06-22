import { ForbiddenException, Injectable } from '@nestjs/common';
import { PaymentService } from './payment.service';
import { StripeService } from './stripe.service';
import { PayPalService } from './paypal.service';
import { PrismaService } from './prisma.service';

export interface MobilePaymentRecord {
  id: string;
  userId: string;
  amount: number;
  currency: string;
  method: string;
  status: string;
  description?: string | null;
  transactionId?: string | null;
  rapidTestId?: string | null;
  stripePaymentIntentId?: string | null;
  paypalOrderId?: string | null;
  createdAt: string;
  updatedAt: string;
  completedAt?: string | null;
  failureReason?: string | null;
}

@Injectable()
export class MobilePaymentService {
  constructor(
    private readonly paymentService: PaymentService,
    private readonly stripeService: StripeService,
    private readonly paypalService: PayPalService,
    private readonly prisma: PrismaService,
  ) {}

  getPaymentAmount() {
    return {
      amount: 29.99,
      reducedAmount: 24.99,
      discount: 5.0,
      discountType: 'percentage',
    };
  }

  async createPayment(
    userId: string,
    body: {
      amount: number;
      currency: string;
      paymentMethod: string;
      rapidTestId?: string;
    },
  ): Promise<MobilePaymentRecord> {
    const payment = await this.paymentService.create({
      userId,
      amount: body.amount,
      currency: body.currency,
      paymentMethod: body.paymentMethod,
      rapidTestId: body.rapidTestId,
    });
    return this.toMobilePayment(payment);
  }

  async createStripePaymentIntent(
    userId: string,
    body: { paymentId: string; amount: number; currency: string },
  ): Promise<{ clientSecret: string; paymentIntentId: string }> {
    await this.assertPaymentOwner(body.paymentId, userId);

    const { clientSecret, paymentIntentId } = await this.stripeService.createPaymentIntent(
      body.amount,
      body.currency,
      { paymentId: body.paymentId },
    );

    await this.paymentService.update(body.paymentId, {
      paymentIntentId: paymentIntentId,
    });

    return { clientSecret, paymentIntentId };
  }

  async createPayPalOrder(
    userId: string,
    body: {
      paymentId?: string;
      amount: number;
      currency: string;
      returnUrl?: string;
      cancelUrl?: string;
    },
  ): Promise<{ orderId: string; approvalUrl: string }> {
    if (body.paymentId) {
      await this.assertPaymentOwner(body.paymentId, userId);
    }

    const order = await this.paypalService.createOrder(
      body.amount,
      body.currency,
      body.returnUrl,
      body.cancelUrl,
      body.paymentId ? { paymentId: body.paymentId } : undefined,
    );

    if (body.paymentId) {
      await this.paymentService.update(body.paymentId, {
        paypalOrderId: order.orderId,
      });
    }

    return order;
  }

  async updatePayment(
    userId: string,
    body: {
      paymentId: string;
      transactionId?: string;
      status?: string;
      paymentIntentId?: string;
      paypalOrderId?: string;
    },
  ): Promise<MobilePaymentRecord> {
    await this.assertPaymentOwner(body.paymentId, userId);

    const payment = await this.paymentService.update(body.paymentId, {
      transactionId: body.transactionId,
      status: body.status,
      paymentIntentId: body.paymentIntentId,
      paypalOrderId: body.paypalOrderId,
    });

    return this.toMobilePayment(payment);
  }

  async markPaymentCompletedFromStripeIntent(paymentIntentId: string): Promise<void> {
    const payment = await this.prisma.payment.findFirst({
      where: { stripePaymentIntentId: paymentIntentId },
    });

    if (payment) {
      await this.prisma.payment.update({
        where: { id: payment.id },
        data: {
          status: 'COMPLETED',
          transactionId: paymentIntentId,
          completedAt: new Date(),
        },
      });
      return;
    }

    const intent = await this.stripeService.getPaymentIntent(paymentIntentId);
    const paymentId = intent.metadata?.paymentId;
    if (!paymentId) {
      return;
    }

    await this.prisma.payment.update({
      where: { id: paymentId },
      data: {
        status: 'COMPLETED',
        transactionId: paymentIntentId,
        stripePaymentIntentId: paymentIntentId,
        completedAt: new Date(),
      },
    });
  }

  async markPaymentCompletedFromPayPalOrder(orderId: string): Promise<void> {
    const payment = await this.prisma.payment.findFirst({
      where: { paypalOrderId: orderId },
    });
    if (!payment) {
      return;
    }

    await this.prisma.payment.update({
      where: { id: payment.id },
      data: {
        status: 'COMPLETED',
        transactionId: orderId,
        completedAt: new Date(),
      },
    });
  }

  private async assertPaymentOwner(paymentId: string, userId: string): Promise<void> {
    const payment = await this.prisma.payment.findUnique({ where: { id: paymentId } });
    if (!payment || payment.userId !== userId) {
      throw new ForbiddenException('Payment not found');
    }
  }

  private toMobilePayment(payment: {
    id: string;
    userId: string;
    amount: number;
    currency: string;
    method: string;
    status: string;
    description?: string | null;
    transactionId?: string | null;
    rapidTestId?: string | null;
    stripePaymentIntentId?: string | null;
    paypalOrderId?: string | null;
    createdAt: Date;
    updatedAt: Date;
    completedAt?: Date | null;
    failureReason?: string | null;
  }): MobilePaymentRecord {
    return {
      id: payment.id,
      userId: payment.userId,
      amount: payment.amount,
      currency: payment.currency,
      method: payment.method,
      status: payment.status,
      description: payment.description,
      transactionId: payment.transactionId,
      rapidTestId: payment.rapidTestId,
      stripePaymentIntentId: payment.stripePaymentIntentId,
      paypalOrderId: payment.paypalOrderId,
      createdAt: payment.createdAt.toISOString(),
      updatedAt: payment.updatedAt.toISOString(),
      completedAt: payment.completedAt?.toISOString() ?? null,
      failureReason: payment.failureReason,
    };
  }
}
