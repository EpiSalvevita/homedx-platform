import { IsNumber, IsOptional, IsString, Min, MinLength } from 'class-validator';

export class CreatePaymentDto {
  @IsNumber()
  @Min(0)
  amount: number;

  @IsString()
  @MinLength(1)
  currency: string;

  @IsString()
  @MinLength(1)
  paymentMethod: string;

  @IsOptional()
  @IsString()
  rapidTestId?: string;
}

export class StripeIntentDto {
  @IsString()
  @MinLength(1)
  paymentId: string;

  @IsNumber()
  @Min(0)
  amount: number;

  @IsString()
  @MinLength(1)
  currency: string;
}

export class PayPalOrderDto {
  @IsOptional()
  @IsString()
  paymentId?: string;

  @IsNumber()
  @Min(0)
  amount: number;

  @IsString()
  @MinLength(1)
  currency: string;

  @IsOptional()
  @IsString()
  returnUrl?: string;

  @IsOptional()
  @IsString()
  cancelUrl?: string;
}

export class UpdatePaymentDto {
  @IsString()
  @MinLength(1)
  paymentId: string;

  @IsOptional()
  @IsString()
  transactionId?: string;

  @IsOptional()
  @IsString()
  status?: string;

  @IsOptional()
  @IsString()
  paymentIntentId?: string;

  @IsOptional()
  @IsString()
  paypalOrderId?: string;
}
