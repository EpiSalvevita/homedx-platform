import { Injectable, UnauthorizedException, BadRequestException, Logger } from '@nestjs/common';
import { JwtService } from '@nestjs/jwt';
import { PrismaService } from './prisma.service';
import * as bcrypt from 'bcrypt';
import { createHash, randomBytes } from 'crypto';
import { getJwtSecret, isProductionEnv } from '../config/env.config';
import {
  loginInvalidCredentialsMessage,
  passwordResetInvalidMessage,
  passwordResetSentMessage,
  passwordResetSuccessMessage,
} from '../utils/login-messages';
import { registrationEmailExistsMessage } from '../utils/registration-messages';
import { isStrongPassword } from '../auth/password-policy';
import { AuditLogService } from './audit-log.service';
import { EmailService } from './email.service';
import {
  emailVerificationInvalidMessage,
  emailVerificationSentMessage,
  emailVerificationSuccessMessage,
} from '../utils/email-messages';

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
    private emailService: EmailService,
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

  private hashSecretToken(rawToken: string): string {
    return createHash('sha256').update(rawToken).digest('hex');
  }

  private createSecretToken(): { rawToken: string; tokenHash: string } {
    const rawToken = randomBytes(32).toString('hex');
    return { rawToken, tokenHash: this.hashSecretToken(rawToken) };
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

    const { rawToken, tokenHash } = this.createSecretToken();
    const expiresAt = new Date(Date.now() + 60 * 60 * 1000);

    await this.prisma.user.update({
      where: { id: user.id },
      data: {
        passwordResetTokenHash: tokenHash,
        passwordResetExpiresAt: expiresAt,
      },
    });

    const sent = await this.emailService.sendPasswordResetEmail({
      to: user.email,
      firstName: user.firstName,
      token: rawToken,
      lang,
    });
    if (!sent && isProductionEnv()) {
      this.logger.error(`Password reset email was not delivered for userId=${user.id}`);
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

    const tokenHash = this.hashSecretToken(token);
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
    const { rawToken, tokenHash } = this.createSecretToken();
    const verificationExpiresAt = new Date(Date.now() + 24 * 60 * 60 * 1000);

    const user = await this.prisma.user.create({
      data: {
        email,
        password: hashedPassword,
        firstName,
        lastName,
        role: asDoctor ? 'DOCTOR' : 'USER',
        address: asDoctor ? options?.clinicAddress : undefined,
        emailVerified: false,
        emailVerificationTokenHash: tokenHash,
        emailVerificationExpiresAt: verificationExpiresAt,
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

    const sent = await this.emailService.sendVerificationEmail({
      to: user.email,
      firstName: user.firstName,
      token: rawToken,
      lang: options?.lang,
    });
    if (!sent && isProductionEnv()) {
      this.logger.error(`Verification email was not delivered for userId=${user.id}`);
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

  async verifyEmail(token: string, lang?: string): Promise<{ message: string }> {
    const tokenHash = this.hashSecretToken(token);
    const user = await this.prisma.user.findFirst({
      where: {
        emailVerificationTokenHash: tokenHash,
        emailVerificationExpiresAt: { gt: new Date() },
      },
    });

    if (!user) {
      throw new BadRequestException(emailVerificationInvalidMessage(lang));
    }

    await this.prisma.user.update({
      where: { id: user.id },
      data: {
        emailVerified: true,
        emailVerificationTokenHash: null,
        emailVerificationExpiresAt: null,
      },
    });

    return { message: emailVerificationSuccessMessage(lang) };
  }

  async resendVerificationEmail(email: string, lang?: string): Promise<{ message: string }> {
    const message = emailVerificationSentMessage(lang);
    const user = await this.prisma.user.findUnique({ where: { email } });

    if (!user || user.emailVerified) {
      return { message };
    }

    const { rawToken, tokenHash } = this.createSecretToken();
    const expiresAt = new Date(Date.now() + 24 * 60 * 60 * 1000);

    await this.prisma.user.update({
      where: { id: user.id },
      data: {
        emailVerificationTokenHash: tokenHash,
        emailVerificationExpiresAt: expiresAt,
      },
    });

    const sent = await this.emailService.sendVerificationEmail({
      to: user.email,
      firstName: user.firstName,
      token: rawToken,
      lang,
    });
    if (!sent && isProductionEnv()) {
      this.logger.error(`Verification email resend was not delivered for userId=${user.id}`);
    }

    return { message };
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
