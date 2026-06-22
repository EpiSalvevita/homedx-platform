import { Injectable, Logger } from '@nestjs/common';
import { Prisma } from '@prisma/client';
import { PrismaService } from './prisma.service';

export interface CubeResultDataItem {
  name: string;
  value: string;
  unit?: string;
  class?: string;
  validity?: number;
}

export interface SubmitCubeDataInput {
  testTypeId: string;
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
}

export type NormalizedCubeResult =
  | 'POSITIVE'
  | 'NEGATIVE'
  | 'INVALID'
  | 'INCONCLUSIVE';

@Injectable()
export class CubeService {
  private readonly logger = new Logger(CubeService.name);

  constructor(private readonly prisma: PrismaService) {}

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

  async submitCubeData(
    userId: string,
    body: SubmitCubeDataInput,
  ): Promise<SubmitCubeDataResult> {
    this.logger.log(
      `submit-cube-data enter userId=${userId} testTypeId=${body.testTypeId} ` +
        `deviceSerial=${body.deviceSerial ?? '(none)'} result=${body.result ?? '(none)'} ` +
        `resultDataLen=${body.resultData?.length ?? 0} ts=${body.measurementTimestamp ?? '(none)'}`,
    );

    if (!body.testTypeId) {
      this.logger.warn('submit-cube-data rejected: testTypeId missing');
      return { success: false, error: 'testTypeId is required' };
    }

    if (Array.isArray(body.resultData) && body.resultData.length > 0) {
      const preview = body.resultData.slice(0, 12).map((r, idx) => ({
        i: idx,
        name: r?.name,
        value:
          typeof r?.value === 'string' && r.value.length > 32
            ? `${r.value.slice(0, 32)}…`
            : r?.value,
        unit: r?.unit,
        class: r?.class,
        validity: r?.validity,
      }));
      this.logger.log(`submit-cube-data resultDataPreview=${JSON.stringify(preview)}`);
    }

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

    const normalizedResult = this.normalizeCubeResult(body.result, body.resultData);
    this.logger.log(`submit-cube-data normalizedResult=${normalizedResult}`);

    const testDate = body.measurementTimestamp
      ? new Date(body.measurementTimestamp)
      : new Date();

    const rapidTest = await this.prisma.rapidTest.create({
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
        notes: JSON.stringify({
          source: 'cube',
          testTypeId: body.testTypeId,
          deviceSerial: body.deviceSerial ?? null,
          measurementTimestamp: body.measurementTimestamp ?? null,
          rawData: body.rawData ?? null,
          resultData: body.resultData ?? [],
        }),
      },
    });

    this.logger.log(
      `submit-cube-data success rapidTestId=${rapidTest.id} testKitId=${testKit.id} normalized=${normalizedResult}`,
    );

    return {
      success: true,
      testId: rapidTest.id,
      result: normalizedResult,
      resultData: body.resultData ?? [],
    };
  }
}
