import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import '../services/notification_service.dart';

/// Registers FCM token when Firebase is configured (see docs/ENV_SETUP.md).
Future<void> initPush(NotificationService notificationService) async {
  final enabled = dotenv.env['FIREBASE_ENABLED']?.toLowerCase() == 'true';
  if (!enabled) return;

  try {
    await Firebase.initializeApp();
    final messaging = FirebaseMessaging.instance;
    final token = await messaging.getToken();
    if (token != null && token.isNotEmpty) {
      await notificationService.registerPushToken(token);
    }
    messaging.onTokenRefresh.listen((newToken) {
      notificationService.registerPushToken(newToken);
    });
  } catch (_) {
    // Firebase not configured on this build — in-app notifications still work.
  }
}
