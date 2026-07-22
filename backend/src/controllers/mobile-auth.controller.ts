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
import { LoginDto, RegisterDto, RequestPasswordResetDto, ResetPasswordDto, UpdateUserDataDto } from '../dto/mobile/auth.dto';
import { sanitizeMobileError } from '../utils/mobile-error.util';
import { registrationEmailExistsMessage } from '../utils/registration-messages';
import {
  BackendStatusResponse,
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
      const result = await this.authService.login(body.user, body.pw, body.lang);
      res.cookie(AUTH_COOKIE_NAME, result.access_token, getAuthCookieOptions());
      return { success: true, token: result.access_token };
    } catch (error) {
      return sanitizeMobileError(error, 'Anmeldung fehlgeschlagen');
    }
  }

  @Public()
  @Throttle({ default: { limit: 5, ttl: 60000 } })
  @Post('request-password-reset')
  async requestPasswordReset(@Body() body: RequestPasswordResetDto): Promise<MobileResponse> {
    try {
      const result = await this.authService.requestPasswordReset(body.email, body.lang);
      return { success: true, message: result.message };
    } catch (error) {
      return sanitizeMobileError(error, 'Passwort zurücksetzen fehlgeschlagen');
    }
  }

  @Public()
  @Throttle({ default: { limit: 10, ttl: 60000 } })
  @Post('reset-password')
  async resetPassword(@Body() body: ResetPasswordDto): Promise<MobileResponse> {
    try {
      const result = await this.authService.resetPassword(body.token, body.password, body.lang);
      return { success: true, message: result.message };
    } catch (error) {
      return sanitizeMobileError(error, 'Passwort zurücksetzen fehlgeschlagen');
    }
  }

  @Public()
  @Throttle({ default: { limit: 10, ttl: 60000 } })
  @Post('register-account')
  async registerAccount(@Body() body: RegisterDto): Promise<MobileResponse> {
    try {
      const existingUser = await this.userService.findByEmail(body.email);
      if (existingUser) {
        return {
          success: false,
          error: registrationEmailExistsMessage(body.lang),
        };
      }
      await this.authService.signup(
        body.email,
        body.password,
        body.firstname,
        body.lastname,
        body.role === 'DOCTOR'
          ? {
              asDoctor: true,
              specialization: body.specialization,
              clinicAddress: body.clinic_address,
              lang: body.lang,
            }
          : { lang: body.lang },
      );
      return { success: true };
    } catch (error) {
      return sanitizeMobileError(error, 'Registrierung fehlgeschlagen');
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
          gender: userData.gender ?? null,
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
        gender: body.gender,
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

  /** Web session probe: validates JWT/cookie without loading profile data. */
  @Post('init-authentication')
  @UseGuards(JwtAuthGuard)
  async initAuthentication(@Request() req: { user: { sub: string } }): Promise<MobileResponse> {
    if (!req.user?.sub) {
      return { success: false, error: 'Invalid token' };
    }
    return { success: true };
  }

  /** Clears the auth cookie on logout (Flutter also clears local token storage). */
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
