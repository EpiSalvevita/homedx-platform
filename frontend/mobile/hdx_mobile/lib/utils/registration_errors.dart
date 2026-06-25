/// Maps API registration errors to German UI messages.
String localizeRegistrationError(String error) {
  final trimmed = error.trim();
  const englishToGerman = {
    'User already exists':
        'Diese E-Mail-Adresse ist bereits registriert. Bitte melden Sie sich an oder verwenden Sie eine andere E-Mail.',
    'Email already exists':
        'Diese E-Mail-Adresse ist bereits registriert. Bitte melden Sie sich an oder verwenden Sie eine andere E-Mail.',
    'Registration failed': 'Registrierung fehlgeschlagen',
    'Invalid request': 'Ungültige Anfrage. Bitte prüfen Sie Ihre Eingaben.',
  };

  return englishToGerman[trimmed] ?? trimmed;
}

bool isEmailAlreadyRegisteredError(String? error) {
  if (error == null || error.isEmpty) return false;
  final normalized = error.toLowerCase();
  return normalized.contains('bereits registriert') ||
      normalized.contains('already registered') ||
      normalized.contains('already exists');
}
