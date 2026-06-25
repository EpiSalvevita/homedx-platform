/**
 * Centralized environment validation.
 * Fail fast at startup if required secrets are missing.
 */
export function validateEnvironment(): void {
  if (!process.env.JWT_SECRET?.trim()) {
    throw new Error(
      'JWT_SECRET environment variable is required. Set it in backend/.env or your deployment environment.',
    );
  }

  const isProd = process.env.NODE_ENV === 'production';
  if (isProd && !process.env.CORS_ORIGINS?.trim()) {
    throw new Error(
      'CORS_ORIGINS is required in production. Set an explicit allowlist of origins.',
    );
  }
}

export function getJwtSecret(): string {
  const secret = process.env.JWT_SECRET?.trim();
  if (!secret) {
    throw new Error('JWT_SECRET environment variable is required');
  }
  return secret;
}

export function getCorsOrigins(): string[] | boolean {
  const raw = process.env.CORS_ORIGINS?.trim();
  if (!raw) {
    // Development default: reflect request origin (same as origin: true)
    return true;
  }
  return raw.split(',').map((o) => o.trim()).filter(Boolean);
}

/** Base URL of the web app (used for password-reset links in logs / email). */
export function getFrontendUrl(): string {
  const raw = process.env.FRONTEND_URL?.trim() || process.env.WEB_APP_URL?.trim();
  if (raw) {
    return raw.replace(/\/$/, '');
  }
  return 'http://localhost:8080';
}

export function isProductionEnv(): boolean {
  return process.env.NODE_ENV === 'production';
}
