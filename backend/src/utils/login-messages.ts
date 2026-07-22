const LOGIN_INVALID_CREDENTIALS_DE =
  'E-Mail oder Passwort ist falsch. Bitte prüfen Sie Ihre Eingaben und versuchen Sie es erneut.';
const LOGIN_INVALID_CREDENTIALS_EN =
  'Email or password is incorrect. Please check your entries and try again.';
const LOGIN_FAILED_DE = 'Anmeldung fehlgeschlagen. Bitte versuchen Sie es erneut.';
const LOGIN_FAILED_EN = 'Sign in failed. Please try again.';

const PASSWORD_RESET_SENT_DE =
  'Falls ein Konto mit dieser E-Mail existiert, erhalten Sie in Kürze eine E-Mail mit einem Link zum Zurücksetzen Ihres Passworts.';
const PASSWORD_RESET_SENT_EN =
  'If an account exists for this email, you will receive a message shortly with a link to reset your password.';
const PASSWORD_RESET_SUCCESS_DE = 'Ihr Passwort wurde erfolgreich geändert. Sie können sich jetzt anmelden.';
const PASSWORD_RESET_SUCCESS_EN = 'Your password was changed successfully. You can sign in now.';
const PASSWORD_RESET_INVALID_DE =
  'Der Link zum Zurücksetzen ist ungültig oder abgelaufen. Bitte fordern Sie einen neuen Link an.';
const PASSWORD_RESET_INVALID_EN =
  'The reset link is invalid or has expired. Please request a new link.';

export function loginInvalidCredentialsMessage(lang?: string): string {
  return lang?.toLowerCase().startsWith('en')
    ? LOGIN_INVALID_CREDENTIALS_EN
    : LOGIN_INVALID_CREDENTIALS_DE;
}

export function loginFailedMessage(lang?: string): string {
  return lang?.toLowerCase().startsWith('en') ? LOGIN_FAILED_EN : LOGIN_FAILED_DE;
}

export function passwordResetSentMessage(lang?: string): string {
  return lang?.toLowerCase().startsWith('en') ? PASSWORD_RESET_SENT_EN : PASSWORD_RESET_SENT_DE;
}

export function passwordResetSuccessMessage(lang?: string): string {
  return lang?.toLowerCase().startsWith('en') ? PASSWORD_RESET_SUCCESS_EN : PASSWORD_RESET_SUCCESS_DE;
}

export function passwordResetInvalidMessage(lang?: string): string {
  return lang?.toLowerCase().startsWith('en') ? PASSWORD_RESET_INVALID_EN : PASSWORD_RESET_INVALID_DE;
}

export const LOGIN_ERROR_CODES = [
  LOGIN_INVALID_CREDENTIALS_DE,
  LOGIN_INVALID_CREDENTIALS_EN,
  LOGIN_FAILED_DE,
  LOGIN_FAILED_EN,
  'Invalid credentials',
  'Login failed',
];
