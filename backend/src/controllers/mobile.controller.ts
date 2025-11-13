import { Controller, Post, Body, Headers, UseGuards, UploadedFile, UseInterceptors, Request } from '@nestjs/common';
import { FileInterceptor } from '@nestjs/platform-express';
import { AuthService } from '../services/auth.service';
import { UserService } from '../services/user.service';
import { RapidTestService } from '../services/rapid-test.service';
import { FileUploadService } from '../services/file-upload.service';
import { JwtAuthGuard } from '../auth/jwt-auth.guard';
import { JwtService } from '@nestjs/jwt';

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

@Controller('gg-homedx-json/gg-api/v1')
export class MobileController {
  constructor(
    private readonly authService: AuthService,
    private readonly userService: UserService,
    private readonly rapidTestService: RapidTestService,
    private readonly fileUploadService: FileUploadService,
    private readonly jwtService: JwtService,
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
        { name: 'COVID-19 Rapid Test', id: 'covid-rapid' },
        { name: 'Antigen Test', id: 'antigen' },
        { name: 'PCR Test', id: 'pcr' },
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

  @Post('get-last-test')
  @UseGuards(JwtAuthGuard)
  async getLastTest(@Headers('x-auth-token') token: string): Promise<TestResultResponse> {
    try {
      const user = await this.authService.validateToken(token);
      if (!user) {
        return { success: false, error: 'Invalid token' };
      }

      // Get user's tests
      const tests = await this.rapidTestService.findByUserId(user.sub);
      const lastTests = tests.map(test => ({
        lastTest: {
          result: test.result || 'pending',
          testDate: test.createdAt.getTime(),
        },
      }));

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
}
