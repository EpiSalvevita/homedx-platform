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
