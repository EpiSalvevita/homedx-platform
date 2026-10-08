import { Injectable, Logger, OnModuleInit } from '@nestjs/common';
import * as nodemailer from 'nodemailer';
import type { Transporter } from 'nodemailer';
import {
  getFrontendUrl,
  getSmtpConfig,
  isFrontendUrlConfigured,
  isProductionEnv,
} from '../config/env.config';
import {
  passwordResetEmailHtml,
  passwordResetEmailSubject,
  passwordResetEmailText,
  verificationEmailHtml,
  verificationEmailSubject,
  verificationEmailText,
} from '../utils/email-messages';

@Injectable()
export class EmailService implements OnModuleInit {
  private readonly logger = new Logger(EmailService.name);
  private readonly transporter: Transporter | null;

  constructor() {
    const smtp = getSmtpConfig();
    this.transporter = smtp
      ? nodemailer.createTransport({
          host: smtp.host,
          port: smtp.port,
          secure: smtp.secure,
          auth: {
            user: smtp.user,
            pass: smtp.pass,
          },
        })
      : null;
  }

  onModuleInit(): void {
    if (!this.transporter) {
      const hint =
        'SMTP is not configured (set SMTP_HOST, SMTP_USER, SMTP_PASS). Transactional emails will not be sent.';
      if (isProductionEnv()) {
        this.logger.error(hint);
      } else {
        this.logger.warn(`${hint} Dev links will be logged instead.`);
      }
    }

    if (isProductionEnv() && !isFrontendUrlConfigured()) {
      this.logger.error(
        'FRONTEND_URL or WEB_APP_URL is not set; email links will point at localhost and will not work for customers.',
      );
    }
  }

  isConfigured(): boolean {
    return this.transporter != null;
  }

  async sendVerificationEmail(params: {
    to: string;
    firstName: string;
    token: string;
    lang?: string;
  }): Promise<boolean> {
    const verifyUrl = `${getFrontendUrl()}/verify-email?token=${encodeURIComponent(params.token)}`;
    return this.dispatch({
      to: params.to,
      subject: verificationEmailSubject(params.lang),
      text: verificationEmailText({
        firstName: params.firstName,
        verifyUrl,
        lang: params.lang,
      }),
      html: verificationEmailHtml({
        firstName: params.firstName,
        verifyUrl,
        lang: params.lang,
      }),
      devLogLabel: 'Email verification link',
      devLogUrl: verifyUrl,
    });
  }

  async sendPasswordResetEmail(params: {
    to: string;
    firstName: string;
    token: string;
    lang?: string;
  }): Promise<boolean> {
    const resetUrl = `${getFrontendUrl()}/reset-password?token=${encodeURIComponent(params.token)}`;
    return this.dispatch({
      to: params.to,
      subject: passwordResetEmailSubject(params.lang),
      text: passwordResetEmailText({
        firstName: params.firstName,
        resetUrl,
        lang: params.lang,
      }),
      html: passwordResetEmailHtml({
        firstName: params.firstName,
        resetUrl,
        lang: params.lang,
      }),
      devLogLabel: 'Password reset link',
      devLogUrl: resetUrl,
    });
  }

  private async dispatch(params: {
    to: string;
    subject: string;
    text: string;
    html: string;
    devLogLabel: string;
    devLogUrl: string;
  }): Promise<boolean> {
    if (!isProductionEnv()) {
      this.logger.log(`[dev] ${params.devLogLabel} for ${params.to}: ${params.devLogUrl}`);
    }

    if (!this.transporter) {
      return false;
    }

    const smtp = getSmtpConfig();
    try {
      await this.transporter.sendMail({
        from: smtp?.from,
        to: params.to,
        subject: params.subject,
        text: params.text,
        html: params.html,
      });
      this.logger.log(`Sent transactional email (${params.devLogLabel})`);
      return true;
    } catch (error) {
      const message = error instanceof Error ? error.message : String(error);
      this.logger.error(`Failed to send "${params.subject}": ${message}`);
      return false;
    }
  }
}
