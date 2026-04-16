import 'package:flutter_dotenv/flutter_dotenv.dart';

class AppConstants {
  // API Configuration — set API_BASE_URL in `.env` (LAN IP + port forwarding, or 127.0.0.1 with `adb reverse`).
  static String get apiBaseUrl {
    final u = dotenv.env['API_BASE_URL']?.trim();
    if (u != null && u.isNotEmpty) return u;
    // Prefer API_BASE_URL in `.env`; this fallback is for USB + `adb reverse tcp:4000`.
    return 'http://127.0.0.1:4000';
  }
  static const Duration apiTimeout = Duration(seconds: 30);
  static const String apiPath = '/gg-homedx-json/gg-api/v1';

  // Storage Keys
  static const String keyAuthToken = 'auth_token';
  static const String keyUserId = 'user_id';
  static const String keyUserEmail = 'user_email';

  // App Configuration
  static const String appName = 'HomeDX';
  static const String appVersion = '1.0.0';
}

