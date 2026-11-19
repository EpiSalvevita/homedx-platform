import { Injectable, Logger } from '@nestjs/common';
import { randomUUID } from 'crypto';
import * as fs from 'fs';
import * as path from 'path';
import { MAX_IMAGE_BYTES, MAX_VIDEO_BYTES } from '../config/media-upload.config';

/**
 * Subset of Express.Multer.File used here. Image endpoints use memory storage
 * (`buffer`); the video endpoint uses disk storage in a private temp dir
 * (`path`). The temp file is owned by the caller (interceptor cleans it up).
 */
export type UploadedMedia = {
  originalname?: string;
  mimetype?: string;
  size?: number;
  buffer?: Buffer;
  path?: string;
};

export type MediaKind = 'image' | 'video';

const ALLOWED_MIME: Record<MediaKind, string[]> = {
  image: ['image/jpeg', 'image/png', 'image/gif'],
  video: ['video/mp4', 'video/quicktime', 'video/webm'],
};

const EXTENSION_BY_MIME: Record<string, string> = {
  'image/jpeg': '.jpeg',
  'image/png': '.png',
  'image/gif': '.gif',
  'video/mp4': '.mp4',
  'video/quicktime': '.mov',
  'video/webm': '.webm',
};

const MP4_BRANDS = ['isom', 'iso2', 'mp41', 'mp42', 'avc1', 'M4V '];
const HEAD_BYTES = 16;

@Injectable()
export class FileUploadService {
  private readonly logger = new Logger(FileUploadService.name);
  private readonly uploadDir = 'uploads';

  constructor() {
    try {
      fs.mkdirSync(path.join(process.cwd(), this.uploadDir), {
        recursive: true,
        mode: 0o700,
      });
    } catch {
      // Created lazily on first upload.
    }
  }

  detectMimeFromBuffer(buffer: Buffer): string | null {
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
    if (buffer.length >= 6 && buffer[0] === 0x47 && buffer[1] === 0x49 && buffer[2] === 0x46) {
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
    // ISO base media file: bytes 4-7 'ftyp', major brand in bytes 8-11.
    if (buffer.length >= 12 && buffer.toString('latin1', 4, 8) === 'ftyp') {
      const brand = buffer.toString('latin1', 8, 12);
      if (brand === 'qt  ') return 'video/quicktime';
      if (MP4_BRANDS.includes(brand)) return 'video/mp4';
    }
    return null;
  }

  private async readHead(file: UploadedMedia): Promise<Buffer | null> {
    if (Buffer.isBuffer(file.buffer)) {
      return file.buffer.subarray(0, HEAD_BYTES);
    }
    if (typeof file.path === 'string') {
      const handle = await fs.promises.open(file.path, 'r');
      try {
        const head = Buffer.alloc(HEAD_BYTES);
        const { bytesRead } = await handle.read(head, 0, HEAD_BYTES, 0);
        return head.subarray(0, bytesRead);
      } finally {
        await handle.close();
      }
    }
    return null;
  }

  private async sizeOf(file: UploadedMedia): Promise<number> {
    if (Buffer.isBuffer(file.buffer)) return file.buffer.length;
    return (await fs.promises.stat(file.path as string)).size;
  }

  /**
   * Validates size and magic bytes for the given kind, then stores the file as
   * uploads/<subdirectory>/<subdirectory>_<uuid><ext>. The extension comes from
   * the detected type only. Never overwrites an existing file.
   */
  async uploadFile(
    file: UploadedMedia,
    subdirectory: string,
    kind: MediaKind = 'image',
  ): Promise<{ success: boolean; objectName?: string; validation?: string }> {
    try {
      if (!file || typeof file !== 'object') {
        return { success: false, validation: 'No file provided' };
      }
      const head = await this.readHead(file);
      if (!head) {
        return { success: false, validation: 'No file provided' };
      }

      const maxBytes = kind === 'video' ? MAX_VIDEO_BYTES : MAX_IMAGE_BYTES;
      if ((await this.sizeOf(file)) > maxBytes) {
        return {
          success: false,
          validation: `File size exceeds ${maxBytes / (1024 * 1024)}MB limit`,
        };
      }

      const allowed = ALLOWED_MIME[kind];
      const detectedMime = this.detectMimeFromBuffer(head);
      if (!detectedMime || !allowed.includes(detectedMime)) {
        return {
          success: false,
          validation: `File type is not allowed. Allowed types: ${allowed.join(', ')}`,
        };
      }

      const subDirPath = path.join(process.cwd(), this.uploadDir, subdirectory);
      await fs.promises.mkdir(subDirPath, { recursive: true, mode: 0o700 });
      const objectName = `${subdirectory}_${randomUUID()}${EXTENSION_BY_MIME[detectedMime]}`;
      const filePath = path.join(subDirPath, objectName);
      if (Buffer.isBuffer(file.buffer)) {
        await fs.promises.writeFile(filePath, file.buffer, { flag: 'wx', mode: 0o600 });
      } else {
        await fs.promises.copyFile(file.path as string, filePath, fs.constants.COPYFILE_EXCL);
        await fs.promises.chmod(filePath, 0o600);
      }
      return { success: true, objectName };
    } catch (error) {
      const e = error as { code?: string; name?: string };
      this.logger.error(`File upload error: ${e?.code ?? e?.name ?? 'unknown'}`);
      return { success: false, validation: 'File upload failed' };
    }
  }

  /** Removes a previously stored object (used when attaching it failed). */
  async deleteStored(subdirectory: string, objectName: string): Promise<void> {
    const base = path.basename(objectName);
    await fs.promises
      .unlink(path.join(process.cwd(), this.uploadDir, subdirectory, base))
      .catch(() => undefined);
  }
}
