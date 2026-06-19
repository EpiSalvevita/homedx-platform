import { Controller, Post, Body, Headers, UseGuards, UploadedFile, UseInterceptors, Request, Logger } from '@nestjs/common';
import { FileInterceptor } from '@nestjs/platform-express';
import { AuthService } from '../services/auth.service';
import { UserService } from '../services/user.service';
import { RapidTestService } from '../services/rapid-test.service';
import { FileUploadService } from '../services/file-upload.service';
import { DoctorService } from '../services/doctor.service';
import { AppointmentService } from '../services/appointment.service';
import { JwtAuthGuard } from '../auth/jwt-auth.guard';
import { RolesGuard } from '../auth/roles.guard';
import { Roles } from '../auth/roles.decorator';
import { JwtService } from '@nestjs/jwt';
import { PrismaService } from '../services/prisma.service';

// Mobile API Response Types
interface MobileResponse {
  success: boolean;
  error?: string;
  validation?: string[];
}

interface LoginResponse extends MobileResponse {
  token?: string;
}

interface UserDataResponse extends MobileResponse {
  userdata?: any;
}

interface TestListResponse extends MobileResponse {
  testTypes?: any[];
}

interface TestResultResponse extends MobileResponse {
  lastTests?: any[];
}

interface BackendStatusResponse extends MobileResponse {
  cwa?: boolean;
  cwaLaive?: boolean;
}

interface MediaResponse extends MobileResponse {
  objectName?: string;
}

interface LiveTokenResponse extends MobileResponse {
  liveToken?: string;
}

interface DoctorsResponse extends MobileResponse {
  doctors?: any[];
}

interface DoctorSlotsResponse extends MobileResponse {
  slots?: any[];
}

interface BookAppointmentResponse extends MobileResponse {
  appointmentId?: string;
  appointmentTime?: string;
}

interface AppointmentsResponse extends MobileResponse {
  appointments?: any[];
}

interface AppointmentResponse extends MobileResponse {
  appointment?: any;
}

interface VideoCallTokenResponse extends MobileResponse {
  roomUrl?: string;
  joinUrl?: string;
  token?: string;
  expiresAt?: string;
}

interface AvailabilityResponse extends MobileResponse {
  availability?: any[];
}

interface CubeResultDataItem {
  name: string;
  value: string;
  unit?: string;
  class?: string;
  validity?: number;
}

interface SubmitCubeDataResponse extends MobileResponse {
  testId?: string;
  result?: string;
  resultData?: CubeResultDataItem[];
}

@Controller('gg-homedx-json/gg-api/v1')
export class MobileController {
  private readonly logger = new Logger(MobileController.name);

  constructor(
    private readonly authService: AuthService,
    private readonly userService: UserService,
    private readonly rapidTestService: RapidTestService,
    private readonly fileUploadService: FileUploadService,
    private readonly doctorService: DoctorService,
    private readonly appointmentService: AppointmentService,
    private readonly jwtService: JwtService,
    private readonly prisma: PrismaService,
  ) {}

  @Post('login')
  async login(@Body() body: { user: string; pw: string; lang?: string }): Promise<LoginResponse> {
    try {
      const { user, pw } = body;
      
      // Use existing login method
      const result = await this.authService.login(user, pw);
      
      return {
        success: true,
        token: result.access_token,
      };
    } catch (error) {
      return {
        success: false,
        error: error.message || 'Login failed',
      };
    }
  }

  @Post('register-account')
  async registerAccount(@Body() body: {
    firstname: string;
    lastname: string;
    email: string;
    password: string;
    lang?: string;
  }): Promise<MobileResponse> {
    try {
      const { firstname, lastname, email, password } = body;
      
      // Check if user already exists
      const existingUser = await this.userService.findByEmail(email);
      if (existingUser) {
        return { success: false, error: 'User already exists' };
      }

      // Create new user
      await this.authService.signup(email, password, firstname, lastname);

      return { success: true };
    } catch (error) {
      return {
        success: false,
        error: error.message || 'Registration failed',
      };
    }
  }

  @Post('get-user-data')
  @UseGuards(JwtAuthGuard)
  async getUserData(@Request() req: any): Promise<UserDataResponse> {
    try {
      // User is already validated by JwtAuthGuard and attached to request
      const user = req.user;
      
      // Get user data
      const userData = await this.userService.findById(user.sub);
      
      return {
        success: true,
        userdata: {
          id: userData.id,
          firstname: userData.firstName,
          lastname: userData.lastName,
          email: userData.email,
          dob: userData.dateOfBirth?.getTime(),
          city: userData.city,
          country: userData.country,
          phone: userData.phone,
          address1: userData.address,
          postcode: userData.postalCode,
          testaccount: userData.role === 'ADMIN',
          role: userData.role,
          authorized: 'accepted', // Default for now
        },
      };
    } catch (error) {
      return {
        success: false,
        error: error.message || 'Failed to get user data',
      };
    }
  }

  @Post('update-user-data')
  @UseGuards(JwtAuthGuard)
  async updateUserData(
    @Headers('x-auth-token') token: string,
    @Body() body: any,
  ): Promise<MobileResponse> {
    try {
      const user = await this.authService.validateToken(token);
      if (!user) {
        return { success: false, error: 'Invalid token' };
      }

      // Update user data
      await this.userService.update(user.sub, {
        firstName: body.first_name,
        lastName: body.last_name,
        dateOfBirth: body.dob ? new Date(body.dob) : undefined,
        city: body.city,
        country: body.country,
        phone: body.phone,
        address1: body.address1,
        postcode: body.postcode,
      });

      return { success: true };
    } catch (error) {
      return {
        success: false,
        error: error.message || 'Failed to update user data',
      };
    }
  }

  @Post('get-test-type-list')
  async getTestTypeList(@Body() body: { lang?: string }): Promise<TestListResponse> {
    try {
      // Return available test types
      const testTypes = [
        { 
          name: 'RheumaCheck', 
          id: 'rheumacheck',
          description: 'Rheumatoid arthritis screening test',
          icon: 'healing',
          color: 'FF0000',
        },
        {
          name: 'CRP (C-reaktives Protein)',
          id: 'crp',
          description: 'Schnelltest für C-reaktives Protein (Entzündungsmarker)',
          icon: 'monitor_heart',
          color: 'E91E63',
        },
        { 
          name: 'Vitamin D', 
          id: 'vitamind',
          description: 'Vitamin D deficiency screening test',
          icon: 'wb_sunny',
          color: 'FF9800',
        },
        { 
          name: 'COVID-19 Rapid Test', 
          id: 'covid-rapid',
          description: 'Rapid antigen test for COVID-19',
          icon: 'coronavirus',
          color: '2196F3',
        },
        { 
          name: 'Antigen Test', 
          id: 'antigen',
          description: 'General antigen test',
          icon: 'science',
          color: '4CAF50',
        },
        { 
          name: 'PCR Test', 
          id: 'pcr',
          description: 'Polymerase Chain Reaction test',
          icon: 'biotech',
          color: '9C27B0',
        },
      ];

      return {
        success: true,
        testTypes,
      };
    } catch (error) {
      return {
        success: false,
        error: error.message || 'Failed to get test types',
      };
    }
  }

  @Post('add-test')
  @UseGuards(JwtAuthGuard)
  async addTest(
    @Headers('x-auth-token') token: string,
    @Body() body: { testTypeId: string; lang?: string },
  ): Promise<MobileResponse> {
    try {
      const user = await this.authService.validateToken(token);
      if (!user) {
        return { success: false, error: 'Invalid token' };
      }

      // Create rapid test
      await this.rapidTestService.create({
        userId: user.sub,
        testKitId: body.testTypeId,
        testDate: new Date(),
      });

      return { success: true };
    } catch (error) {
      return {
        success: false,
        error: error.message || 'Failed to add test',
      };
    }
  }

  @Post('submit-cube-data')
  @UseGuards(JwtAuthGuard)
  async submitCubeData(
    @Request() req: any,
    @Body()
    body: {
      testTypeId: string;
      rawData?: number[];
      deviceSerial?: string;
      measurementTimestamp?: number;
      result?: string;
      resultData?: CubeResultDataItem[];
    },
  ): Promise<SubmitCubeDataResponse> {
    try {
      const userId = req?.user?.sub;
      this.logger.log(
        `submit-cube-data enter userId=${userId ?? '(missing)'} testTypeId=${body?.testTypeId} ` +
          `deviceSerial=${body?.deviceSerial ?? '(none)'} result=${body?.result ?? '(none)'} ` +
          `resultDataLen=${body?.resultData?.length ?? 0} ts=${body?.measurementTimestamp ?? '(none)'}`,
      );
      if (Array.isArray(body?.resultData) && body.resultData.length > 0) {
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
      if (!userId) {
        this.logger.warn('submit-cube-data rejected: no user on JWT payload');
        return { success: false, error: 'Invalid token' };
      }
      if (!body?.testTypeId) {
        this.logger.warn('submit-cube-data rejected: testTypeId missing');
        return { success: false, error: 'testTypeId is required' };
      }

      // Reuse available kit; create a fallback if inventory is empty.
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
    } catch (error) {
      this.logger.error(
        `submit-cube-data exception: ${error?.message ?? error}`,
        error?.stack,
      );
      return {
        success: false,
        error: error.message || 'Failed to submit Cube data',
      };
    }
  }

  @Post('get-last-test')
  @UseGuards(JwtAuthGuard)
  async getLastTest(@Headers('x-auth-token') token: string): Promise<TestResultResponse> {
    try {
      const user = await this.authService.validateToken(token);
      if (!user) {
        return { success: false, error: 'Invalid token' };
      }

      const tests = await this.rapidTestService.findByUserId(user.sub);
      const sorted = [...tests].sort((a, b) => {
        const aTime = (a.testDate ?? a.createdAt).getTime();
        const bTime = (b.testDate ?? b.createdAt).getTime();
        return bTime - aTime;
      });

      const lastTests = sorted.map((test) => {
        let testTypeId: string | null = null;
        let resultData: CubeResultDataItem[] = [];
        if (test.notes) {
          try {
            const parsed = JSON.parse(test.notes);
            testTypeId = parsed?.testTypeId ?? null;
            if (Array.isArray(parsed?.resultData)) {
              resultData = parsed.resultData;
            }
          } catch {
            // ignore malformed notes
          }
        }
        return {
          id: test.id,
          testTypeId,
          result: test.result ?? null,
          status: test.status,
          testDate: (test.testDate ?? test.createdAt).getTime(),
          resultData,
        };
      });

      return {
        success: true,
        lastTests,
      };
    } catch (error) {
      return {
        success: false,
        error: error.message || 'Failed to get test results',
      };
    }
  }

  @Post('add-rapid-test-photo')
  @UseGuards(JwtAuthGuard)
  @UseInterceptors(FileInterceptor('media'))
  async addRapidTestPhoto(
    @Headers('x-auth-token') token: string,
    @UploadedFile() file: any,
    @Body() body: { fileExtension: string },
  ): Promise<MediaResponse> {
    try {
      const user = await this.authService.validateToken(token);
      if (!user) {
        return { success: false, error: 'Invalid token' };
      }

      // Upload file
      const uploadResult = await this.fileUploadService.uploadFile(file, 'photos');
      
      return {
        success: true,
        objectName: uploadResult.objectName,
      };
    } catch (error) {
      return {
        success: false,
        error: error.message || 'Failed to upload photo',
      };
    }
  }

  @Post('add-rapid-test-video')
  @UseGuards(JwtAuthGuard)
  @UseInterceptors(FileInterceptor('media'))
  async addRapidTestVideo(
    @Headers('x-auth-token') token: string,
    @UploadedFile() file: any,
    @Body() body: { fileExtension: string },
  ): Promise<MediaResponse> {
    try {
      const user = await this.authService.validateToken(token);
      if (!user) {
        return { success: false, error: 'Invalid token' };
      }

      // Upload file
      const uploadResult = await this.fileUploadService.uploadFile(file, 'videos');
      
      return {
        success: true,
        objectName: uploadResult.objectName,
      };
    } catch (error) {
      return {
        success: false,
        error: error.message || 'Failed to upload video',
      };
    }
  }

  @Post('add-identification-photo')
  @UseGuards(JwtAuthGuard)
  @UseInterceptors(FileInterceptor('media'))
  async addIdentificationPhoto(
    @Headers('x-auth-token') token: string,
    @UploadedFile() file: any,
    @Body() body: { fileExtension: string; type: string },
  ): Promise<MediaResponse> {
    try {
      const user = await this.authService.validateToken(token);
      if (!user) {
        return { success: false, error: 'Invalid token' };
      }

      // Upload file
      const uploadResult = await this.fileUploadService.uploadFile(file, 'identification');
      
      return {
        success: true,
        objectName: uploadResult.objectName,
      };
    } catch (error) {
      return {
        success: false,
        error: error.message || 'Failed to upload identification photo',
      };
    }
  }

  @Post('get-be-status-flags')
  async getBackendStatus(@Body() body: { lang?: string }): Promise<BackendStatusResponse> {
    try {
      return {
        success: true,
        cwa: true,
        cwaLaive: true,
      };
    } catch (error) {
      return {
        success: false,
        error: error.message || 'Failed to get backend status',
      };
    }
  }

  @Post('get-live-token')
  @UseGuards(JwtAuthGuard)
  async getLiveToken(@Headers('x-auth-token') token: string): Promise<LiveTokenResponse> {
    try {
      const user = await this.authService.validateToken(token);
      if (!user) {
        return { success: false, error: 'Invalid token' };
      }

      // Generate live token (for real-time features)
      const liveToken = `live_${Date.now()}_${user.id}`;
      
      return {
        success: true,
        liveToken,
      };
    } catch (error) {
      return {
        success: false,
        error: error.message || 'Failed to get live token',
      };
    }
  }

  @Post('init-authentication')
  @UseGuards(JwtAuthGuard)
  async initAuthentication(@Headers('x-auth-token') token: string): Promise<MobileResponse> {
    try {
      const user = await this.authService.validateToken(token);
      if (!user) {
        return { success: false, error: 'Invalid token' };
      }

      // Initialize authentication process
      return { success: true };
    } catch (error) {
      return {
        success: false,
        error: error.message || 'Failed to initialize authentication',
      };
    }
  }

  @Post('get-doctors')
  @UseGuards(JwtAuthGuard)
  async getDoctors(
    @Request() req: any,
    @Body() body: { testTypeId?: string; lang?: string },
  ): Promise<DoctorsResponse> {
    try {
      const doctors = await this.doctorService.listDoctors(body.testTypeId);
      return { success: true, doctors };
    } catch (error) {
      return {
        success: false,
        error: error.message || 'Failed to get doctors',
      };
    }
  }

  @Post('get-doctor-slots')
  @UseGuards(JwtAuthGuard)
  async getDoctorSlots(
    @Body() body: { doctorId: string; from?: string; to?: string; lang?: string },
  ): Promise<DoctorSlotsResponse> {
    try {
      if (!body.doctorId) {
        return { success: false, error: 'doctorId is required' };
      }
      const from = body.from ? new Date(body.from) : undefined;
      const to = body.to ? new Date(body.to) : undefined;
      const slots = await this.doctorService.getAvailableSlots(body.doctorId, from, to);
      return { success: true, slots };
    } catch (error) {
      return {
        success: false,
        error: error.message || 'Failed to get doctor slots',
      };
    }
  }

  @Post('book-appointment')
  @UseGuards(JwtAuthGuard)
  async bookAppointment(
    @Request() req: any,
    @Body()
    body: {
      doctorId: string;
      appointmentTime: string;
      type: string;
      notes?: string;
      testTypeId?: string;
      lang?: string;
    },
  ): Promise<BookAppointmentResponse> {
    try {
      const userId = req.user?.sub;
      if (!userId) {
        return { success: false, error: 'Invalid token' };
      }
      if (!body.doctorId || !body.appointmentTime) {
        return { success: false, error: 'doctorId and appointmentTime are required' };
      }

      const appointment = await this.appointmentService.bookAppointment({
        patientId: userId,
        doctorId: body.doctorId,
        appointmentTime: new Date(body.appointmentTime),
        type: body.type ?? 'online',
        notes: body.notes,
        testTypeId: body.testTypeId,
      });

      return {
        success: true,
        appointmentId: appointment.id,
        appointmentTime: appointment.scheduledAt.toISOString(),
      };
    } catch (error) {
      return {
        success: false,
        error: error.message || 'Failed to book appointment',
      };
    }
  }

  @Post('list-appointments')
  @UseGuards(JwtAuthGuard)
  async listAppointments(@Request() req: any): Promise<AppointmentsResponse> {
    try {
      const userId = req.user?.sub;
      const role = await this.resolveUserRole(userId);
      if (!userId) {
        return { success: false, error: 'Invalid token' };
      }

      const appointments = await this.appointmentService.listAppointments(userId, role);
      return { success: true, appointments };
    } catch (error) {
      return {
        success: false,
        error: error.message || 'Failed to list appointments',
      };
    }
  }

  @Post('get-appointment')
  @UseGuards(JwtAuthGuard)
  async getAppointment(
    @Request() req: any,
    @Body() body: { appointmentId: string },
  ): Promise<AppointmentResponse> {
    try {
      const userId = req.user?.sub;
      const role = await this.resolveUserRole(userId);
      if (!userId || !body.appointmentId) {
        return { success: false, error: 'Invalid request' };
      }

      const appointment = await this.appointmentService.getAppointment(
        body.appointmentId,
        userId,
        role,
      );
      return { success: true, appointment };
    } catch (error) {
      return {
        success: false,
        error: error.message || 'Failed to get appointment',
      };
    }
  }

  @Post('cancel-appointment')
  @UseGuards(JwtAuthGuard)
  async cancelAppointment(
    @Request() req: any,
    @Body() body: { appointmentId: string },
  ): Promise<AppointmentResponse> {
    try {
      const userId = req.user?.sub;
      const role = await this.resolveUserRole(userId);
      if (!userId || !body.appointmentId) {
        return { success: false, error: 'Invalid request' };
      }

      const appointment = await this.appointmentService.cancelAppointment(
        body.appointmentId,
        userId,
        role,
      );
      return { success: true, appointment };
    } catch (error) {
      return {
        success: false,
        error: error.message || 'Failed to cancel appointment',
      };
    }
  }

  @Post('get-video-call-token')
  @UseGuards(JwtAuthGuard)
  async getVideoCallToken(
    @Request() req: any,
    @Body() body: { appointmentId: string },
  ): Promise<VideoCallTokenResponse> {
    try {
      const userId = req.user?.sub;
      const role = await this.resolveUserRole(userId);
      if (!userId || !body.appointmentId) {
        return { success: false, error: 'Invalid request' };
      }

      const result = await this.appointmentService.getVideoCallToken(
        body.appointmentId,
        userId,
        role,
      );
      return { success: true, ...result };
    } catch (error) {
      return {
        success: false,
        error: error.message || 'Failed to get video call token',
      };
    }
  }

  @Post('get-doctor-availability')
  @UseGuards(JwtAuthGuard, RolesGuard)
  @Roles('DOCTOR')
  async getDoctorAvailability(@Request() req: any): Promise<AvailabilityResponse> {
    try {
      const userId = req.user?.sub;
      if (!userId) {
        return { success: false, error: 'Invalid token' };
      }

      const availability = await this.doctorService.getAvailability(userId);
      return { success: true, availability };
    } catch (error) {
      return {
        success: false,
        error: error.message || 'Failed to get availability',
      };
    }
  }

  @Post('set-doctor-availability')
  @UseGuards(JwtAuthGuard, RolesGuard)
  @Roles('DOCTOR')
  async setDoctorAvailability(
    @Request() req: any,
    @Body()
    body: {
      availability: Array<{
        dayOfWeek: number;
        startTime: string;
        endTime: string;
        slotMinutes?: number;
      }>;
    },
  ): Promise<AvailabilityResponse> {
    try {
      const userId = req.user?.sub;
      if (!userId) {
        return { success: false, error: 'Invalid token' };
      }

      const availability = await this.doctorService.setAvailability(
        userId,
        body.availability ?? [],
      );
      return { success: true, availability };
    } catch (error) {
      return {
        success: false,
        error: error.message || 'Failed to set availability',
      };
    }
  }

  @Post('unset-authentication')
  @UseGuards(JwtAuthGuard)
  async unsetAuthentication(@Headers('x-auth-token') token: string): Promise<MobileResponse> {
    try {
      const user = await this.authService.validateToken(token);
      if (!user) {
        return { success: false, error: 'Invalid token' };
      }

      // Unset authentication
      return { success: true };
    } catch (error) {
      return {
        success: false,
        error: error.message || 'Failed to unset authentication',
      };
    }
  }

  private async resolveUserRole(userId: string): Promise<string> {
    if (!userId) return 'USER';
    const user = await this.prisma.user.findUnique({
      where: { id: userId },
      select: { role: true },
    });
    return user?.role ?? 'USER';
  }

  private normalizeCubeResult(
    result?: string,
    resultData?: CubeResultDataItem[],
  ): 'POSITIVE' | 'NEGATIVE' | 'INVALID' | 'INCONCLUSIVE' {
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
}
