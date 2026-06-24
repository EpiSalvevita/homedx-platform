import { Injectable } from '@nestjs/common';
import {
  Client,
  OrdersController,
  Environment,
  OrderApplicationContextUserAction,
  CheckoutPaymentIntent,
  OrderApplicationContextLandingPage,
} from '@paypal/paypal-server-sdk';

@Injectable()
export class PayPalService {
  private ordersController: OrdersController | null = null;

  constructor() {
    const clientId = process.env.PAYPAL_CLIENT_ID;
    const clientSecret = process.env.PAYPAL_CLIENT_SECRET;
    const mode = process.env.PAYPAL_MODE || 'sandbox';

    if (!clientId || !clientSecret) {
      console.warn('PayPal credentials not found in environment variables. PayPal functionality will be disabled.');
      return;
    }

    try {
      const client = new Client({
        environment: mode === 'live' ? Environment.Production : Environment.Sandbox,
        clientCredentialsAuthCredentials: {
          oAuthClientId: clientId,
          oAuthClientSecret: clientSecret,
        },
      });
      this.ordersController = new OrdersController(client);
    } catch (error) {
      console.error('Failed to initialize PayPal client:', error);
    }
  }

  /**
   * Create a PayPal order
   * @param amount Amount in the currency
   * @param currency Three-letter ISO currency code (e.g., 'EUR', 'USD')
   * @param returnUrl URL to redirect after payment approval
   * @param cancelUrl URL to redirect if payment is cancelled
   * @param metadata Optional metadata
   * @returns Order with approval URL and order ID
   */
  async createOrder(
    amount: number,
    currency: string = 'EUR',
    returnUrl?: string,
    cancelUrl?: string,
    metadata?: Record<string, string>,
  ): Promise<{ orderId: string; approvalUrl: string }> {
    if (!this.ordersController) {
      throw new Error('PayPal is not configured. Please set PAYPAL_CLIENT_ID and PAYPAL_CLIENT_SECRET in environment variables.');
    }

    try {
      const response = await this.ordersController.createOrder({
        body: {
          intent: CheckoutPaymentIntent.Capture,
          purchaseUnits: [
            {
              amount: {
                currencyCode: currency.toUpperCase(),
                value: amount.toFixed(2),
              },
              description: `Payment for ${amount} ${currency}`,
            },
          ],
          applicationContext: {
            brandName: 'HomeDX',
            landingPage: OrderApplicationContextLandingPage.Billing,
            userAction: OrderApplicationContextUserAction.PayNow,
            returnUrl: returnUrl || `${process.env.APP_URL || 'http://localhost:4000'}/paypal/return`,
            cancelUrl: cancelUrl || `${process.env.APP_URL || 'http://localhost:4000'}/paypal/cancel`,
          },
        },
        prefer: 'return=representation',
      });

      if (response.statusCode !== 201) {
        throw new Error(`PayPal order creation failed with status ${response.statusCode}`);
      }

      const order = response.result;
      if (!order.id) {
        throw new Error('PayPal order creation failed: order ID is missing');
      }

      // Find the approval URL
      const approvalLink = order.links?.find((link) => link.rel === 'approve');
      if (!approvalLink || !approvalLink.href) {
        throw new Error('PayPal order creation failed: approval URL is missing');
      }

      return {
        orderId: order.id,
        approvalUrl: approvalLink.href,
      };
    } catch (error) {
      console.error('PayPal order creation error:', error);
      throw new Error(`Failed to create PayPal order: ${error instanceof Error ? error.message : 'Unknown error'}`);
    }
  }

  /**
   * Capture a PayPal order (after user approval)
   * @param orderId PayPal order ID
   * @returns Captured order details
   */
  async captureOrder(orderId: string): Promise<any> {
    if (!this.ordersController) {
      throw new Error('PayPal is not configured.');
    }

    try {
      const response = await this.ordersController.captureOrder({
        id: orderId,
        body: {},
      });

      if (response.statusCode !== 201) {
        throw new Error(`PayPal order capture failed with status ${response.statusCode}`);
      }

      return response.result;
    } catch (error) {
      console.error('PayPal order capture error:', error);
      throw new Error(`Failed to capture PayPal order: ${error instanceof Error ? error.message : 'Unknown error'}`);
    }
  }

  /**
   * Get order details
   * @param orderId PayPal order ID
   */
  async getOrder(orderId: string): Promise<any> {
    if (!this.ordersController) {
      throw new Error('PayPal is not configured.');
    }

    try {
      const response = await this.ordersController.getOrder({
        id: orderId,
      });

      if (response.statusCode !== 200) {
        throw new Error(`PayPal order retrieval failed with status ${response.statusCode}`);
      }

      return response.result;
    } catch (error) {
      console.error('PayPal order retrieval error:', error);
      throw new Error(`Failed to get PayPal order: ${error instanceof Error ? error.message : 'Unknown error'}`);
    }
  }

  /**
   * Verify PayPal webhook signature via REST API.
   */
  async verifyWebhookSignature(
    headers: Record<string, string | undefined>,
    body: Record<string, unknown>,
  ): Promise<boolean> {
    const webhookId = process.env.PAYPAL_WEBHOOK_ID;
    if (!webhookId) {
      console.warn('PAYPAL_WEBHOOK_ID not set — rejecting PayPal webhook');
      return false;
    }

    const transmissionId = headers['paypal-transmission-id'];
    const transmissionTime = headers['paypal-transmission-time'];
    const transmissionSig = headers['paypal-transmission-sig'];
    const certUrl = headers['paypal-cert-url'];
    const authAlgo = headers['paypal-auth-algo'];

    if (!transmissionId || !transmissionTime || !transmissionSig || !certUrl || !authAlgo) {
      return false;
    }

    const accessToken = await this.getAccessToken();
    if (!accessToken) {
      return false;
    }

    const mode = process.env.PAYPAL_MODE || 'sandbox';
    const baseUrl =
      mode === 'live' ? 'https://api-m.paypal.com' : 'https://api-m.sandbox.paypal.com';

    const response = await fetch(`${baseUrl}/v1/notifications/verify-webhook-signature`, {
      method: 'POST',
      headers: {
        'Content-Type': 'application/json',
        Authorization: `Bearer ${accessToken}`,
      },
      body: JSON.stringify({
        auth_algo: authAlgo,
        cert_url: certUrl,
        transmission_id: transmissionId,
        transmission_sig: transmissionSig,
        transmission_time: transmissionTime,
        webhook_id: webhookId,
        webhook_event: body,
      }),
    });

    if (!response.ok) {
      return false;
    }

    const result = (await response.json()) as { verification_status?: string };
    return result.verification_status === 'SUCCESS';
  }

  private async getAccessToken(): Promise<string | null> {
    const clientId = process.env.PAYPAL_CLIENT_ID;
    const clientSecret = process.env.PAYPAL_CLIENT_SECRET;
    if (!clientId || !clientSecret) {
      return null;
    }

    const mode = process.env.PAYPAL_MODE || 'sandbox';
    const baseUrl =
      mode === 'live' ? 'https://api-m.paypal.com' : 'https://api-m.sandbox.paypal.com';

    const credentials = Buffer.from(`${clientId}:${clientSecret}`).toString('base64');
    const response = await fetch(`${baseUrl}/v1/oauth2/token`, {
      method: 'POST',
      headers: {
        Authorization: `Basic ${credentials}`,
        'Content-Type': 'application/x-www-form-urlencoded',
      },
      body: 'grant_type=client_credentials',
    });

    if (!response.ok) {
      return null;
    }

    const data = (await response.json()) as { access_token?: string };
    return data.access_token ?? null;
  }
}
