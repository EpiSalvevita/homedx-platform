import { Global, Module } from '@nestjs/common';
import { AuditLogService } from '../../services/audit-log.service';
import { FileUploadService } from '../../services/file-upload.service';
import { MobileUserHelper } from '../../controllers/mobile-user.helper';

@Global()
@Module({
  providers: [AuditLogService, FileUploadService, MobileUserHelper],
  exports: [AuditLogService, FileUploadService, MobileUserHelper],
})
export class CommonModule {}
