import { Field, ObjectType } from '@nestjs/graphql';

@ObjectType()
export class SystemFlag {
  @Field()
  key: string;

  @Field()
  value: string;
}

@ObjectType()
export class BackendStatus {
  @Field()
  maintenance: boolean;

  @Field()
  version: string;

  @Field(() => [SystemFlag])
  flags: SystemFlag[];

  @Field()
  paymentIsActive: boolean;

  @Field()
  stripe: boolean;

  @Field()
  cwa: boolean;

  @Field()
  cwaLaive: boolean;

  @Field()
  certificatePdf: boolean;
}

@ObjectType()
export class PaymentAmount {
  @Field()
  amount: number;

  @Field()
  reducedAmount: number;

  @Field()
  discount: number;

  @Field()
  discountType: string;
}

@ObjectType()
export class SystemResponse {
  @Field()
  success: boolean;

  @Field({ nullable: true })
  secret?: string;

  @Field({ nullable: true })
  message?: string;
} 