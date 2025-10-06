import { Resolver, Query, Mutation } from '@nestjs/graphql';
import { BackendStatus, PaymentAmount, SystemResponse } from '../types/system.types';

@Resolver()
export class SystemResolver {
  @Query(() => BackendStatus)
  async backendStatus(): Promise<BackendStatus> {
    return {
      maintenance: false,
      version: '1.0.0',
      flags: [
        { key: 'feature_flags_enabled', value: 'true' },
        { key: 'maintenance_mode', value: 'false' },
        { key: 'payment_is_active', value: 'true' }
      ],
      paymentIsActive: true,
      stripe: true,
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

  @Mutation(() => SystemResponse)
  async createPaymentIntent(): Promise<SystemResponse> {
    return {
      success: true,
      secret: 'pi_test_secret_' + Math.random().toString(36).substr(2, 9)
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