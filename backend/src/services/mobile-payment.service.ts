import {
  BadRequestException,
  ForbiddenException,
  Injectable,
  NotFoundException,
} from '@nestjs/common';
import { PaymentService } from './payment.service';
import { StripeService } from './stripe.service';
import { PayPalService } from './paypal.service';
import { PrismaService } from './prisma.service';
import { MobileNotificationService } from './mobile-notification.service';

export interface MobilePaymentLineItem {
  productId: string;
  name: string;
  quantity: number;
  unitPrice: number;
}

export interface MobilePaymentRecord {
  id: string;
  userId: string;
  amount: number;
  currency: string;
  method: string;
  status: string;
  description?: string | null;
  lineItems?: MobilePaymentLineItem[] | null;
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
  private static readonly DEFAULT_CURRENCY = 'EUR';

  constructor(
    private readonly paymentService: PaymentService,
    private readonly stripeService: StripeService,
    private readonly paypalService: PayPalService,
    private readonly prisma: PrismaService,
    private readonly mobileNotificationService: MobileNotificationService,
  ) {}

  getPaymentAmount() {
    return {
      amount: 29.99,
      reducedAmount: 24.99,
      discount: 5.0,
      discountType: 'percentage',
    };
  }

  private getServerChargeAmount(): number {
    const pricing = this.getPaymentAmount();
    return pricing.reducedAmount ?? pricing.amount;
  }

  async createPayment(
    userId: string,
    body: {
      paymentMethod?: string;
      rapidTestId?: string;
      items?: Array<{
        productId: string;
        name: string;
        quantity: number;
        unitPrice: number;
      }>;
    },
  ): Promise<MobilePaymentRecord> {
    const lineItems = this.normalizeLineItems(body.items);
    const amount = lineItems.length
      ? this.amountFromLineItems(lineItems)
      : this.getServerChargeAmount();

    if (amount <= 0) {
      throw new BadRequestException('Ungültiger Betrag');
    }

    const description = lineItems.length
      ? lineItems.map((i) => `${i.quantity}× ${i.name}`).join(', ')
      : undefined;

    const payment = await this.paymentService.create({
      userId,
      amount,
      currency: MobilePaymentService.DEFAULT_CURRENCY,
      paymentMethod: body.paymentMethod ?? 'CREDIT_CARD',
      rapidTestId: body.rapidTestId,
      description,
      lineItems: lineItems.length ? lineItems : undefined,
    });
    return this.toMobilePayment(payment);
  }

  async getPayment(userId: string, paymentId: string): Promise<MobilePaymentRecord> {
    await this.assertPaymentOwner(paymentId, userId);
    const payment = await this.prisma.payment.findUnique({ where: { id: paymentId } });
    if (!payment) {
      throw new NotFoundException('Payment not found');
    }
    return this.toMobilePayment(payment);
  }

  async createStripePaymentIntent(
    userId: string,
    body: { paymentId: string },
  ): Promise<{ clientSecret: string; paymentIntentId: string }> {
    const payment = await this.assertPaymentOwner(body.paymentId, userId);

    const { clientSecret, paymentIntentId } = await this.stripeService.createPaymentIntent(
      payment.amount,
      payment.currency,
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
      returnUrl?: string;
      cancelUrl?: string;
    },
  ): Promise<{ orderId: string; approvalUrl: string }> {
    let amount = this.getServerChargeAmount();
    let currency = MobilePaymentService.DEFAULT_CURRENCY;

    if (body.paymentId) {
      const payment = await this.assertPaymentOwner(body.paymentId, userId);
      amount = payment.amount;
      currency = payment.currency;
    }

    const order = await this.paypalService.createOrder(
      amount,
      currency,
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
      paymentIntentId?: string;
      paypalOrderId?: string;
    },
  ): Promise<MobilePaymentRecord> {
    await this.assertPaymentOwner(body.paymentId, userId);

    const payment = await this.paymentService.update(body.paymentId, {
      paymentIntentId: body.paymentIntentId,
      paypalOrderId: body.paypalOrderId,
    });

    return this.toMobilePayment(payment);
  }

  async confirmStripePayment(userId: string, paymentId: string): Promise<MobilePaymentRecord> {
    const payment = await this.assertPaymentOwner(paymentId, userId);

    if (payment.status === 'COMPLETED') {
      return this.toMobilePayment(payment);
    }

    const intentId = payment.stripePaymentIntentId;
    if (!intentId) {
      throw new BadRequestException('No Stripe payment intent linked to this payment');
    }

    const intent = await this.stripeService.getPaymentIntent(intentId);
    if (intent.status !== 'succeeded') {
      throw new BadRequestException(`Payment not completed (status: ${intent.status})`);
    }

    await this.markPaymentCompleted(payment.id, payment.userId, intentId);
    const updated = await this.prisma.payment.findUnique({ where: { id: paymentId } });
    return this.toMobilePayment(updated!);
  }

  async capturePayPalOrder(
    userId: string,
    paymentId: string,
    paypalOrderId?: string,
  ): Promise<MobilePaymentRecord> {
    const payment = await this.assertPaymentOwner(paymentId, userId);

    if (payment.status === 'COMPLETED') {
      return this.toMobilePayment(payment);
    }

    const orderId = paypalOrderId ?? payment.paypalOrderId;
    if (!orderId) {
      throw new BadRequestException('No PayPal order linked to this payment');
    }

    if (payment.paypalOrderId && payment.paypalOrderId !== orderId) {
      throw new BadRequestException('PayPal order does not match this payment');
    }

    await this.paypalService.captureOrder(orderId);
    await this.markPaymentCompleted(payment.id, payment.userId, orderId);

    const updated = await this.prisma.payment.findUnique({ where: { id: paymentId } });
    return this.toMobilePayment(updated!);
  }

  async listByUserId(userId: string): Promise<MobilePaymentRecord[]> {
    const payments = await this.paymentService.findByUserId(userId);
    return payments.map((p) => this.toMobilePayment(p));
  }

  async markPaymentCompletedFromStripeIntent(paymentIntentId: string): Promise<void> {
    const payment = await this.prisma.payment.findFirst({
      where: { stripePaymentIntentId: paymentIntentId },
    });

    if (payment) {
      if (payment.status === 'COMPLETED') {
        return;
      }
      await this.markPaymentCompleted(payment.id, payment.userId, paymentIntentId);
      return;
    }

    const intent = await this.stripeService.getPaymentIntent(paymentIntentId);
    const paymentId = intent.metadata?.paymentId;
    if (!paymentId) {
      return;
    }

    const linked = await this.prisma.payment.findUnique({ where: { id: paymentId } });
    if (!linked || linked.status === 'COMPLETED') {
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
    await this.mobileNotificationService.notifyUser(linked.userId, {
      type: 'PAYMENT_SUCCESS',
      title: 'Zahlung erfolgreich',
      message: 'Ihre Zahlung wurde bestätigt.',
      data: { paymentId: linked.id },
    });
  }

  async markPaymentCompletedFromPayPalOrder(orderId: string): Promise<void> {
    const payment = await this.prisma.payment.findFirst({
      where: { paypalOrderId: orderId },
    });
    if (!payment || payment.status === 'COMPLETED') {
      return;
    }

    try {
      await this.paypalService.captureOrder(orderId);
    } catch (error) {
      const order = await this.paypalService.getOrder(orderId);
      const captureStatus = order?.purchase_units?.[0]?.payments?.captures?.[0]?.status;
      if (captureStatus !== 'COMPLETED') {
        throw error;
      }
    }

    await this.markPaymentCompleted(payment.id, payment.userId, orderId);
  }

  private async markPaymentCompleted(
    paymentId: string,
    userId: string,
    transactionId: string,
  ): Promise<void> {
    const payment = await this.prisma.payment.update({
      where: { id: paymentId },
      data: {
        status: 'COMPLETED',
        transactionId,
        completedAt: new Date(),
      },
    });

    await this.mobileNotificationService.notifyUser(userId, {
      type: 'PAYMENT_SUCCESS',
      title: 'Zahlung erfolgreich',
      message: `Ihre Zahlung über ${payment.amount} ${payment.currency} wurde bestätigt.`,
      data: { paymentId: payment.id },
    });
  }

  private async assertPaymentOwner(paymentId: string, userId: string) {
    const payment = await this.prisma.payment.findUnique({ where: { id: paymentId } });
    if (!payment || payment.userId !== userId) {
      throw new ForbiddenException('Payment not found');
    }
    return payment;
  }

  private normalizeLineItems(
    items?: Array<{
      productId: string;
      name: string;
      quantity: number;
      unitPrice: number;
    }>,
  ): MobilePaymentLineItem[] {
    if (!items?.length) return [];
    return items
      .map((item) => ({
        productId: String(item.productId ?? '').trim(),
        name: String(item.name ?? '').trim(),
        quantity: Math.max(1, Math.floor(Number(item.quantity) || 0)),
        unitPrice: Math.round((Number(item.unitPrice) || 0) * 100) / 100,
      }))
      .filter((item) => item.productId && item.name && item.unitPrice >= 0);
  }

  private amountFromLineItems(items: MobilePaymentLineItem[]): number {
    const total = items.reduce(
      (sum, item) => sum + item.quantity * item.unitPrice,
      0,
    );
    return Math.round(total * 100) / 100;
  }

  private parseLineItems(raw: unknown): MobilePaymentLineItem[] | null {
    if (!Array.isArray(raw)) return null;
    const items = this.normalizeLineItems(
      raw as Array<{
        productId: string;
        name: string;
        quantity: number;
        unitPrice: number;
      }>,
    );
    return items.length ? items : null;
  }

  private toMobilePayment(payment: {
    id: string;
    userId: string;
    amount: number;
    currency: string;
    method: string;
    status: string;
    description?: string | null;
    lineItems?: unknown;
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
      lineItems: this.parseLineItems(payment.lineItems),
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
