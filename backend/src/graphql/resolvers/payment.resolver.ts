import { Resolver, Query, Mutation, Args } from '@nestjs/graphql';
import { Payment, PaymentStatus } from '../types/payment.type';
import { CreatePaymentInput, UpdatePaymentInput } from '../types/payment.input';
import { PaymentService } from '../../services/payment.service';

@Resolver(() => Payment)
export class PaymentResolver {
  constructor(private readonly paymentService: PaymentService) {}

  @Query(() => [Payment])
  async payments(): Promise<Payment[]> {
    return this.paymentService.findAll();
  }

  @Query(() => Payment, { nullable: true })
  async payment(@Args('id') id: string): Promise<Payment | null> {
    return this.paymentService.findOne(id);
  }

  @Query(() => [Payment])
  async userPayments(@Args('userId') userId: string): Promise<Payment[]> {
    return this.paymentService.findByUserId(userId);
  }

  @Mutation(() => Payment)
  async createPayment(@Args('input') input: CreatePaymentInput): Promise<Payment> {
    return this.paymentService.create(input);
  }

  @Mutation(() => Payment)
  async updatePayment(
    @Args('id') id: string,
    @Args('input') input: UpdatePaymentInput,
  ): Promise<Payment> {
    return this.paymentService.update(id, input);
  }

  @Mutation(() => Payment)
  async removePayment(@Args('id') id: string): Promise<Payment> {
    return this.paymentService.remove(id);
  }

  @Mutation(() => Payment)
  async updatePaymentStatus(
    @Args('id') id: string,
    @Args('status') status: PaymentStatus,
  ): Promise<Payment> {
    return this.paymentService.updateStatus(id, status);
  }
} 