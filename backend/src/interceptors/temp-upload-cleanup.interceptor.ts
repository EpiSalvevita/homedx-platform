import { CallHandler, ExecutionContext, Injectable, NestInterceptor } from '@nestjs/common';
import * as fs from 'fs';
import { Observable, catchError, concatMap } from 'rxjs';

/**
 * Deletes the multer disk-storage temp file (req.file.path) before the response
 * is sent, whether it succeeded, failed validation or threw. Runs inside
 * FileInterceptor so it also covers DTO validation failures.
 */
@Injectable()
export class TempUploadCleanupInterceptor implements NestInterceptor {
  intercept(context: ExecutionContext, next: CallHandler): Observable<unknown> {
    const req = context.switchToHttp().getRequest<{ file?: { path?: string } }>();
    const cleanup = async () => {
      const tmp = req.file?.path;
      if (tmp) {
        await fs.promises.unlink(tmp).catch(() => undefined);
      }
    };
    // Cleanup completes before the response (or error) is emitted.
    return next.handle().pipe(
      concatMap(async (value) => {
        await cleanup();
        return value;
      }),
      catchError(async (err) => {
        await cleanup();
        throw err;
      }),
    );
  }
}
