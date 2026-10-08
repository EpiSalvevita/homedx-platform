function isEnglish(lang?: string): boolean {
  return !!lang?.toLowerCase().startsWith('en');
}

const VERIFICATION_SENT_DE =
  'Falls ein Konto mit dieser E-Mail existiert, erhalten Sie in Kürze eine Nachricht mit einem Bestätigungslink.';
const VERIFICATION_SENT_EN =
  'If an account exists for this email, you will receive a message shortly with a confirmation link.';

const VERIFICATION_SUCCESS_DE =
  'Ihre E-Mail-Adresse wurde bestätigt. Sie können sich jetzt anmelden.';
const VERIFICATION_SUCCESS_EN =
  'Your email address was confirmed. You can sign in now.';

const VERIFICATION_INVALID_DE =
  'Der Bestätigungslink ist ungültig oder abgelaufen. Bitte fordern Sie eine neue E-Mail an.';
const VERIFICATION_INVALID_EN =
  'The confirmation link is invalid or has expired. Please request a new email.';

export function emailVerificationSentMessage(lang?: string): string {
  return isEnglish(lang) ? VERIFICATION_SENT_EN : VERIFICATION_SENT_DE;
}

export function emailVerificationSuccessMessage(lang?: string): string {
  return isEnglish(lang) ? VERIFICATION_SUCCESS_EN : VERIFICATION_SUCCESS_DE;
}

export function emailVerificationInvalidMessage(lang?: string): string {
  return isEnglish(lang) ? VERIFICATION_INVALID_EN : VERIFICATION_INVALID_DE;
}

export const EMAIL_VERIFICATION_INVALID_CODES = [
  VERIFICATION_INVALID_DE,
  VERIFICATION_INVALID_EN,
];

export function verificationEmailSubject(lang?: string): string {
  return isEnglish(lang) ? 'Confirm your homeDX account' : 'Bitte bestätigen Sie Ihr homeDX-Konto';
}

export function passwordResetEmailSubject(lang?: string): string {
  return isEnglish(lang) ? 'Reset your homeDX password' : 'homeDX-Passwort zurücksetzen';
}

export function verificationEmailText(params: {
  firstName: string;
  verifyUrl: string;
  lang?: string;
}): string {
  if (isEnglish(params.lang)) {
    return [
      `Hello ${params.firstName},`,
      '',
      'Please confirm your email address to activate your homeDX account:',
      params.verifyUrl,
      '',
      'This link is valid for 24 hours. If you did not create an account, you can ignore this email.',
      '',
      '— homeDX',
    ].join('\n');
  }

  return [
    `Hallo ${params.firstName},`,
    '',
    'bitte bestätigen Sie Ihre E-Mail-Adresse, um Ihr homeDX-Konto zu aktivieren:',
    params.verifyUrl,
    '',
    'Der Link ist 24 Stunden gültig. Falls Sie kein Konto angelegt haben, können Sie diese E-Mail ignorieren.',
    '',
    '— homeDX',
  ].join('\n');
}

export function passwordResetEmailText(params: {
  firstName: string;
  resetUrl: string;
  lang?: string;
}): string {
  if (isEnglish(params.lang)) {
    return [
      `Hello ${params.firstName},`,
      '',
      'Use this link to choose a new password for your homeDX account:',
      params.resetUrl,
      '',
      'This link is valid for 1 hour. If you did not request a reset, you can ignore this email.',
      '',
      '— homeDX',
    ].join('\n');
  }

  return [
    `Hallo ${params.firstName},`,
    '',
    'mit diesem Link können Sie ein neues Passwort für Ihr homeDX-Konto festlegen:',
    params.resetUrl,
    '',
    'Der Link ist 1 Stunde gültig. Falls Sie kein Zurücksetzen angefordert haben, können Sie diese E-Mail ignorieren.',
    '',
    '— homeDX',
  ].join('\n');
}

export function verificationEmailHtml(params: {
  firstName: string;
  verifyUrl: string;
  lang?: string;
}): string {
  const name = escapeHtml(params.firstName);
  const url = escapeHtml(params.verifyUrl);
  if (isEnglish(params.lang)) {
    return emailLayout({
      heading: 'Confirm your email',
      intro: `Hello ${name}, please confirm your email address to activate your homeDX account.`,
      ctaLabel: 'Confirm account',
      url,
      expiry: 'This link is valid for 24 hours. If you did not create an account, you can ignore this email.',
    });
  }

  return emailLayout({
    heading: 'E-Mail bestätigen',
    intro: `Hallo ${name}, bitte bestätigen Sie Ihre E-Mail-Adresse, um Ihr homeDX-Konto zu aktivieren.`,
    ctaLabel: 'Konto bestätigen',
    url,
    expiry: 'Der Link ist 24 Stunden gültig. Falls Sie kein Konto angelegt haben, können Sie diese E-Mail ignorieren.',
  });
}

export function passwordResetEmailHtml(params: {
  firstName: string;
  resetUrl: string;
  lang?: string;
}): string {
  const name = escapeHtml(params.firstName);
  const url = escapeHtml(params.resetUrl);
  if (isEnglish(params.lang)) {
    return emailLayout({
      heading: 'Reset your password',
      intro: `Hello ${name}, use the button below to choose a new password for your homeDX account.`,
      ctaLabel: 'Choose new password',
      url,
      expiry: 'This link is valid for 1 hour. If you did not request a reset, you can ignore this email.',
    });
  }

  return emailLayout({
    heading: 'Passwort zurücksetzen',
    intro: `Hallo ${name}, mit dem Button unten können Sie ein neues Passwort für Ihr homeDX-Konto festlegen.`,
    ctaLabel: 'Neues Passwort festlegen',
    url,
    expiry: 'Der Link ist 1 Stunde gültig. Falls Sie kein Zurücksetzen angefordert haben, können Sie diese E-Mail ignorieren.',
  });
}

function escapeHtml(value: string): string {
  return value
    .replace(/&/g, '&amp;')
    .replace(/</g, '&lt;')
    .replace(/>/g, '&gt;')
    .replace(/"/g, '&quot;');
}

function emailLayout(params: {
  heading: string;
  intro: string;
  ctaLabel: string;
  url: string;
  expiry: string;
}): string {
  return `<!DOCTYPE html>
<html lang="de">
<body style="margin:0;padding:24px;background:#f4f6f8;font-family:Arial,sans-serif;color:#1b2a4a;">
  <table role="presentation" width="100%" cellspacing="0" cellpadding="0" style="max-width:560px;margin:0 auto;background:#ffffff;border-radius:12px;padding:32px;">
    <tr><td style="font-size:20px;font-weight:700;padding-bottom:16px;">homeDX</td></tr>
    <tr><td style="font-size:22px;font-weight:600;padding-bottom:12px;">${params.heading}</td></tr>
    <tr><td style="font-size:16px;line-height:1.5;padding-bottom:24px;">${params.intro}</td></tr>
    <tr><td style="padding-bottom:24px;">
      <a href="${params.url}" style="display:inline-block;background:#1b4f9c;color:#ffffff;text-decoration:none;padding:12px 20px;border-radius:999px;font-weight:600;">${params.ctaLabel}</a>
    </td></tr>
    <tr><td style="font-size:14px;line-height:1.5;color:#5b6b82;">${params.expiry}</td></tr>
  </table>
</body>
</html>`;
}
