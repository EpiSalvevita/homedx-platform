import { Module } from '@nestjs/common';
import { RapidTestService } from '../../services/rapid-test.service';
import { MobileTestService } from '../../services/mobile-test.service';
import { CubeService } from '../../services/cube.service';
import { MobileTestController } from '../../controllers/mobile-test.controller';
import { CertificatesModule } from '../certificates/certificates.module';
import { NotificationsModule } from '../notifications/notifications.module';

@Module({
  imports: [CertificatesModule, NotificationsModule],
  controllers: [MobileTestController],
  providers: [RapidTestService, MobileTestService, CubeService],
  exports: [RapidTestService, MobileTestService, CubeService],
})
export class TestsModule {}
