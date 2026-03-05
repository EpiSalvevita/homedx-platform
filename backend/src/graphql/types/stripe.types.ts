import { Field, InputType, ObjectType, Float } from '@nestjs/graphql';

@InputType()
export class CreateStripePaymentIntentInput {
  @Field(() => Float)
  amount: number;

  @Field()
  currency: string;

  @Field({ nullable: true })
  paymentId?: string;
}

@ObjectType()
export class StripePaymentIntentResponse {
  @Field()
  clientSecret: string;

  @Field()
  paymentIntentId: string;
}



