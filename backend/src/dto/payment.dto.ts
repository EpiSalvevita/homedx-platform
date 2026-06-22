export interface CreatePaymentInput {
  userId: string;
  amount: number;
  currency: string;
  paymentMethod: string;
  rapidTestId?: string;
  transactionId?: string;
  paymentIntentId?: string;
  paypalOrderId?: string;
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
