export interface PaymentLineItemInput {
  productId: string;
  name: string;
  quantity: number;
  unitPrice: number;
}

export interface CreatePaymentInput {
  userId: string;
  amount: number;
  currency: string;
  paymentMethod: string;
  rapidTestId?: string;
  transactionId?: string;
  paymentIntentId?: string;
  paypalOrderId?: string;
  description?: string;
  lineItems?: PaymentLineItemInput[];
}

export interface UpdatePaymentInput {
  amount?: number;
  currency?: string;
  status?: string;
  paymentMethod?: string;
  transactionId?: string;
  paymentIntentId?: string;
  paypalOrderId?: string;
  rapidTestId?: string;
}
