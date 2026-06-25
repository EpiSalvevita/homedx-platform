/** Shared registration password rules (enforced on register-account). */
export const PASSWORD_MIN_LENGTH = 8;

const HAS_LOWERCASE = /[a-z]/;
const HAS_UPPERCASE = /[A-Z]/;
const HAS_DIGIT = /\d/;
const HAS_SPECIAL = /[^A-Za-z0-9]/;

export function isStrongPassword(password: string): boolean {
  if (password.length < PASSWORD_MIN_LENGTH) return false;
  if (!HAS_LOWERCASE.test(password)) return false;
  if (!HAS_UPPERCASE.test(password)) return false;
  if (!HAS_DIGIT.test(password)) return false;
  if (!HAS_SPECIAL.test(password)) return false;
  return true;
}
