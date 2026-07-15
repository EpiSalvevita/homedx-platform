import { Type } from 'class-transformer';
import {
  ArrayMaxSize,
  IsArray,
  IsNumber,
  IsOptional,
  IsString,
  Min,
  MinLength,
  ValidateNested,
} from 'class-validator';

export class PaymentLineItemDto {
  @IsString()
  @MinLength(1)
  productId: string;

  @IsString()
  @MinLength(1)
  name: string;

  @IsNumber()
  @Min(1)
  quantity: number;

  @IsNumber()
  @Min(0)
  unitPrice: number;
}

export class CreatePaymentDto {
  @IsOptional()
  @IsString()
  rapidTestId?: string;

  @IsOptional()
  @IsString()
  @MinLength(1)
  paymentMethod?: string;

  @IsOptional()
  @IsArray()
  @ArrayMaxSize(50)
  @ValidateNested({ each: true })
  @Type(() => PaymentLineItemDto)
  items?: PaymentLineItemDto[];
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
