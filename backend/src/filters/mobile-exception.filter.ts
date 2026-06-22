import {
  ArgumentsHost,
  Catch,
  ExceptionFilter,
  HttpException,
  UnauthorizedException,
} from '@nestjs/common';
import { ThrottlerException } from '@nestjs/throttler';
import { Response } from 'express';
import { sanitizeMobileError } from '../util/mobile-error.util';

const MOBILE_API_PREFIX = '/gg-homedx-json/gg-api/v1';

@Catch()
export class MobileExceptionFilter implements ExceptionFilter {
  catch(exception: unknown, host: ArgumentsHost) {
    const ctx = host.switchToHttp();
    const response = ctx.getResponse<Response>();
    const request = ctx.getRequest<{ url?: string; path?: string }>();

    const path = request.url?.split('?')[0] ?? request.path ?? '';
    if (!path.startsWith(MOBILE_API_PREFIX)) {
      if (exception instanceof HttpException) {
        const status = exception.getStatus();
        const body = exception.getResponse();
        response.status(status).json(body);
        return;
      }
      response.status(500).json({ statusCode: 500, message: 'Internal server error' });
      return;
    }

    if (exception instanceof UnauthorizedException || exception instanceof ThrottlerException) {
      const status = exception.getStatus();
      response.status(status).json(exception.getResponse());
      return;
    }

    const body = sanitizeMobileError(exception, 'Request failed');
    response.status(201).json(body);
  }
}
