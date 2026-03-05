import { Field, ObjectType, registerEnumType } from '@nestjs/graphql';
import { User } from './user.type';

export enum PaymentMethod {
  CREDIT_CARD = 'CREDIT_CARD',
  PAYPAL = 'PAYPAL',
  BANK_TRANSFER = 'BANK_TRANSFER',
  CRYPTO = 'CRYPTO'
}

export enum PaymentStatus {
  PENDING = 'PENDING',
  COMPLETED = 'COMPLETED',
  FAILED = 'FAILED',
  REFUNDED = 'REFUNDED',
  CANCELLED = 'CANCELLED'
}

registerEnumType(PaymentMethod, {
  name: 'PaymentMethod',
  description: 'Payment method enumeration',
});

registerEnumType(PaymentStatus, {
  name: 'PaymentStatus',
  description: 'Payment status enumeration',
});

@ObjectType()
export class Payment {
  @Field()
  id: string;

  @Field()
  userId: string;

  @Field()
  amount: number;

  @Field()
  currency: string;

  @Field(() => PaymentMethod)
  method: PaymentMethod;

  @Field(() => PaymentStatus)
  status: PaymentStatus;

  @Field({ nullable: true })
  transactionId?: string;

  @Field({ nullable: true })
  description?: string;

  @Field({ nullable: true })
  failureReason?: string;

  @Field()
  createdAt: Date;

  @Field()
  updatedAt: Date;

  @Field({ nullable: true })
  completedAt?: Date;

  // Relations
  @Field(() => User)
  user: User;
} 