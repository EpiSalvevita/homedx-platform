import { IsOptional, IsString, MinLength } from 'class-validator';

export class CreatePaymentDto {
  @IsOptional()
  @IsString()
  rapidTestId?: string;

  @IsOptional()
  @IsString()
  @MinLength(1)
  paymentMethod?: string;
}

export class StripeIntentDto {
  @IsString()
  @MinLength(1)
  paymentId: string;
}

export class PayPalOrderDto {
  @IsOptional()
  @IsString()
  paymentId?: string;

  @IsOptional()
  @IsString()
  returnUrl?: string;

  @IsOptional()
  @IsString()
  cancelUrl?: string;
}

export class PaymentIdDto {
  @IsString()
  @MinLength(1)
  paymentId: string;
}

export class CapturePayPalOrderDto {
  @IsString()
  @MinLength(1)
  paymentId: string;

  @IsOptional()
  @IsString()
  paypalOrderId?: string;
}

export class UpdatePaymentDto {
  @IsString()
  @MinLength(1)
  paymentId: string;

  @IsOptional()
  @IsString()
  paymentIntentId?: string;

  @IsOptional()
  @IsString()
  paypalOrderId?: string;
}
