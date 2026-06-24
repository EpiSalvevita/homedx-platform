import { INestApplication, ValidationPipe } from '@nestjs/common';
import helmet from 'helmet';
import { MobileExceptionFilter } from '../filters/mobile-exception.filter';
import { getCorsOrigins } from './env.config';

export function configureApp(app: INestApplication): void {
  app.use(helmet());
  app.useGlobalFilters(new MobileExceptionFilter());

  app.enableCors({
    origin: getCorsOrigins(),
    credentials: true,
    methods: ['GET', 'POST', 'PUT', 'DELETE', 'OPTIONS'],
    allowedHeaders: ['Content-Type', 'Authorization', 'x-auth-token', 'Accept'],
  });

  app.useGlobalPipes(
    new ValidationPipe({
      transform: true,
      whitelist: true,
      forbidNonWhitelisted: true,
    }),
  );
}
