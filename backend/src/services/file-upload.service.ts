import { Injectable } from '@nestjs/common';
import * as fs from 'fs';
import * as path from 'path';
import { promisify } from 'util';

const writeFile = promisify(fs.writeFile);
const mkdir = promisify(fs.mkdir);

/**
 * Subset of Express.Multer.File used here. Memory storage provides `buffer`;
 * disk storage (multer `dest`) provides `path` instead, which is read once and
 * removed so no unnamed temp files remain in the upload directory.
 */
type FileUpload = {
  originalname?: string;
  mimetype?: string;
  size?: number;
  buffer?: Buffer;
  path?: string;
};

const MAX_UPLOAD_BYTES = 10 * 1024 * 1024;

@Injectable()
export class FileUploadService {
  private readonly uploadDir = 'uploads';

  constructor() {
    this.ensureUploadDir();
  }

  private async ensureUploadDir() {
    const uploadPath = path.join(process.cwd(), this.uploadDir);
    try {
      await mkdir(uploadPath, { recursive: true });
    } catch {
      // Directory already exists
    }
  }

  private detectMimeFromBuffer(buffer: Buffer): string | null {
    if (buffer.length >= 3 && buffer[0] === 0xff && buffer[1] === 0xd8 && buffer[2] === 0xff) {
      return 'image/jpeg';
    }
    if (
      buffer.length >= 8 &&
      buffer[0] === 0x89 &&
      buffer[1] === 0x50 &&
      buffer[2] === 0x4e &&
      buffer[3] === 0x47
    ) {
      return 'image/png';
    }
    if (
      buffer.length >= 6 &&
      buffer[0] === 0x47 &&
      buffer[1] === 0x49 &&
      buffer[2] === 0x46
    ) {
      return 'image/gif';
    }
    if (
      buffer.length >= 4 &&
      buffer[0] === 0x1a &&
      buffer[1] === 0x45 &&
      buffer[2] === 0xdf &&
      buffer[3] === 0xa3
    ) {
      return 'video/webm';
    }
  return null;
  }

  async uploadFile(file: FileUpload, subdirectory: string): Promise<{ success: boolean; objectName?: string; validation?: string }> {
    try {
      if (!file || typeof file !== 'object') {
        return { success: false, validation: 'No file provided' };
      }
      const filename = file.originalname ?? '';
      let buffer: Buffer;
      if (Buffer.isBuffer(file.buffer)) {
        buffer = file.buffer;
      } else if (typeof file.path === 'string') {
        try {
          const stat = await fs.promises.stat(file.path);
          if (stat.size > MAX_UPLOAD_BYTES) {
            return { success: false, validation: 'File size exceeds 10MB limit' };
          }
          buffer = await fs.promises.readFile(file.path);
        } finally {
          await fs.promises.unlink(file.path).catch(() => undefined);
        }
      } else {
        return { success: false, validation: 'No file provided' };
      }

      if (buffer.length > MAX_UPLOAD_BYTES) {
        return {
          success: false,
          validation: 'File size exceeds 10MB limit',
        };
      }
      const detectedMime = this.detectMimeFromBuffer(buffer);
      const allowedMimeTypes = [
        'image/jpeg',
        'image/png',
        'image/gif',
        'video/mp4',
        'video/avi',
        'video/mov',
        'video/webm',
      ];

      if (!detectedMime || !allowedMimeTypes.includes(detectedMime)) {
        return {
          success: false,
          validation: `File type is not allowed. Allowed types: ${allowedMimeTypes.join(', ')}`,
        };
      }

      const subDirPath = path.join(process.cwd(), this.uploadDir, subdirectory);
      await mkdir(subDirPath, { recursive: true });
      const timestamp = Date.now();
      // Client-supplied extension is only used if it is short and alphanumeric.
      let extension = path.extname(filename);
      if (!/^\.[A-Za-z0-9]{1,5}$/.test(extension)) {
        extension = '';
      }
      if (!extension) {
        if (detectedMime === 'image/jpeg') extension = '.jpeg';
        else if (detectedMime === 'image/png') extension = '.png';
        else if (detectedMime === 'image/gif') extension = '.gif';
        else if (detectedMime === 'video/mp4') extension = '.mp4';
        else if (detectedMime === 'video/avi') extension = '.avi';
        else if (detectedMime === 'video/mov') extension = '.mov';
        else if (detectedMime === 'video/webm') extension = '.webm';
        else extension = '';
      }
      const objectName = `${subdirectory}_${timestamp}${extension}`;
      const filePath = path.join(subDirPath, objectName);
      await writeFile(filePath, buffer);
      return {
        success: true,
        objectName,
      };
    } catch (error) {
      console.error('File upload error:', error);
      return {
        success: false,
        validation: 'File upload failed',
      };
    }
  }
}
