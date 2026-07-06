import { Injectable, UnauthorizedException, BadRequestException, Logger } from '@nestjs/common';
import { JwtService } from '@nestjs/jwt';
import { PrismaService } from './prisma.service';
import * as bcrypt from 'bcrypt';
import { createHash, randomBytes } from 'crypto';
import { getFrontendUrl, getJwtSecret, isProductionEnv } from '../config/env.config';
import {
  loginInvalidCredentialsMessage,
  passwordResetInvalidMessage,
  passwordResetSentMessage,
  passwordResetSuccessMessage,
} from '../util/login-messages';
import { registrationEmailExistsMessage } from '../util/registration-messages';
import { isStrongPassword } from '../auth/password-policy';
import { AuditLogService } from './audit-log.service';

@Injectable()
export class AuthService {
  private readonly logger = new Logger(AuthService.name);

  /// Dummy bcrypt hash so non-existent accounts still incur a compare (constant-time login).
  private static readonly DUMMY_PASSWORD_HASH =
    '$2b$12$yks6owW0p0GmHXshuNXrzepXqI87jlLrTd9ZOJ/pu4PNjgXpgq8qa';

  constructor(
    private prisma: PrismaService,
    private jwtService: JwtService,
    private auditLogService: AuditLogService,
  ) {}

  private signAccessToken(user: {
    id: string;
    email: string;
    role: string;
    tokenVersion: number;
  }): string {
    return this.jwtService.sign({
      email: user.email,
      sub: user.id,
      role: user.role,
      tv: user.tokenVersion,
    });
  }

  private hashResetToken(rawToken: string): string {
    return createHash('sha256').update(rawToken).digest('hex');
  }

  async validateUser(email: string, password: string): Promise<any> {
    const user = await this.prisma.user.findUnique({ where: { email } });
    if (user && await bcrypt.compare(password, user.password)) {
      const { password, ...result } = user;
      return result;
    }
    return null;
  }

  async login(email: string, password: string, lang?: string) {
    const user = await this.prisma.user.findUnique({ where: { email } });

    // Always run a bcrypt compare (even when the user is missing) so response
    // timing does not reveal whether an account exists (user enumeration).
    const hashToCompare = user?.password ?? AuthService.DUMMY_PASSWORD_HASH;
    const passwordMatches = await bcrypt.compare(password, hashToCompare);

    if (!user || !passwordMatches) {
      throw new UnauthorizedException(loginInvalidCredentialsMessage(lang));
    }

    try {
      await this.auditLogService.create({
        userId: user.id,
        action: 'LOGIN',
        entityType: 'USER',
        entityId: user.id,
      });
    } catch (error) {
      // Audit logging must never block a successful login.
      this.logger.warn(`Audit log write failed for login userId=${user.id}: ${error?.message ?? error}`);
    }

    const { password: _, ...result } = user;
    return {
      access_token: this.signAccessToken({
        id: user.id,
        email: user.email,
        role: user.role,
        tokenVersion: user.tokenVersion,
      }),
      user: result,
    };
  }

  async requestPasswordReset(email: string, lang?: string): Promise<{ message: string }> {
    const user = await this.prisma.user.findUnique({ where: { email } });
    const message = passwordResetSentMessage(lang);

    if (!user) {
      return { message };
    }

    const rawToken = randomBytes(32).toString('hex');
    const tokenHash = this.hashResetToken(rawToken);
    const expiresAt = new Date(Date.now() + 60 * 60 * 1000);

    await this.prisma.user.update({
      where: { id: user.id },
      data: {
        passwordResetTokenHash: tokenHash,
        passwordResetExpiresAt: expiresAt,
      },
    });

    if (!isProductionEnv()) {
      const resetUrl = `${getFrontendUrl()}/reset-password?token=${encodeURIComponent(rawToken)}`;
      this.logger.log(`[dev] Password reset link for ${email}: ${resetUrl}`);
    }

    return { message };
  }

  async resetPassword(token: string, newPassword: string, lang?: string): Promise<{ message: string }> {
    if (!isStrongPassword(newPassword)) {
      throw new BadRequestException(
        lang?.toLowerCase().startsWith('en')
          ? 'Password does not meet security requirements'
          : 'Das Passwort erfüllt nicht die Sicherheitsanforderungen',
      );
    }

    const tokenHash = this.hashResetToken(token);
    const user = await this.prisma.user.findFirst({
      where: {
        passwordResetTokenHash: tokenHash,
        passwordResetExpiresAt: { gt: new Date() },
      },
    });

    if (!user) {
      throw new BadRequestException(passwordResetInvalidMessage(lang));
    }

    const hashedPassword = await bcrypt.hash(newPassword, 12);
    await this.prisma.user.update({
      where: { id: user.id },
      data: {
        password: hashedPassword,
        passwordResetTokenHash: null,
        passwordResetExpiresAt: null,
        tokenVersion: user.tokenVersion + 1,
      },
    });

    return { message: passwordResetSuccessMessage(lang) };
  }

  async signup(
    email: string,
    password: string,
    firstName: string,
    lastName: string,
    options?: {
      asDoctor?: boolean;
      specialization?: string;
      clinicAddress?: string;
      lang?: string;
    },
  ) {
    const existingUser = await this.prisma.user.findUnique({ where: { email } });
    if (existingUser) {
      throw new BadRequestException(registrationEmailExistsMessage(options?.lang));
    }

    const hashedPassword = await bcrypt.hash(password, 12);
    const asDoctor = options?.asDoctor === true;

    const user = await this.prisma.user.create({
      data: {
        email,
        password: hashedPassword,
        firstName,
        lastName,
        role: asDoctor ? 'DOCTOR' : 'USER',
        address: asDoctor ? options?.clinicAddress : undefined,
      },
    });

    if (asDoctor && options?.specialization) {
      await this.prisma.doctorProfile.create({
        data: {
          userId: user.id,
          specialization: options.specialization,
          languages: ['Deutsch'],
        },
      });
    }

    const { password: _, ...result } = user;

    return {
      access_token: this.signAccessToken({
        id: user.id,
        email: user.email,
        role: user.role,
        tokenVersion: user.tokenVersion,
      }),
      user: result,
    };
  }

  async checkEmail(email: string) {
    const existingUser = await this.prisma.user.findUnique({ where: { email } });
    const emailRegex = /^[^\s@]+@[^\s@]+\.[^\s@]+$/;

    return {
      exists: !!existingUser,
      valid: emailRegex.test(email),
    };
  }

  async validateToken(token: string): Promise<any> {
    try {
      const payload = this.jwtService.verify(token, {
        secret: getJwtSecret(),
      });
      return payload;
    } catch {
      return null;
    }
  }
}
