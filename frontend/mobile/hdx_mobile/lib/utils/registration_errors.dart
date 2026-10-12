import 'package:flutter/widgets.dart';

import '../l10n/app_localizations.dart';

/// Maps API registration errors to localized UI messages.
/// Without [l10n] the German texts are used (legacy callers outside widgets).
String localizeRegistrationError(String error, {AppLocalizations? l10n}) {
  final loc = l10n ?? lookupAppLocalizations(const Locale('de'));
  final trimmed = error.trim();
  final englishToLocalized = {
    'User already exists': loc.authErrorEmailAlreadyRegistered,
    'Email already exists': loc.authErrorEmailAlreadyRegistered,
    'Registration failed': loc.authErrorRegistrationFailed,
    'Invalid request': loc.authErrorInvalidRequest,
  };

  return englishToLocalized[trimmed] ?? trimmed;
}

bool isEmailAlreadyRegisteredError(String? error) {
  if (error == null || error.isEmpty) return false;
  final normalized = error.toLowerCase();
  return normalized.contains('bereits registriert') ||
      normalized.contains('already registered') ||
      normalized.contains('already exists');
}
