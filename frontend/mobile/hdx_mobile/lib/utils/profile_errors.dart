import 'package:flutter/widgets.dart';

import '../l10n/app_localizations.dart';

/// Maps backend profile/update validation messages to localized UI text.
/// Without [l10n] the German texts are used (legacy callers outside widgets).
String localizeProfileError(String message, {AppLocalizations? l10n}) {
  final loc = l10n ?? lookupAppLocalizations(const Locale('de'));
  final lower = message.toLowerCase();

  if (lower.contains('property email should not exist')) {
    return loc.authErrorEmailNotEditable;
  }
  if (lower.contains('gender must be one of')) {
    return loc.authErrorGenderInvalid;
  }
  if (lower.contains('invalid request')) {
    return loc.authErrorInvalidRequestRetry;
  }

  return message;
}
