import {
  BadRequestException,
  ForbiddenException,
  HttpException,
  NotFoundException,
} from '@nestjs/common';
import { LOGIN_ERROR_CODES } from './login-messages';
import { REGISTRATION_EMAIL_EXISTS_CODES } from './registration-messages';

export interface MobileErrorBody {
  success: false;
  error: string;
  validation?: string[];
}

export function formatValidationMessages(messages: string[]): string[] {
  return messages.map((m) => (typeof m === 'string' ? m : String(m)));
}

export function sanitizeMobileError(
  error: unknown,
  fallback = 'Request failed',
): MobileErrorBody {
  if (error instanceof BadRequestException) {
    const response = error.getResponse();
    if (typeof response === 'object' && response !== null && 'message' in response) {
      const raw = (response as { message: string | string[] }).message;
      const messages = Array.isArray(raw) ? raw : [String(raw)];
      if (
        messages.length === 1 &&
        REGISTRATION_EMAIL_EXISTS_CODES.includes(messages[0])
      ) {
        return { success: false, error: messages[0] };
      }
      return {
        success: false,
        error: 'Invalid request',
        validation: formatValidationMessages(messages),
      };
    }
    return { success: false, error: 'Invalid request' };
  }

  if (error instanceof ForbiddenException || error instanceof NotFoundException) {
    const response = error.getResponse();
    const message =
      typeof response === 'string'
        ? response
        : typeof response === 'object' && response !== null && 'message' in response
          ? String((response as { message: unknown }).message)
          : fallback;
    return { success: false, error: message };
  }

  if (error instanceof HttpException) {
    const response = error.getResponse();
    const message =
      typeof response === 'string'
        ? response
        : typeof response === 'object' && response !== null && 'message' in response
          ? String((response as { message: unknown }).message)
          : fallback;
    return { success: false, error: message };
  }

  if (error instanceof Error && error.message) {
    const safe = [
      'Invalid token',
      'User already exists',
      'Email already exists',
      ...REGISTRATION_EMAIL_EXISTS_CODES,
      ...LOGIN_ERROR_CODES,
      'Login failed',
      'Registration failed',
      'Rapid test not found',
      'Certificate not found',
      'Agreement must be accepted',
    ];
    if (safe.some((s) => error.message.includes(s))) {
      return { success: false, error: error.message };
    }
  }

  return { success: false, error: fallback };
}
