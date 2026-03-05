import { Resolver, Query, Mutation, Args, ResolveField, Parent } from '@nestjs/graphql';
import { UseGuards } from '@nestjs/common';
import { RapidTest, TestResult, TestStatus, SubmitTestResponse } from '../types/rapid-test.type';
import { CreateRapidTestInput, UpdateRapidTestInput } from '../types/rapid-test.input';
import { RapidTestService } from '../../services/rapid-test.service';
import { PrismaService } from '../../services/prisma.service';
import { CurrentUser } from '../../auth/current-user.decorator';
import { User } from '../types/user.type';
import { JwtAuthGuard } from '../../auth/jwt-auth.guard';

@Resolver(() => RapidTest)
export class RapidTestResolver {
  constructor(
    private readonly rapidTestService: RapidTestService,
    private readonly prisma: PrismaService
  ) {}

  @Query(() => [RapidTest])
  async rapidTests(): Promise<RapidTest[]> {
    return this.rapidTestService.findAll();
  }

  @Query(() => RapidTest, { nullable: true })
  async rapidTest(@Args('id') id: string): Promise<RapidTest | null> {
    return this.rapidTestService.findOne(id);
  }

  @Query(() => [RapidTest])
  async userRapidTests(@Args('userId') userId: string): Promise<RapidTest[]> {
    return this.rapidTestService.findByUserId(userId);
  }

  @Query(() => RapidTest, { nullable: true })
  async lastRapidTest(@CurrentUser() user: User): Promise<RapidTest | null> {
    if (!user || !user.id) {
      return null;
    }
    const userTests = await this.rapidTestService.findByUserId(user.id);
    return userTests.length > 0 ? userTests[userTests.length - 1] : null;
  }

  @Query(() => String)
  async testStatus(@CurrentUser() user: User): Promise<string> {
    const userTests = await this.rapidTestService.findByUserId(user.id);
    const lastTest = userTests.length > 0 ? userTests[userTests.length - 1] : null;
    
    return JSON.stringify({
      id: lastTest?.id || null,
      status: lastTest?.status || 'NO_TEST',
      result: lastTest?.result || null,
      createdAt: lastTest?.createdAt || null,
      updatedAt: lastTest?.updatedAt || null
    });
  }

  @Query(() => String)
  async liveToken(): Promise<string> {
    // Generate a 4-digit PIN as a string
    return Math.floor(1000 + Math.random() * 9000).toString();
  }

  @Query(() => String)
  async cwaLink(@Args('rapidTestId') rapidTestId: string): Promise<string> {
    // Generate CWA link for the test
    return `https://cwa.example.com/test/${rapidTestId}`;
  }

  @Mutation(() => SubmitTestResponse)
  async submitTest(
    @Args('videoUrl') videoUrl: string,
    @Args('photoUrl') photoUrl: string,
    @Args('testDeviceUrl') testDeviceUrl: string,
    @Args('testDate') testDate: number,
    @Args('liveToken') liveToken: string,
    @Args('agreementGiven', { nullable: true }) agreementGiven?: boolean,
    @Args('paymentId', { nullable: true }) paymentId?: string,
    @Args('licenseCode', { nullable: true }) licenseCode?: string,
    @Args('identityCard1Url', { nullable: true }) identityCard1Url?: string,
    @Args('identityCard2Url', { nullable: true }) identityCard2Url?: string,
    @Args('identifyUrl', { nullable: true }) identifyUrl?: string,
    @Args('identityCardId', { nullable: true }) identityCardId?: string,
  ): Promise<SubmitTestResponse> {
    try {
      // Find an available test kit or create a default one
      let testKit = await this.prisma.testKit.findFirst({
        where: { status: 'AVAILABLE' }
      });

      if (!testKit) {
        // Create a default test kit if none available
        testKit = await this.prisma.testKit.create({
          data: {
            serialNumber: `DEFAULT-${Date.now()}`,
            type: 'COVID_19',
            manufacturer: 'Default Manufacturer',
            model: 'Default Model',
            batchNumber: 'DEFAULT-BATCH',
            expirationDate: new Date(Date.now() + 365 * 24 * 60 * 60 * 1000), // 1 year from now
            status: 'AVAILABLE'
          }
        });
      }

      // Create a new rapid test with the submitted data
      const testInput = {
        testDate: new Date(testDate),
        videoUrl,
        photoUrl,
        testDeviceUrl,
        agreementGiven: agreementGiven || false,
        identityCard1Url,
        identityCard2Url,
        identityCardId,
        userId: 'cmc4w7oml0002v8zucjwlb0z7', // Default test user ID
        testKitId: testKit.id
      };

      const newTest = await this.rapidTestService.create(testInput as any);
      
      return {
        success: true,
        validation: 'PENDING'
      };
    } catch (error) {
      console.error('Error in submitTest:', error);
      return {
        success: false,
        validation: 'FAILED'
      };
    }
  }

  @Mutation(() => RapidTest)
  async createRapidTest(@Args('input') input: CreateRapidTestInput): Promise<RapidTest> {
    return this.rapidTestService.create(input);
  }

  @Mutation(() => RapidTest)
  async updateRapidTest(
    @Args('id') id: string,
    @Args('input') input: UpdateRapidTestInput,
  ): Promise<RapidTest> {
    return this.rapidTestService.update(id, input);
  }

  @Mutation(() => RapidTest)
  async removeRapidTest(@Args('id') id: string): Promise<RapidTest> {
    return this.rapidTestService.remove(id);
  }
} 