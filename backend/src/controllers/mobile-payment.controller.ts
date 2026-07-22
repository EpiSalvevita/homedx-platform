import { Body, Controller, Post, Request, UseGuards } from '@nestjs/common';
import { MobilePaymentService } from '../services/mobile-payment.service';
import { JwtAuthGuard } from '../auth/jwt-auth.guard';
import {
  CapturePayPalOrderDto,
  CreatePaymentDto,
  PayPalOrderDto,
  PaymentIdDto,
  StripeIntentDto,
  UpdatePaymentDto,
} from '../dto/mobile/payment.dto';
import { sanitizeMobileError } from '../utils/mobile-error.util';
import {
  MOBILE_API_PATH,
  PaymentAmountResponse,
  PaymentRecordResponse,
  PayPalOrderResponse,
  StripeIntentResponse,
} from './mobile.types';

@Controller(MOBILE_API_PATH)
export class MobilePaymentController {
  constructor(private readonly mobilePaymentService: MobilePaymentService) {}

  @Post('get-payment-amount')
  @UseGuards(JwtAuthGuard)
  async getPaymentAmount(): Promise<PaymentAmountResponse> {
    try {
      const amount = this.mobilePaymentService.getPaymentAmount();
      return { success: true, ...amount };
    } catch (error) {
      return sanitizeMobileError(error, 'Failed to get payment amount');
    }
  }

  @Post('create-payment')
  @UseGuards(JwtAuthGuard)
  async createPayment(
    @Request() req: { user?: { sub: string } },
    @Body() body: CreatePaymentDto,
  ): Promise<PaymentRecordResponse> {
    try {
      const userId = req.user?.sub;
      if (!userId) {
        return { success: false, error: 'Invalid token' };
      }
      const payment = await this.mobilePaymentService.createPayment(userId, body);
      return { success: true, payment };
    } catch (error) {
      return sanitizeMobileError(error, 'Failed to create payment');
    }
  }

  @Post('get-payment')
  @UseGuards(JwtAuthGuard)
  async getPayment(
    @Request() req: { user?: { sub: string } },
    @Body() body: PaymentIdDto,
  ): Promise<PaymentRecordResponse> {
    try {
      const userId = req.user?.sub;
      if (!userId) {
        return { success: false, error: 'Invalid token' };
      }
      const payment = await this.mobilePaymentService.getPayment(userId, body.paymentId);
      return { success: true, payment };
    } catch (error) {
      return sanitizeMobileError(error, 'Failed to get payment');
    }
  }

  @Post('create-stripe-payment-intent')
  @UseGuards(JwtAuthGuard)
  async createStripePaymentIntent(
    @Request() req: { user?: { sub: string } },
    @Body() body: StripeIntentDto,
  ): Promise<StripeIntentResponse> {
    try {
      const userId = req.user?.sub;
      if (!userId) {
        return { success: false, error: 'Invalid token' };
      }
      const result = await this.mobilePaymentService.createStripePaymentIntent(userId, body);
      return { success: true, ...result };
    } catch (error) {
      return sanitizeMobileError(error, 'Failed to create Stripe payment intent');
    }
  }

  @Post('confirm-stripe-payment')
  @UseGuards(JwtAuthGuard)
  async confirmStripePayment(
    @Request() req: { user?: { sub: string } },
    @Body() body: PaymentIdDto,
  ): Promise<PaymentRecordResponse> {
    try {
      const userId = req.user?.sub;
      if (!userId) {
        return { success: false, error: 'Invalid token' };
      }
      const payment = await this.mobilePaymentService.confirmStripePayment(userId, body.paymentId);
      return { success: true, payment };
    } catch (error) {
      return sanitizeMobileError(error, 'Failed to confirm Stripe payment');
    }
  }

  @Post('create-paypal-order')
  @UseGuards(JwtAuthGuard)
  async createPayPalOrder(
    @Request() req: { user?: { sub: string } },
    @Body() body: PayPalOrderDto,
  ): Promise<PayPalOrderResponse> {
    try {
      const userId = req.user?.sub;
      if (!userId) {
        return { success: false, error: 'Invalid token' };
      }
      const result = await this.mobilePaymentService.createPayPalOrder(userId, body);
      return { success: true, ...result };
    } catch (error) {
      return sanitizeMobileError(error, 'Failed to create PayPal order');
    }
  }

  @Post('capture-paypal-order')
  @UseGuards(JwtAuthGuard)
  async capturePayPalOrder(
    @Request() req: { user?: { sub: string } },
    @Body() body: CapturePayPalOrderDto,
  ): Promise<PaymentRecordResponse> {
    try {
      const userId = req.user?.sub;
      if (!userId) {
        return { success: false, error: 'Invalid token' };
      }
      const payment = await this.mobilePaymentService.capturePayPalOrder(
        userId,
        body.paymentId,
        body.paypalOrderId,
      );
      return { success: true, payment };
    } catch (error) {
      return sanitizeMobileError(error, 'Failed to capture PayPal order');
    }
  }

  @Post('update-payment')
  @UseGuards(JwtAuthGuard)
  async updatePayment(
    @Request() req: { user?: { sub: string } },
    @Body() body: UpdatePaymentDto,
  ): Promise<PaymentRecordResponse> {
    try {
      const userId = req.user?.sub;
      if (!userId) {
        return { success: false, error: 'Invalid token' };
      }
      const payment = await this.mobilePaymentService.updatePayment(userId, body);
      return { success: true, payment };
    } catch (error) {
      return sanitizeMobileError(error, 'Failed to update payment');
    }
  }

  @Post('list-payments')
  @UseGuards(JwtAuthGuard)
  async listPayments(@Request() req: { user?: { sub: string } }) {
    try {
      const userId = req.user?.sub;
      if (!userId) {
        return { success: false, error: 'Invalid token' };
      }
      const payments = await this.mobilePaymentService.listByUserId(userId);
      return { success: true, payments };
    } catch (error) {
      return sanitizeMobileError(error, 'Failed to list payments');
    }
  }
}
