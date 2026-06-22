import { ForbiddenException, Injectable } from '@nestjs/common';
import { PrismaService } from './prisma.service';

export interface MobileRapidTestSummary {
  id: string;
  testTypeId: string | null;
  status: string;
  result: string | null;
  agreementGiven: boolean;
  photoUrl: string | null;
  videoUrl: string | null;
  identityCard1Url: string | null;
  identityCard2Url: string | null;
  testDate: string;
}

@Injectable()
export class MobileTestService {
  constructor(private readonly prisma: PrismaService) {}

  async resolveAvailableTestKit() {
    let testKit = await this.prisma.testKit.findFirst({
      where: { status: 'AVAILABLE' },
    });
    if (!testKit) {
      testKit = await this.prisma.testKit.create({
        data: {
          serialNumber: `MOBILE-${Date.now()}`,
          type: 'COVID_19',
          manufacturer: 'HomeDX',
          model: 'Mobile',
          batchNumber: `BATCH-${Date.now()}`,
          expirationDate: new Date(Date.now() + 365 * 24 * 60 * 60 * 1000),
          status: 'AVAILABLE',
        },
      });
    }
    return testKit;
  }

  async createPendingTest(userId: string, testTypeId: string): Promise<string> {
    const testKit = await this.resolveAvailableTestKit();
    const rapidTest = await this.prisma.rapidTest.create({
      data: {
        userId,
        testKitId: testKit.id,
        testTypeId,
        testDate: new Date(),
        status: 'PENDING',
        source: 'mobile',
        agreementGiven: false,
      },
    });
    return rapidTest.id;
  }

  async assertTestOwner(rapidTestId: string, userId: string) {
    const test = await this.prisma.rapidTest.findUnique({
      where: { id: rapidTestId },
    });
    if (!test || test.userId !== userId) {
      throw new ForbiddenException('Rapid test not found');
    }
    return test;
  }

  private mediaPath(subdirectory: string, objectName: string): string {
    return `${subdirectory}/${objectName}`;
  }

  async attachPhoto(userId: string, rapidTestId: string, objectName: string) {
    await this.assertTestOwner(rapidTestId, userId);
    return this.prisma.rapidTest.update({
      where: { id: rapidTestId },
      data: { photoUrl: this.mediaPath('photos', objectName) },
    });
  }

  async attachVideo(userId: string, rapidTestId: string, objectName: string) {
    await this.assertTestOwner(rapidTestId, userId);
    return this.prisma.rapidTest.update({
      where: { id: rapidTestId },
      data: { videoUrl: this.mediaPath('videos', objectName) },
    });
  }

  async attachIdentificationPhoto(
    userId: string,
    rapidTestId: string,
    objectName: string,
    type: string,
  ) {
    await this.assertTestOwner(rapidTestId, userId);
    const path = this.mediaPath('identification', objectName);
    const data =
      type === 'back' || type === 'identityCard2'
        ? { identityCard2Url: path }
        : { identityCard1Url: path };
    return this.prisma.rapidTest.update({
      where: { id: rapidTestId },
      data,
    });
  }

  async finalizeSubmission(
    userId: string,
    rapidTestId: string,
    agreementGiven: boolean,
  ): Promise<MobileRapidTestSummary> {
    const test = await this.assertTestOwner(rapidTestId, userId);
    if (!agreementGiven) {
      throw new ForbiddenException('Agreement must be accepted');
    }

    const updated = await this.prisma.rapidTest.update({
      where: { id: rapidTestId },
      data: {
        agreementGiven: true,
        status: test.status === 'PENDING' ? 'COMPLETED' : test.status,
        completedAt: test.completedAt ?? new Date(),
      },
    });

    return this.toSummary(updated);
  }

  toSummary(test: {
    id: string;
    testTypeId: string | null;
    status: string;
    result: string | null;
    agreementGiven: boolean;
    photoUrl: string | null;
    videoUrl: string | null;
    identityCard1Url: string | null;
    identityCard2Url: string | null;
    testDate: Date;
  }): MobileRapidTestSummary {
    return {
      id: test.id,
      testTypeId: test.testTypeId,
      status: test.status,
      result: test.result,
      agreementGiven: test.agreementGiven,
      photoUrl: test.photoUrl,
      videoUrl: test.videoUrl,
      identityCard1Url: test.identityCard1Url,
      identityCard2Url: test.identityCard2Url,
      testDate: test.testDate.toISOString(),
    };
  }
}
