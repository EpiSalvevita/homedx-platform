import { Body, Controller, Logger, Post, Request, Res, UseGuards } from '@nestjs/common';
import type { Response } from 'express';
import { Throttle } from '@nestjs/throttler';
import { AuthService } from '../services/auth.service';
import { UserService } from '../services/user.service';
import { JwtAuthGuard } from '../auth/jwt-auth.guard';
import { Public } from '../auth/public.decorator';
import {
  AUTH_COOKIE_NAME,
  getAuthCookieClearOptions,
  getAuthCookieOptions,
} from '../config/auth-cookie.config';
import { LoginDto, RegisterDto, UpdateUserDataDto } from '../dto/mobile/auth.dto';
import { sanitizeMobileError } from '../util/mobile-error.util';
import {
  BackendStatusResponse,
  LiveTokenResponse,
  LoginResponse,
  MOBILE_API_PATH,
  MobileResponse,
  UserDataResponse,
} from './mobile.types';

@Controller(MOBILE_API_PATH)
export class MobileAuthController {
  private readonly logger = new Logger(MobileAuthController.name);

  constructor(
    private readonly authService: AuthService,
    private readonly userService: UserService,
  ) {}

  @Public()
  @Throttle({ default: { limit: 10, ttl: 60000 } })
  @Post('login')
  async login(@Body() body: LoginDto, @Res({ passthrough: true }) res: Response): Promise<LoginResponse> {
    try {
      const result = await this.authService.login(body.user, body.pw);
      res.cookie(AUTH_COOKIE_NAME, result.access_token, getAuthCookieOptions());
      return { success: true, token: result.access_token };
    } catch (error) {
      return sanitizeMobileError(error, 'Login failed');
    }
  }

  @Public()
  @Throttle({ default: { limit: 10, ttl: 60000 } })
  @Post('register-account')
  async registerAccount(@Body() body: RegisterDto): Promise<MobileResponse> {
    try {
      const existingUser = await this.userService.findByEmail(body.email);
      if (existingUser) {
        return { success: false, error: 'User already exists' };
      }
      await this.authService.signup(body.email, body.password, body.firstname, body.lastname);
      return { success: true };
    } catch (error) {
      return sanitizeMobileError(error, 'Registration failed');
    }
  }

  @Post('get-user-data')
  @UseGuards(JwtAuthGuard)
  async getUserData(@Request() req: { user: { sub: string } }): Promise<UserDataResponse> {
    try {
      const userData = await this.userService.findById(req.user.sub);
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
          authorized: 'accepted',
        },
      };
    } catch (error) {
      return sanitizeMobileError(error, 'Failed to get user data');
    }
  }

  @Post('update-user-data')
  @UseGuards(JwtAuthGuard)
  async updateUserData(
    @Request() req: { user: { sub: string } },
    @Body() body: UpdateUserDataDto,
  ): Promise<MobileResponse> {
    try {
      await this.userService.update(req.user.sub, {
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
      return sanitizeMobileError(error, 'Failed to update user data');
    }
  }

  @Public()
  @Post('get-be-status-flags')
  async getBackendStatus(): Promise<BackendStatusResponse> {
    return { success: true, online: true };
  }

  @Post('get-live-token')
  @UseGuards(JwtAuthGuard)
  async getLiveToken(@Request() req: { user: { sub: string; id?: string } }): Promise<LiveTokenResponse> {
    try {
      const liveToken = `live_${Date.now()}_${req.user.id ?? req.user.sub}`;
      return { success: true, liveToken };
    } catch (error) {
      return sanitizeMobileError(error, 'Failed to get live token');
    }
  }

  @Post('init-authentication')
  @UseGuards(JwtAuthGuard)
  async initAuthentication(@Request() req: { user: { sub: string } }): Promise<MobileResponse> {
    if (!req.user?.sub) {
      return { success: false, error: 'Invalid token' };
    }
    return { success: true };
  }

  @Post('unset-authentication')
  @UseGuards(JwtAuthGuard)
  async unsetAuthentication(
    @Request() req: { user: { sub: string } },
    @Res({ passthrough: true }) res: Response,
  ): Promise<MobileResponse> {
    if (!req.user?.sub) {
      return { success: false, error: 'Invalid token' };
    }
    res.clearCookie(AUTH_COOKIE_NAME, getAuthCookieClearOptions());
    return { success: true };
  }
}
