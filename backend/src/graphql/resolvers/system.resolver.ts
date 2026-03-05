import { Resolver, Query, Mutation, Args } from '@nestjs/graphql';
import { BackendStatus, PaymentAmount, SystemResponse } from '../types/system.types';
import { StripeService } from '../../services/stripe.service';
import { PayPalService } from '../../services/paypal.service';
import { CreateStripePaymentIntentInput, StripePaymentIntentResponse } from '../types/stripe.types';
import { CreatePayPalOrderInput, PayPalOrderResponse } from '../types/paypal.types';

@Resolver()
export class SystemResolver {
  constructor(
    private readonly stripeService: StripeService,
    private readonly paypalService: PayPalService,
  ) {}

  @Query(() => BackendStatus)
  async backendStatus(): Promise<BackendStatus> {
    const stripeConfigured = !!process.env.STRIPE_SECRET_KEY;
    const paypalConfigured = !!(process.env.PAYPAL_CLIENT_ID && process.env.PAYPAL_CLIENT_SECRET);

    return {
      maintenance: false,
      version: '1.0.0',
      flags: [
        { key: 'feature_flags_enabled', value: 'true' },
        { key: 'maintenance_mode', value: 'false' },
        { key: 'payment_is_active', value: 'true' }
      ],
      paymentIsActive: true,
      stripe: stripeConfigured,
      cwa: false,
      cwaLaive: false,
      certificatePdf: true
    };
  }

  @Query(() => PaymentAmount)
  async paymentAmount(): Promise<PaymentAmount> {
    return {
      amount: 29.99,
      reducedAmount: 24.99,
      discount: 5.00,
      discountType: 'percentage'
    };
  }

  @Query(() => [String])
  async countryCodes(): Promise<string[]> {
    return ['DE', 'AT', 'CH', 'FR', 'IT', 'ES', 'NL', 'BE', 'LU', 'US', 'CA', 'GB'];
  }

  @Query(() => String)
  async profileImage(): Promise<string> {
    return 'https://example.com/default-profile.png';
  }

  @Query(() => String)
  async qrCode(): Promise<string> {
    return 'https://example.com/qr-code.png';
  }

  @Mutation(() => StripePaymentIntentResponse)
  async createPaymentIntent(
    @Args('input') input: CreateStripePaymentIntentInput,
  ): Promise<StripePaymentIntentResponse> {
    const { clientSecret, paymentIntentId } = await this.stripeService.createPaymentIntent(
      input.amount,
      input.currency,
      input.paymentId ? { paymentId: input.paymentId } : undefined,
    );

    return {
      clientSecret,
      paymentIntentId,
    };
  }

  @Mutation(() => PayPalOrderResponse)
  async createPayPalOrder(
    @Args('input') input: CreatePayPalOrderInput,
  ): Promise<PayPalOrderResponse> {
    const { orderId, approvalUrl } = await this.paypalService.createOrder(
      input.amount,
      input.currency,
      input.returnUrl,
      input.cancelUrl,
    );

    return {
      orderId,
      approvalUrl,
    };
  }

  @Mutation(() => SystemResponse)
  async resetAuthentication(): Promise<SystemResponse> {
    return {
      success: true
    };
  }

  @Mutation(() => SystemResponse)
  async resetCWALink(): Promise<SystemResponse> {
    return {
      success: true
    };
  }
} 