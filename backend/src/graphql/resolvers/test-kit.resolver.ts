import { Resolver, Query, Mutation, Args } from '@nestjs/graphql';
import { TestKit } from '../types/test-kit.types';
import { CreateTestKitInput, UpdateTestKitInput } from '../types/test-kit.input';
import { TestKitService } from '../../services/test-kit.service';

@Resolver(() => TestKit)
export class TestKitResolver {
  constructor(private readonly testKitService: TestKitService) {}

  @Query(() => [TestKit])
  async testKits(): Promise<TestKit[]> {
    return this.testKitService.findAll();
  }

  @Query(() => TestKit, { nullable: true })
  async testKit(@Args('id') id: string): Promise<TestKit | null> {
    return this.testKitService.findOne(id);
  }

  @Query(() => TestKit, { nullable: true })
  async testKitBySerialNumber(@Args('serialNumber') serialNumber: string): Promise<TestKit | null> {
    return this.testKitService.findBySerialNumber(serialNumber);
  }

  @Query(() => [TestKit])
  async availableTestKits(): Promise<TestKit[]> {
    return this.testKitService.findAvailable();
  }

  @Query(() => [TestKit])
  async userTestKits(@Args('userId') userId: string): Promise<TestKit[]> {
    return this.testKitService.findByUserId(userId);
  }

  @Mutation(() => TestKit)
  async createTestKit(@Args('input') input: CreateTestKitInput): Promise<TestKit> {
    return this.testKitService.create(input);
  }

  @Mutation(() => TestKit)
  async updateTestKit(
    @Args('id') id: string,
    @Args('input') input: UpdateTestKitInput,
  ): Promise<TestKit> {
    return this.testKitService.update(id, input);
  }

  @Mutation(() => TestKit)
  async removeTestKit(@Args('id') id: string): Promise<TestKit> {
    return this.testKitService.remove(id);
  }

  @Mutation(() => TestKit)
  async assignTestKitToUser(
    @Args('id') id: string,
    @Args('userId') userId: string,
  ): Promise<TestKit> {
    return this.testKitService.assignToUser(id, userId);
  }

  @Mutation(() => TestKit)
  async markTestKitAsUsed(@Args('id') id: string): Promise<TestKit> {
    return this.testKitService.markAsUsed(id);
  }
} 