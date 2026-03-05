import { Injectable } from '@nestjs/common';
import Stripe from 'stripe';

@Injectable()
export class StripeService {
  private stripe: Stripe;

  constructor() {
    const secretKey = process.env.STRIPE_SECRET_KEY;
    if (!secretKey) {
      console.warn('STRIPE_SECRET_KEY not found in environment variables. Stripe functionality will be disabled.');
      return;
    }

    this.stripe = new Stripe(secretKey, {
      apiVersion: '2025-11-17.clover',
    });
  }

  /**
   * Create a Stripe Payment Intent
   * @param amount Amount in the smallest currency unit (e.g., cents for USD/EUR)
   * @param currency Three-letter ISO currency code (e.g., 'eur', 'usd')
   * @param metadata Optional metadata to attach to the payment intent
   * @returns Payment Intent with client secret
   */
  async createPaymentIntent(
    amount: number,
    currency: string = 'eur',
    metadata?: Record<string, string>,
  ): Promise<{ clientSecret: string; paymentIntentId: string }> {
    if (!this.stripe) {
      throw new Error('Stripe is not configured. Please set STRIPE_SECRET_KEY in environment variables.');
    }

    try {
      // Convert amount to smallest currency unit (cents)
      const amountInCents = Math.round(amount * 100);

      const paymentIntent = await this.stripe.paymentIntents.create({
        amount: amountInCents,
        currency: currency.toLowerCase(),
        automatic_payment_methods: {
          enabled: true,
        },
        metadata: metadata || {},
      });

      if (!paymentIntent.client_secret) {
        throw new Error('Failed to create payment intent: client_secret is missing');
      }

      return {
        clientSecret: paymentIntent.client_secret,
        paymentIntentId: paymentIntent.id,
      };
    } catch (error) {
      console.error('Stripe payment intent creation error:', error);
      throw new Error(`Failed to create payment intent: ${error instanceof Error ? error.message : 'Unknown error'}`);
    }
  }

  /**
   * Retrieve a payment intent by ID
   */
  async getPaymentIntent(paymentIntentId: string): Promise<Stripe.PaymentIntent> {
    if (!this.stripe) {
      throw new Error('Stripe is not configured.');
    }

    return await this.stripe.paymentIntents.retrieve(paymentIntentId);
  }

  /**
   * Confirm a payment intent (usually called after client-side confirmation)
   */
  async confirmPaymentIntent(paymentIntentId: string): Promise<Stripe.PaymentIntent> {
    if (!this.stripe) {
      throw new Error('Stripe is not configured.');
    }

    return await this.stripe.paymentIntents.confirm(paymentIntentId);
  }

  /**
   * Cancel a payment intent
   */
  async cancelPaymentIntent(paymentIntentId: string): Promise<Stripe.PaymentIntent> {
    if (!this.stripe) {
      throw new Error('Stripe is not configured.');
    }

    return await this.stripe.paymentIntents.cancel(paymentIntentId);
  }
}

