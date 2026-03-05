import { Field, InputType, ObjectType, Float } from '@nestjs/graphql';

@InputType()
export class CreatePayPalOrderInput {
  @Field(() => Float)
  amount: number;

  @Field()
  currency: string;

  @Field({ nullable: true })
  returnUrl?: string;

  @Field({ nullable: true })
  cancelUrl?: string;
}

@ObjectType()
export class PayPalOrderResponse {
  @Field()
  orderId: string;

  @Field()
  approvalUrl: string;
}



