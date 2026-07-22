import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class AppConstants {
  // API Configuration — set API_BASE_URL in `.env` (LAN IP + port forwarding, or 127.0.0.1 with `adb reverse`).
  static String get apiBaseUrl {
    final fromEnv = dotenv.env['API_BASE_URL']?.trim();
    var url = (fromEnv != null && fromEnv.isNotEmpty)
        ? fromEnv
        : 'http://127.0.0.1:4000';

    // Windows + WSL2: browsers resolve localhost to ::1; backend listens IPv4 only.
    if (kIsWeb) {
      final uri = Uri.tryParse(url);
      if (uri != null && uri.host == 'localhost') {
        url = uri.replace(host: '127.0.0.1').toString();
      }
    }

    return url.endsWith('/') ? url.substring(0, url.length - 1) : url;
  }
  static const Duration apiTimeout = Duration(seconds: 30);
  static const String apiPath = '/gg-homedx-json/gg-api/v1';

  // Storage Keys
  static const String keyAuthToken = 'auth_token';
  static const String keyUserId = 'user_id';
  static const String keyUserEmail = 'user_email';
  static const String keyUserRole = 'user_role';

  // App Configuration
  static const String appName = 'HomeDX';
  // Keep in sync with the `version:` field in pubspec.yaml (marketing
  // version only, no build number — see CHANGELOG.md for release notes).
  static const String appVersion = '1.1.1';

  /// Verbose Cube / assay flow logs (`HDX_CUBE`, poll loops, step UI): per-
  /// measurement result rows and full API responses. Defaults to **on** in
  /// debug/profile builds (useful during development) and **off** in
  /// release builds unless explicitly overridden via `.env`.
  ///
  /// Regulatory note: this used to default to `true` in all build modes,
  /// meaning a release build with a missing/misconfigured `.env` could log
  /// Cube measurement rows and API responses in production (see
  /// docs/regulatory/gap-assessment.md §6). Explicit `.env` overrides
  /// (`CUBE_VERBOSE=true`/`false`) still take precedence in any build mode
  /// for debugging a specific release build.
  static bool get cubeVerboseLogging {
    try {
      final v = dotenv.env['CUBE_VERBOSE']?.trim().toLowerCase();
      if (v == '0' || v == 'false' || v == 'no' || v == 'off') return false;
      if (v == '1' || v == 'true' || v == 'yes' || v == 'on') return true;
      return !kReleaseMode;
    } catch (_) {
      // dotenv not loaded (e.g. unit tests) — default to verbose, matching
      // debug/profile behavior above.
      return true;
    }
  }

  /// When false, Cube SDK skips cassette incubation timer (not clinically valid).
  ///
  /// Release builds always use the timer (`true`), ignoring `.env`, so a
  /// misconfigured production env cannot skip assay incubation.
  static bool get cubeUseTimer {
    if (kReleaseMode) return true;
    try {
      final v = dotenv.env['CUBE_USE_TIMER']?.trim().toLowerCase();
      if (v == '0' || v == 'false' || v == 'no' || v == 'off') return false;
      if (v == '1' || v == 'true' || v == 'yes' || v == 'on') return true;
      return true;
    } catch (_) {
      return true;
    }
  }
}

