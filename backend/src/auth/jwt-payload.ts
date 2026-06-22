/** Shape of the JWT payload attached to req.user after authentication. */
export interface JwtPayload {
  email: string;
  sub: string;
  role: string;
}

export function getUserIdFromPayload(
  user: { sub?: string; id?: string } | null | undefined,
): string | undefined {
  if (!user) return undefined;
  return user.sub ?? user.id;
}
