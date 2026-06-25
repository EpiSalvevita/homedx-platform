import {
  Injectable,
  CanActivate,
  ExecutionContext,
  UnauthorizedException,
} from '@nestjs/common';
import { Reflector } from '@nestjs/core';
import { JwtService } from '@nestjs/jwt';
import { getJwtSecret } from '../config/env.config';
import { AUTH_COOKIE_NAME } from '../config/auth-cookie.config';
import { IS_PUBLIC_KEY } from './public.decorator';
import { PrismaService } from '../services/prisma.service';

@Injectable()
export class JwtAuthGuard implements CanActivate {
  constructor(
    private jwtService: JwtService,
    private reflector: Reflector,
    private prisma: PrismaService,
  ) {}

  async canActivate(context: ExecutionContext): Promise<boolean> {
    const isPublic = this.reflector.getAllAndOverride<boolean>(IS_PUBLIC_KEY, [
      context.getHandler(),
      context.getClass(),
    ]);
    if (isPublic) {
      return true;
    }

    const request = context.switchToHttp().getRequest();
    const token = this.extractToken(request);

    if (!token) {
      throw new UnauthorizedException('No token provided');
    }

    try {
      const payload = await this.jwtService.verifyAsync(token, {
        secret: getJwtSecret(),
        algorithms: ['HS256'],
      });

      const user = await this.prisma.user.findUnique({
        where: { id: payload.sub as string },
        select: { id: true, status: true, role: true, email: true, tokenVersion: true },
      });

      if (!user || user.status !== 'ACTIVE') {
        throw new UnauthorizedException('User account is not active');
      }

      const tokenVersion = typeof payload.tv === 'number' ? payload.tv : 0;
      if (tokenVersion !== user.tokenVersion) {
        throw new UnauthorizedException('Invalid token');
      }

      request.user = { ...payload, role: user.role, email: user.email };
      return true;
    } catch (error) {
      if (error instanceof UnauthorizedException) {
        throw error;
      }
      throw new UnauthorizedException('Invalid token');
    }
  }

  private extractToken(request: Record<string, unknown>): string | undefined {
    const headers = request.headers as Record<string, string | undefined>;
    const authHeader = headers?.authorization;
    if (authHeader) {
      const [type, token] = authHeader.split(' ');
      if (type === 'Bearer' && token) {
        return token;
      }
    }

    const xAuthToken = headers?.['x-auth-token'];
    if (xAuthToken) {
      return xAuthToken;
    }

    const cookies = request.cookies as Record<string, string> | undefined;
    const cookieToken = cookies?.[AUTH_COOKIE_NAME];
    if (cookieToken) {
      return cookieToken;
    }

    return undefined;
  }
}
