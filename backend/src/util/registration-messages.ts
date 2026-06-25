const EMAIL_ALREADY_REGISTERED_DE =
  'Diese E-Mail-Adresse ist bereits registriert. Bitte melden Sie sich an oder verwenden Sie eine andere E-Mail.';

const EMAIL_ALREADY_REGISTERED_EN =
  'This email address is already registered. Please sign in or use a different email.';

export function registrationEmailExistsMessage(lang?: string): string {
  return lang?.toLowerCase().startsWith('en')
    ? EMAIL_ALREADY_REGISTERED_EN
    : EMAIL_ALREADY_REGISTERED_DE;
}

export const REGISTRATION_EMAIL_EXISTS_CODES = [
  'User already exists',
  'Email already exists',
  EMAIL_ALREADY_REGISTERED_DE,
  EMAIL_ALREADY_REGISTERED_EN,
];
