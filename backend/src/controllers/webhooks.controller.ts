import {
  Controller,
  Post,
  Req,
  Headers,
  HttpCode,
  Logger,
  BadRequestException,
} from '@nestjs/common';
import { SkipThrottle } from '@nestjs/throttler';
import type { RawBodyRequest } from '@nestjs/common';
import type { Request } from 'express';
import { Public } from '../auth/public.decorator';
import { StripeService } from '../services/stripe.service';
import { MobilePaymentService } from '../services/mobile-payment.service';
import Stripe from 'stripe';

@SkipThrottle()
@Controller('webhooks')
export class WebhooksController {
  private readonly logger = new Logger(WebhooksController.name);

  constructor(
    private readonly stripeService: StripeService,
    private readonly mobilePaymentService: MobilePaymentService,
  ) {}

  @Public()
  @Post('stripe')
  @HttpCode(200)
  async handleStripeWebhook(
    @Req() req: RawBodyRequest<Request>,
    @Headers('stripe-signature') signature?: string,
  ): Promise<{ received: boolean }> {
    const rawBody = req.rawBody;
    if (!rawBody) {
      throw new BadRequestException('Missing raw body for Stripe webhook');
    }

    let event: Stripe.Event;
    try {
      event = this.stripeService.constructWebhookEvent(rawBody, signature ?? '');
    } catch (error) {
      this.logger.warn(`Stripe webhook rejected: ${error?.message ?? error}`);
      throw new BadRequestException('Invalid Stripe webhook signature');
    }

    if (event.type === 'payment_intent.succeeded') {
      const intent = event.data.object as Stripe.PaymentIntent;
      await this.mobilePaymentService.markPaymentCompletedFromStripeIntent(intent.id);
      this.logger.log(`Stripe payment_intent.succeeded handled for ${intent.id}`);
    }

    return { received: true };
  }

  @Public()
  @Post('paypal')
  @HttpCode(200)
  async handlePayPalWebhook(@Req() req: Request): Promise<{ received: boolean }> {
    const eventType = req.body?.event_type as string | undefined;
    const resource = req.body?.resource;
    const orderId = resource?.id as string | undefined;

    if (eventType === 'CHECKOUT.ORDER.APPROVED' && orderId) {
      await this.mobilePaymentService.markPaymentCompletedFromPayPalOrder(orderId);
      this.logger.log(`PayPal order approved handled for ${orderId}`);
    }

    return { received: true };
  }
}
