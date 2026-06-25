/// Maps API login errors to German UI messages.
String localizeLoginError(String error) {
  final trimmed = error.trim();
  const englishToGerman = {
    'Invalid credentials':
        'E-Mail oder Passwort ist falsch. Bitte prüfen Sie Ihre Eingaben und versuchen Sie es erneut.',
    'Login failed': 'Anmeldung fehlgeschlagen. Bitte versuchen Sie es erneut.',
    'Authentication required or token expired': 'Bitte melden Sie sich erneut an.',
  };

  return englishToGerman[trimmed] ?? trimmed;
}
