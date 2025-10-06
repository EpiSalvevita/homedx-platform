import { NestFactory } from '@nestjs/core';
import { ValidationPipe } from '@nestjs/common';
import { AppModule } from './app.module';

const graphqlUploadExpress = require('graphql-upload/graphqlUploadExpress.mjs').default;

async function bootstrap() {
  const app = await NestFactory.create(AppModule);
  
  // Enable CORS
  app.enableCors({
    origin: ['http://localhost:3000', 'http://localhost:3001', 'http://localhost:8080', 'http://localhost:8000'],
    credentials: true,
  });
  
  app.use(graphqlUploadExpress({ maxFileSize: 10000000, maxFiles: 5 }));

  app.useGlobalPipes(
    new ValidationPipe({
      transform: true,
      whitelist: true,
      forbidNonWhitelisted: false,
    }),
  );

  await app.listen(4000);
}

bootstrap(); 