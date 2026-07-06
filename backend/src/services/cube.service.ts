import { Injectable, Logger } from '@nestjs/common';
import { Prisma } from '@prisma/client';
import { PrismaService } from './prisma.service';
import { MobileCertificateService } from './mobile-certificate.service';
import { MobileNotificationService } from './mobile-notification.service';
import { AuditLogService } from './audit-log.service';

export interface CubeResultDataItem {
  name: string;
  value: string;
  unit?: string;
  class?: string;
  validity?: number;
}

export interface SubmitCubeDataInput {
  testTypeId: string;
  rapidTestId?: string;
  rawData?: number[];
  deviceSerial?: string;
  measurementTimestamp?: number;
  result?: string;
  resultData?: CubeResultDataItem[];
}

export interface SubmitCubeDataResult {
  success: boolean;
  error?: string;
  testId?: string;
  result?: string;
  resultData?: CubeResultDataItem[];
  certificateId?: string;
}

export type NormalizedCubeResult =
  | 'POSITIVE'
  | 'NEGATIVE'
  | 'INVALID'
  | 'INCONCLUSIVE';

@Injectable()
export class CubeService {
  private readonly logger = new Logger(CubeService.name);

  constructor(
    private readonly prisma: PrismaService,
    private readonly mobileCertificateService: MobileCertificateService,
    private readonly mobileNotificationService: MobileNotificationService,
    private readonly auditLogService: AuditLogService,
  ) {}

  normalizeCubeResult(
    result?: string,
    resultData?: CubeResultDataItem[],
  ): NormalizedCubeResult {
    const normalized = (result ?? '').toUpperCase();
    if (
      normalized === 'POSITIVE' ||
      normalized === 'NEGATIVE' ||
      normalized === 'INVALID' ||
      normalized === 'INCONCLUSIVE'
    ) {
      return normalized;
    }

    for (const entry of resultData ?? []) {
      const cls = (entry.class ?? '').toUpperCase();
      if (cls === 'POSITIVE' || cls === 'POS') return 'POSITIVE';
      if (cls === 'NEGATIVE' || cls === 'NEG') return 'NEGATIVE';
      if (cls === 'INVALID') return 'INVALID';
      if (cls === 'INCONCLUSIVE') return 'INCONCLUSIVE';
    }

    return 'INCONCLUSIVE';
  }

  parseCubeMetadata(test: {
    notes?: string | null;
    testTypeId?: string | null;
    cubeResultData?: unknown;
  }): {
    testTypeId: string | null;
    resultData: CubeResultDataItem[];
  } {
    if (test.testTypeId) {
      return {
        testTypeId: test.testTypeId,
        resultData: this.coerceResultData(test.cubeResultData),
      };
    }

    return this.parseCubeNotes(test.notes);
  }

  parseCubeNotes(notes: string | null | undefined): {
    testTypeId: string | null;
    resultData: CubeResultDataItem[];
  } {
    if (!notes) {
      return { testTypeId: null, resultData: [] };
    }

    try {
      const parsed = JSON.parse(notes);
      return {
        testTypeId: parsed?.testTypeId ?? null,
        resultData: this.coerceResultData(parsed?.resultData),
      };
    } catch {
      return { testTypeId: null, resultData: [] };
    }
  }

  private coerceResultData(value: unknown): CubeResultDataItem[] {
    if (!Array.isArray(value)) {
      return [];
    }
    return value as CubeResultDataItem[];
  }

  private async resolveAvailableTestKit() {
    let testKit = await this.prisma.testKit.findFirst({
      where: { status: 'AVAILABLE' },
    });
    if (!testKit) {
      testKit = await this.prisma.testKit.create({
        data: {
          serialNumber: `CUBE-${Date.now()}`,
          type: 'COVID_19',
          manufacturer: 'Cube Device',
          model: 'Cube',
          batchNumber: `CUBE-BATCH-${Date.now()}`,
          expirationDate: new Date(Date.now() + 365 * 24 * 60 * 60 * 1000),
          status: 'AVAILABLE',
        },
      });
    }
    return testKit;
  }

  async submitCubeData(
    userId: string,
    body: SubmitCubeDataInput,
  ): Promise<SubmitCubeDataResult> {
    this.logger.log(
      `submit-cube-data enter userId=${userId} testTypeId=${body.testTypeId} ` +
        `rapidTestId=${body.rapidTestId ?? '(none)'} ` +
        `deviceSerial=${body.deviceSerial ?? '(none)'} result=${body.result ?? '(none)'} ` +
        `resultDataLen=${body.resultData?.length ?? 0} ts=${body.measurementTimestamp ?? '(none)'}`,
    );

    if (!body.testTypeId) {
      this.logger.warn('submit-cube-data rejected: testTypeId missing');
      return { success: false, error: 'testTypeId is required' };
    }

    const normalizedResult = this.normalizeCubeResult(body.result, body.resultData);
    const testDate = body.measurementTimestamp
      ? new Date(body.measurementTimestamp)
      : new Date();

    const notesPayload = JSON.stringify({
      source: 'cube',
      testTypeId: body.testTypeId,
      deviceSerial: body.deviceSerial ?? null,
      measurementTimestamp: body.measurementTimestamp ?? null,
      rawData: body.rawData ?? null,
      resultData: body.resultData ?? [],
    });

    let rapidTest;

    if (body.rapidTestId) {
      const existing = await this.prisma.rapidTest.findUnique({
        where: { id: body.rapidTestId },
      });
      if (!existing || existing.userId !== userId) {
        return { success: false, error: 'Rapid test not found' };
      }

      rapidTest = await this.prisma.rapidTest.update({
        where: { id: body.rapidTestId },
        data: {
          testDate,
          completedAt: new Date(),
          status: 'COMPLETED',
          result: normalizedResult,
          testTypeId: body.testTypeId,
          source: 'cube',
          deviceSerial: body.deviceSerial ?? null,
          cubeResultData: (body.resultData ?? []) as unknown as Prisma.InputJsonValue,
          cubeRawData: (body.rawData ?? null) as unknown as Prisma.InputJsonValue,
          notes: notesPayload,
        },
      });
    } else {
      const testKit = await this.resolveAvailableTestKit();
      rapidTest = await this.prisma.rapidTest.create({
        data: {
          userId,
          testKitId: testKit.id,
          testDate,
          completedAt: new Date(),
          status: 'COMPLETED',
          result: normalizedResult,
          testTypeId: body.testTypeId,
          source: 'cube',
          deviceSerial: body.deviceSerial ?? null,
          cubeResultData: (body.resultData ?? []) as unknown as Prisma.InputJsonValue,
          cubeRawData: (body.rawData ?? null) as unknown as Prisma.InputJsonValue,
          notes: notesPayload,
        },
      });
    }

    this.logger.log(
      `submit-cube-data success rapidTestId=${rapidTest.id} normalized=${normalizedResult}`,
    );

    try {
      await this.auditLogService.create({
        userId,
        action: body.rapidTestId ? 'UPDATE' : 'CREATE',
        entityType: 'RAPID_TEST',
        entityId: rapidTest.id,
        description: `Cube data submitted: testTypeId=${body.testTypeId} result=${normalizedResult}.`,
      });
    } catch (error) {
      // Audit logging must never block a Cube result from being saved.
      this.logger.warn(`Audit log write failed for rapidTestId=${rapidTest.id}: ${error?.message ?? error}`);
    }

    let certificateId: string | undefined;
    try {
      const certificate = await this.mobileCertificateService.issueForRapidTest(
        rapidTest.id,
      );
      if (certificate) {
        certificateId = certificate.id;
        await this.mobileNotificationService.notifyUser(userId, {
          type: 'CERTIFICATE_READY',
          title: 'Zertifikat bereit',
          message: `Ihr Testzertifikat ${certificate.certificateNumber} ist verfügbar.`,
          data: { certificateId: certificate.id, rapidTestId: rapidTest.id },
        });
      }
    } catch (error) {
      this.logger.warn(`Certificate/notification after cube submit failed: ${error?.message ?? error}`);
    }

    return {
      success: true,
      testId: rapidTest.id,
      result: normalizedResult,
      resultData: body.resultData ?? [],
      certificateId,
    };
  }
}
