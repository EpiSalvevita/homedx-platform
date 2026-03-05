import 'package:flutter_dotenv/flutter_dotenv.dart';

class AppConstants {
  // API Configuration
  static String get apiBaseUrl => dotenv.env['API_BASE_URL'] ?? 'http://localhost:4000';
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

