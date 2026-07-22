import { Module } from '@nestjs/common';
import { MobileCertificateService } from '../../services/mobile-certificate.service';
import { MobileCertificateController } from '../../controllers/mobile-certificate.controller';

@Module({
  controllers: [MobileCertificateController],
  providers: [MobileCertificateService],
  exports: [MobileCertificateService],
})
export class CertificatesModule {}
