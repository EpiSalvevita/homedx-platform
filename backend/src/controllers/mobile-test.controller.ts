import {
  Body,
  Controller,
  Logger,
  Post,
  Request,
  UploadedFile,
  UseGuards,
  UseInterceptors,
} from '@nestjs/common';
import { FileInterceptor } from '@nestjs/platform-express';
import { RapidTestService } from '../services/rapid-test.service';
import { FileUploadService } from '../services/file-upload.service';
import { CubeService } from '../services/cube.service';
import { MobileTestService } from '../services/mobile-test.service';
import { JwtAuthGuard } from '../auth/jwt-auth.guard';
import { Public } from '../auth/public.decorator';
import {
  AddTestDto,
  FinalizeTestDto,
  IdentificationPhotoUploadDto,
  RapidTestMediaUploadDto,
  SubmitCubeDataDto,
} from '../dto/mobile/test.dto';
import { sanitizeMobileError } from '../util/mobile-error.util';
import {
  AddTestResponse,
  FinalizeTestResponse,
  MediaResponse,
  MOBILE_API_PATH,
  SubmitCubeDataResponse,
  TestListResponse,
  TestResultResponse,
} from './mobile.types';

@Controller(MOBILE_API_PATH)
export class MobileTestController {
  private readonly logger = new Logger(MobileTestController.name);

  constructor(
    private readonly rapidTestService: RapidTestService,
    private readonly fileUploadService: FileUploadService,
    private readonly cubeService: CubeService,
    private readonly mobileTestService: MobileTestService,
  ) {}

  @Public()
  @Post('get-test-type-list')
  async getTestTypeList(): Promise<TestListResponse> {
    try {
      const testTypes = [
        { name: 'RheumaCheck', id: 'rheumacheck', description: 'Rheumatoid arthritis screening test', icon: 'healing', color: 'FF0000' },
        { name: 'CRP (C-reaktives Protein)', id: 'crp', description: 'Schnelltest für C-reaktives Protein (Entzündungsmarker)', icon: 'monitor_heart', color: 'E91E63' },
        { name: 'Vitamin D', id: 'vitamind', description: 'Vitamin D deficiency screening test', icon: 'wb_sunny', color: 'FF9800' },
        { name: 'COVID-19 Rapid Test', id: 'covid-rapid', description: 'Rapid antigen test for COVID-19', icon: 'coronavirus', color: '2196F3' },
        { name: 'Antigen Test', id: 'antigen', description: 'General antigen test', icon: 'science', color: '4CAF50' },
        { name: 'PCR Test', id: 'pcr', description: 'Polymerase Chain Reaction test', icon: 'biotech', color: '9C27B0' },
      ];
      return { success: true, testTypes };
    } catch (error) {
      return sanitizeMobileError(error, 'Failed to get test types');
    }
  }

  @Post('add-test')
  @UseGuards(JwtAuthGuard)
  async addTest(
    @Request() req: { user?: { sub: string } },
    @Body() body: AddTestDto,
  ): Promise<AddTestResponse> {
    try {
      const userId = req.user?.sub;
      if (!userId) {
        return { success: false, error: 'Invalid token' };
      }
      const rapidTestId = await this.mobileTestService.createPendingTest(userId, body.testTypeId);
      return { success: true, rapidTestId };
    } catch (error) {
      return sanitizeMobileError(error, 'Failed to add test');
    }
  }

  @Post('submit-cube-data')
  @UseGuards(JwtAuthGuard)
  async submitCubeData(
    @Request() req: { user?: { sub: string } },
    @Body() body: SubmitCubeDataDto,
  ): Promise<SubmitCubeDataResponse> {
    try {
      const userId = req.user?.sub;
      if (!userId) {
        this.logger.warn('submit-cube-data rejected: no user on JWT payload');
        return { success: false, error: 'Invalid token' };
      }
      return await this.cubeService.submitCubeData(userId, body as Parameters<CubeService['submitCubeData']>[1]);
    } catch (error) {
      this.logger.error(`submit-cube-data exception: ${error instanceof Error ? error.message : error}`);
      return sanitizeMobileError(error, 'Failed to submit Cube data');
    }
  }

  @Post('get-last-test')
  @UseGuards(JwtAuthGuard)
  async getLastTest(@Request() req: { user: { sub: string } }): Promise<TestResultResponse> {
    try {
      const tests = await this.rapidTestService.findByUserId(req.user.sub);
      const sorted = [...tests].sort((a, b) => {
        const aTime = (a.testDate ?? a.createdAt).getTime();
        const bTime = (b.testDate ?? b.createdAt).getTime();
        return bTime - aTime;
      });
      const lastTests = sorted.map((test) => {
        const { testTypeId, resultData } = this.cubeService.parseCubeMetadata(test);
        return {
          id: test.id,
          testTypeId,
          result: test.result ?? null,
          status: test.status,
          testDate: (test.testDate ?? test.createdAt).getTime(),
          resultData,
        };
      });
      return { success: true, lastTests };
    } catch (error) {
      return sanitizeMobileError(error, 'Failed to get test results');
    }
  }

  @Post('add-rapid-test-photo')
  @UseGuards(JwtAuthGuard)
  @UseInterceptors(FileInterceptor('media'))
  async addRapidTestPhoto(
    @Request() req: { user?: { sub: string } },
    @UploadedFile() file: unknown,
    @Body() body: RapidTestMediaUploadDto,
  ): Promise<MediaResponse> {
    return this.uploadMedia(req, file, body, 'photos', (uid, rtId, name) =>
      this.mobileTestService.attachPhoto(uid, rtId, name),
    );
  }

  @Post('add-rapid-test-video')
  @UseGuards(JwtAuthGuard)
  @UseInterceptors(FileInterceptor('media'))
  async addRapidTestVideo(
    @Request() req: { user?: { sub: string } },
    @UploadedFile() file: unknown,
    @Body() body: RapidTestMediaUploadDto,
  ): Promise<MediaResponse> {
    return this.uploadMedia(req, file, body, 'videos', (uid, rtId, name) =>
      this.mobileTestService.attachVideo(uid, rtId, name),
    );
  }

  @Post('add-identification-photo')
  @UseGuards(JwtAuthGuard)
  @UseInterceptors(FileInterceptor('media'))
  async addIdentificationPhoto(
    @Request() req: { user?: { sub: string } },
    @UploadedFile() file: unknown,
    @Body() body: IdentificationPhotoUploadDto,
  ): Promise<MediaResponse> {
    return this.uploadMedia(req, file, body, 'identification', (uid, rtId, name) =>
      this.mobileTestService.attachIdentificationPhoto(uid, rtId, name, body.type),
    );
  }

  @Post('finalize-test-submission')
  @UseGuards(JwtAuthGuard)
  async finalizeTestSubmission(
    @Request() req: { user?: { sub: string } },
    @Body() body: FinalizeTestDto,
  ): Promise<FinalizeTestResponse> {
    try {
      const userId = req.user?.sub;
      if (!userId) {
        return { success: false, error: 'Invalid token' };
      }
      const rapidTest = await this.mobileTestService.finalizeSubmission(
        userId,
        body.rapidTestId,
        body.agreementGiven,
      );
      return { success: true, rapidTest };
    } catch (error) {
      return sanitizeMobileError(error, 'Failed to finalize test submission');
    }
  }

  private async uploadMedia(
    req: { user?: { sub: string } },
    file: unknown,
    body: RapidTestMediaUploadDto,
    folder: string,
    attach: (userId: string, rapidTestId: string, objectName: string) => Promise<unknown>,
  ): Promise<MediaResponse> {
    try {
      const userId = req.user?.sub;
      if (!userId) {
        return { success: false, error: 'Invalid token' };
      }
      const uploadResult = await this.fileUploadService.uploadFile(
        file as Parameters<FileUploadService['uploadFile']>[0],
        folder,
      );
      if (!uploadResult.success || !uploadResult.objectName) {
        return {
          success: false,
          error: uploadResult.validation || 'Failed to upload file',
        };
      }
      if (body.rapidTestId) {
        await attach(userId, body.rapidTestId, uploadResult.objectName);
      }
      return { success: true, objectName: uploadResult.objectName };
    } catch (error) {
      return sanitizeMobileError(error, 'Failed to upload file');
    }
  }
}
