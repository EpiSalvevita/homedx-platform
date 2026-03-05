import { NestFactory } from '@nestjs/core';
import { ValidationPipe } from '@nestjs/common';
import { AppModule } from './app.module';

async function bootstrap() {
  const app = await NestFactory.create(AppModule);
  
  // Enable CORS
  app.enableCors({
    origin: true, // Allow all origins in development (for Flutter app)
    credentials: true,
    methods: ['GET', 'POST', 'PUT', 'DELETE', 'OPTIONS'],
    allowedHeaders: ['Content-Type', 'Authorization', 'x-auth-token', 'Accept'],
  });
  
  // TODO: Fix graphql-upload ES module issue
  // const { default: graphqlUploadExpress } = await import('graphql-upload/graphqlUploadExpress.mjs');
  // app.use(graphqlUploadExpress({ maxFileSize: 10000000, maxFiles: 5 }));

  app.useGlobalPipes(
    new ValidationPipe({
      transform: true,
      whitelist: true,
      forbidNonWhitelisted: false,
    }),
  );

  await app.listen(4000, '0.0.0.0');
}

bootstrap(); 