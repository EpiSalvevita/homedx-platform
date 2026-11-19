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

const STALE_MS = 15 * 60 * 1000;

/**
 * One fixed private (0700) temp directory, never under uploads/. Holds
 * in-flight video uploads only. Override with HOMEDX_VIDEO_TMP_DIR (tests).
 */
export function getVideoTempDir(): string {
  const dir =
    process.env.HOMEDX_VIDEO_TMP_DIR || path.join(os.tmpdir(), 'homedx-video');
  fs.mkdirSync(dir, { recursive: true, mode: 0o700 });
  return dir;
}

/**
 * Startup sweep: removes temp files older than 15 minutes (left by a crash or
 * abort) and stale legacy `homedx-video-*` directories owned by this user.
 * Never throws.
 */
export function purgeStaleVideoTemp(now = Date.now()): void {
  try {
    const dir = getVideoTempDir();
    for (const name of fs.readdirSync(dir)) {
      const full = path.join(dir, name);
      try {
        if (now - fs.statSync(full).mtimeMs > STALE_MS) fs.rmSync(full, { force: true });
      } catch {
        // ignore
      }
    }
  } catch {
    // ignore
  }
  try {
    const root = os.tmpdir();
    const uid = typeof process.getuid === 'function' ? process.getuid() : undefined;
    for (const name of fs.readdirSync(root)) {
      if (!/^homedx-video-/.test(name)) continue;
      const full = path.join(root, name);
      try {
        const st = fs.statSync(full);
        if (st.isDirectory() && (uid === undefined || st.uid === uid) && now - st.mtimeMs > STALE_MS) {
          fs.rmSync(full, { recursive: true, force: true });
        }
      } catch {
        // ignore
      }
    }
  } catch {
    // ignore
  }
}

/** Multer options for the video endpoint: disk storage in the temp dir, 100 MB. */
export const VIDEO_UPLOAD_OPTIONS = {
  storage: diskStorage({
    destination: (_req, _file, cb) => cb(null, getVideoTempDir()),
    // Random name: the client filename is never used on disk.
    filename: (req, _file, cb) => {
      const name = randomUUID();
      // multer does not remove a partially written file when the client aborts
      // mid-upload, so tie its lifetime to the response: 'close' fires after a
      // normal response and on abort.
      const full = path.join(getVideoTempDir(), name);
      (req as { res?: { once(e: string, f: () => void): void } }).res?.once('close', () => {
        fs.promises.unlink(full).catch(() => undefined);
      });
      cb(null, name);
    },
  }),
  limits: { ...BASE_LIMITS, fileSize: MAX_VIDEO_BYTES },
};
