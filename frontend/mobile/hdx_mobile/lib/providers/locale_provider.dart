import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LocaleProvider extends ChangeNotifier {
  static const _prefKey = 'app_locale';

  Locale _locale = const Locale('de', 'DE');

  Locale get locale => _locale;
  bool get isGerman => _locale.languageCode == 'de';

  Future<void> initialize() async {
    final prefs = await SharedPreferences.getInstance();
    final code = prefs.getString(_prefKey);
    if (code == 'en') {
      _locale = const Locale('en', 'US');
    } else {
      _locale = const Locale('de', 'DE');
    }
    notifyListeners();
  }

  Future<void> setGerman() async {
    if (_locale.languageCode == 'de') return;
    _locale = const Locale('de', 'DE');
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_prefKey, 'de');
    notifyListeners();
  }

  Future<void> setEnglish() async {
    if (_locale.languageCode == 'en') return;
    _locale = const Locale('en', 'US');
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_prefKey, 'en');
    notifyListeners();
  }

  Future<void> toggle() async {
    if (isGerman) {
      await setEnglish();
    } else {
      await setGerman();
    }
  }
}
