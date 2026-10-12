import 'package:flutter/widgets.dart';

import 'app_localizations.dart';

/// Shorthand for the app's localizations in widgets.
///
/// Falls back to German (the template language) when no localization delegate
/// is installed above [this], e.g. in widget tests that pump a bare MaterialApp.
extension L10nX on BuildContext {
  AppLocalizations get l10n =>
      Localizations.of<AppLocalizations>(this, AppLocalizations) ??
      lookupAppLocalizations(const Locale('de'));
}
