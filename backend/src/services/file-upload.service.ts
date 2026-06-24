import { Injectable } from '@nestjs/common';
import * as fs from 'fs';
import * as path from 'path';
import { promisify } from 'util';

const writeFile = promisify(fs.writeFile);
const mkdir = promisify(fs.mkdir);

type FileUpload = {
  filename: string;
  mimetype: string;
  encoding: string;
  createReadStream(): AsyncIterable<Buffer>;
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
      const fileAny = await file as unknown as { file?: FileUpload };
      const fileData = fileAny.file ?? file;
      const { createReadStream, filename } = fileData;
      const stream = createReadStream();
      const chunks: Buffer[] = [];
      let totalSize = 0;

      for await (const chunk of stream) {
        totalSize += chunk.length;
        if (totalSize > MAX_UPLOAD_BYTES) {
          return {
            success: false,
            validation: 'File size exceeds 10MB limit',
          };
        }
        chunks.push(chunk);
      }

      const buffer = Buffer.concat(chunks);
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
      let extension = path.extname(filename);
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
