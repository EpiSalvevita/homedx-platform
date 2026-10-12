import 'package:flutter/widgets.dart';

import '../l10n/app_localizations.dart';

/// Maps API login errors to localized UI messages.
/// Without [l10n] the German texts are used (legacy callers outside widgets).
String localizeLoginError(String error, {AppLocalizations? l10n}) {
  final loc = l10n ?? lookupAppLocalizations(const Locale('de'));
  final trimmed = error.trim();
  final englishToLocalized = {
    'Invalid credentials': loc.authErrorInvalidCredentials,
    'Login failed': loc.authErrorLoginFailed,
    'Authentication required or token expired': loc.authErrorSessionExpired,
  };

  return englishToLocalized[trimmed] ?? trimmed;
}
