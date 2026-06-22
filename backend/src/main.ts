import { NestFactory } from '@nestjs/core';
import { AppModule } from './app.module';
import { validateEnvironment } from './config/env.config';
import { configureApp } from './config/app.bootstrap';

async function bootstrap() {
  validateEnvironment();

  const app = await NestFactory.create(AppModule, { rawBody: true });
  configureApp(app);

  const port = parseInt(process.env.PORT || '4000', 10);
  await app.listen(port, '0.0.0.0');
}

bootstrap();
