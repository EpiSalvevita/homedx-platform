import { Injectable } from '@nestjs/common';
import { PrismaService } from './prisma.service';
import { CreateRapidTestInput, UpdateRapidTestInput } from '../graphql/types/rapid-test.input';
import { TestStatus, TestResult } from '../graphql/types/rapid-test.type';

@Injectable()
export class RapidTestService {
  constructor(private prisma: PrismaService) {}

  private readonly includeRelations = {
    user: true,
    testKit: true,
    license: {
      include: {
        user: true
      }
    }
  };

  private mapTestStatus(status: string): TestStatus {
    switch (status) {
      case 'PENDING':
        return TestStatus.PENDING;
      case 'IN_PROGRESS':
        return TestStatus.IN_PROGRESS;
      case 'COMPLETED':
        return TestStatus.COMPLETED;
      case 'FAILED':
        return TestStatus.FAILED;
      default:
        return TestStatus.PENDING;
    }
  }

  private mapTestResult(result: string | null): TestResult | null {
    if (!result) return null;
    switch (result) {
      case 'POSITIVE':
        return TestResult.POSITIVE;
      case 'NEGATIVE':
        return TestResult.NEGATIVE;
      case 'INVALID':
        return TestResult.INVALID;
      case 'INCONCLUSIVE':
        return TestResult.INCONCLUSIVE;
      default:
        return null;
    }
  }

  private mapRapidTestToGraphQL(rapidTest: any) {
    return {
      ...rapidTest,
      status: this.mapTestStatus(rapidTest.status),
      result: this.mapTestResult(rapidTest.result),
    };
  }

  async findAll() {
    const rapidTests = await this.prisma.rapidTest.findMany({
      include: this.includeRelations
    });
    return rapidTests.map(test => this.mapRapidTestToGraphQL(test));
  }

  async findOne(id: string) {
    const rapidTest = await this.prisma.rapidTest.findUnique({
      where: { id },
      include: this.includeRelations
    });
    return rapidTest ? this.mapRapidTestToGraphQL(rapidTest) : null;
  }

  async findByUserId(userId: string) {
    const rapidTests = await this.prisma.rapidTest.findMany({
      where: { userId },
      include: this.includeRelations
    });
    return rapidTests.map(test => this.mapRapidTestToGraphQL(test));
  }

  async create(data: CreateRapidTestInput) {
    const rapidTest = await this.prisma.rapidTest.create({
      data: {
        ...data,
        status: 'PENDING' as any,
      },
      include: this.includeRelations
    });
    return this.mapRapidTestToGraphQL(rapidTest);
  }

  async update(id: string, data: UpdateRapidTestInput) {
    const rapidTest = await this.prisma.rapidTest.update({
      where: { id },
      data: data as any,
      include: this.includeRelations
    });
    return this.mapRapidTestToGraphQL(rapidTest);
  }

  async remove(id: string) {
    const rapidTest = await this.prisma.rapidTest.delete({
      where: { id },
      include: this.includeRelations
    });
    return this.mapRapidTestToGraphQL(rapidTest);
  }
} 