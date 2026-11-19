import { randomUUID } from 'crypto';
import * as fs from 'fs';
import * as os from 'os';
import * as path from 'path';
import { diskStorage } from 'multer';

export const MAX_IMAGE_BYTES = 10 * 1024 * 1024;
export const MAX_VIDEO_BYTES = 100 * 1024 * 1024;

const BASE_LIMITS = { files: 1, fields: 5, parts: 6, fieldSize: 1024 };

/** Multer options for photo endpoints: memory storage, 10 MB. */
export const IMAGE_UPLOAD_OPTIONS = {
  limits: { ...BASE_LIMITS, fileSize: MAX_IMAGE_BYTES },
};

let videoTempDir: string | undefined;

/**
 * Private (0700) temp directory under os.tmpdir(), never under uploads/.
 * Holds in-flight video uploads only; files are validated, copied into
 * uploads/videos and always deleted afterwards.
 */
export function getVideoTempDir(): string {
  if (!videoTempDir || !fs.existsSync(videoTempDir)) {
    videoTempDir = fs.mkdtempSync(path.join(os.tmpdir(), 'homedx-video-'));
  }
  return videoTempDir;
}

/** Multer options for the video endpoint: disk storage in the temp dir, 100 MB. */
export const VIDEO_UPLOAD_OPTIONS = {
  storage: diskStorage({
    destination: (_req, _file, cb) => cb(null, getVideoTempDir()),
    // Random name: the client filename is never used on disk.
    filename: (_req, _file, cb) => cb(null, randomUUID()),
  }),
  limits: { ...BASE_LIMITS, fileSize: MAX_VIDEO_BYTES },
};
