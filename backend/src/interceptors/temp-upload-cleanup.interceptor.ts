import { CallHandler, ExecutionContext, Injectable, NestInterceptor } from '@nestjs/common';
import * as fs from 'fs';
import { Observable, finalize } from 'rxjs';

/**
 * Deletes the multer disk-storage temp file (req.file.path) once the request
 * finished, whether it succeeded, failed validation or threw. Runs inside
 * FileInterceptor so it also covers DTO validation failures.
 */
@Injectable()
export class TempUploadCleanupInterceptor implements NestInterceptor {
  intercept(context: ExecutionContext, next: CallHandler): Observable<unknown> {
    const req = context.switchToHttp().getRequest<{ file?: { path?: string } }>();
    return next.handle().pipe(
      finalize(() => {
        const tmp = req.file?.path;
        if (tmp) {
          fs.promises.unlink(tmp).catch(() => undefined);
        }
      }),
    );
  }
}
