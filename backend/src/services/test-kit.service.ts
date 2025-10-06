import { Injectable } from '@nestjs/common';
import { PrismaService } from './prisma.service';
import { TestKitType, TestKitStatus } from '../graphql/types/test-kit.types';

@Injectable()
export class TestKitService {
  constructor(private prisma: PrismaService) {}

  private mapTestKitType(type: string): TestKitType {
    switch (type) {
      case 'COVID_19':
        return TestKitType.COVID_19;
      case 'FLU':
        return TestKitType.FLU;
      case 'STREP_THROAT':
        return TestKitType.STREP_THROAT;
      case 'PREGNANCY':
        return TestKitType.PREGNANCY;
      case 'DRUG_TEST':
        return TestKitType.DRUG_TEST;
      default:
        return TestKitType.COVID_19;
    }
  }

  private mapTestKitStatus(status: string): TestKitStatus {
    switch (status) {
      case 'AVAILABLE':
        return TestKitStatus.AVAILABLE;
      case 'USED':
        return TestKitStatus.USED;
      case 'EXPIRED':
        return TestKitStatus.EXPIRED;
      case 'DAMAGED':
        return TestKitStatus.DAMAGED;
      default:
        return TestKitStatus.AVAILABLE;
    }
  }

  private mapTestKitToGraphQL(testKit: any) {
    return {
      ...testKit,
      type: this.mapTestKitType(testKit.type),
      status: this.mapTestKitStatus(testKit.status),
    };
  }

  async findAll() {
    const testKits = await this.prisma.testKit.findMany({
      include: {
        user: true,
        rapidTests: {
          include: {
            user: true,
            testKit: true,
          },
        },
      },
    });
    return testKits.map(testKit => this.mapTestKitToGraphQL(testKit));
  }

  async findOne(id: string) {
    const testKit = await this.prisma.testKit.findUnique({
      where: { id },
      include: {
        user: true,
        rapidTests: {
          include: {
            user: true,
            testKit: true,
          },
        },
      },
    });
    return testKit ? this.mapTestKitToGraphQL(testKit) : null;
  }

  async findBySerialNumber(serialNumber: string) {
    const testKit = await this.prisma.testKit.findUnique({
      where: { serialNumber },
      include: {
        user: true,
        rapidTests: {
          include: {
            user: true,
            testKit: true,
          },
        },
      },
    });
    return testKit ? this.mapTestKitToGraphQL(testKit) : null;
  }

  async findAvailable() {
    const testKits = await this.prisma.testKit.findMany({
      where: { status: 'AVAILABLE' },
      include: {
        user: true,
        rapidTests: {
          include: {
            user: true,
            testKit: true,
          },
        },
      },
    });
    return testKits.map(testKit => this.mapTestKitToGraphQL(testKit));
  }

  async findByUserId(userId: string) {
    const testKits = await this.prisma.testKit.findMany({
      where: { userId },
      include: {
        user: true,
        rapidTests: {
          include: {
            user: true,
            testKit: true,
          },
        },
      },
    });
    return testKits.map(testKit => this.mapTestKitToGraphQL(testKit));
  }

  async create(data: any) {
    const testKit = await this.prisma.testKit.create({
      data: data as any,
      include: {
        user: true,
        rapidTests: {
          include: {
            user: true,
            testKit: true,
          },
        },
      },
    });
    return this.mapTestKitToGraphQL(testKit);
  }

  async update(id: string, data: any) {
    const testKit = await this.prisma.testKit.update({
      where: { id },
      data: data as any,
      include: {
        user: true,
        rapidTests: {
          include: {
            user: true,
            testKit: true,
          },
        },
      },
    });
    return this.mapTestKitToGraphQL(testKit);
  }

  async remove(id: string) {
    const testKit = await this.prisma.testKit.delete({
      where: { id },
      include: {
        user: true,
        rapidTests: {
          include: {
            user: true,
            testKit: true,
          },
        },
      },
    });
    return this.mapTestKitToGraphQL(testKit);
  }

  async assignToUser(id: string, userId: string) {
    const testKit = await this.prisma.testKit.update({
      where: { id },
      data: {
        userId,
        status: 'AVAILABLE' as any,
        purchasedAt: new Date(),
      },
      include: {
        user: true,
        rapidTests: {
          include: {
            user: true,
            testKit: true,
          },
        },
      },
    });
    return this.mapTestKitToGraphQL(testKit);
  }

  async markAsUsed(id: string) {
    const testKit = await this.prisma.testKit.update({
      where: { id },
      data: {
        status: 'USED' as any,
        usedAt: new Date(),
      },
      include: {
        user: true,
        rapidTests: {
          include: {
            user: true,
            testKit: true,
          },
        },
      },
    });
    return this.mapTestKitToGraphQL(testKit);
  }
} 