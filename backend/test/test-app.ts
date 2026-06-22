import { INestApplication } from '@nestjs/common';
import { configureApp } from '../src/config/app.bootstrap';

export function bootstrapTestApp(app: INestApplication): void {
  configureApp(app);
}
