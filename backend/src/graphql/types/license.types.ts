import { Field, ObjectType } from '@nestjs/graphql';
import { License } from './license.type';

@ObjectType()
export class ActivateLicenseResponse {
  @Field()
  success: boolean;

  @Field(() => License, { nullable: true })
  license?: License;

  @Field({ nullable: true })
  message?: string;
}

@ObjectType()
export class AssignCouponResponse {
  @Field()
  success: boolean;

  @Field({ nullable: true })
  licenseCode?: string;

  @Field({ nullable: true })
  message?: string;
} 