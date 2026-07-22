import { Module } from '@nestjs/common';
import { LegalPageService } from '../../services/legal-page.service';
import { MobileLegalController } from '../../controllers/mobile-legal.controller';

@Module({
  controllers: [MobileLegalController],
  providers: [LegalPageService],
  exports: [LegalPageService],
})
export class LegalModule {}
