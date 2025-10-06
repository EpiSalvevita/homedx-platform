import { Field, InputType, Int, Float } from '@nestjs/graphql';
import { IsInt, IsString, IsOptional, IsNumber, Min, Matches } from 'class-validator';

@InputType()
export class CreatePaymentInput {
  @Field()
  @IsString()
  userId: string;

  @Field(() => Float)
  @IsNumber({ maxDecimalPlaces: 2 })
  @Min(0, { message: 'Amount must be greater than or equal to 0' })
  amount: number;

  @Field()
  @IsString()
  @Matches(/^[A-Z]{3}$/, {
    message: 'Currency must be a valid 3-letter currency code (e.g., EUR, USD)',
  })
  currency: string;

  @Field()
  @IsString()
  @Matches(/^(CREDIT_CARD|PAYPAL|BANK_TRANSFER|STRIPE)$/, {
    message: 'Payment method must be one of: CREDIT_CARD, PAYPAL, BANK_TRANSFER, STRIPE',
  })
  paymentMethod: string;

  @Field({ nullable: true })
  @IsOptional()
  @IsString()
  rapidTestId?: string;

  @Field({ nullable: true })
  @IsOptional()
  @IsString()
  transactionId?: string;

  @Field({ nullable: true })
  @IsOptional()
  @IsString()
  paymentIntentId?: string;
}

@InputType()
export class UpdatePaymentInput {
  @Field(() => Float, { nullable: true })
  @IsOptional()
  @IsNumber({ maxDecimalPlaces: 2 })
  @Min(0, { message: 'Amount must be greater than or equal to 0' })
  amount?: number;

  @Field({ nullable: true })
  @IsOptional()
  @IsString()
  @Matches(/^[A-Z]{3}$/, {
    message: 'Currency must be a valid 3-letter currency code (e.g., EUR, USD)',
  })
  currency?: string;

  @Field({ nullable: true })
  @IsOptional()
  @IsString()
  @Matches(/^(PENDING|COMPLETED|FAILED|REFUNDED)$/, {
    message: 'Status must be one of: PENDING, COMPLETED, FAILED, REFUNDED',
  })
  status?: string;

  @Field({ nullable: true })
  @IsOptional()
  @IsString()
  @Matches(/^(CREDIT_CARD|PAYPAL|BANK_TRANSFER|STRIPE)$/, {
    message: 'Payment method must be one of: CREDIT_CARD, PAYPAL, BANK_TRANSFER, STRIPE',
  })
  paymentMethod?: string;

  @Field({ nullable: true })
  @IsOptional()
  @IsString()
  transactionId?: string;

  @Field({ nullable: true })
  @IsOptional()
  @IsString()
  paymentIntentId?: string;
} 