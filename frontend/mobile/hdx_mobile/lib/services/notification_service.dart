import '../models/app_notification.dart';
import 'api_service.dart';

class NotificationService {
  final ApiService _api;

  NotificationService(this._api);

  Future<List<AppNotification>> listNotifications() async {
    final response = await _api.post('list-notifications', body: {});
    if (response['success'] != true) {
      throw Exception(response['error']?.toString() ?? 'Failed to load notifications');
    }
    final raw = response['notifications'];
    if (raw is! List) return [];
    return raw
        .whereType<Map>()
        .map((m) => AppNotification.fromJson(Map<String, dynamic>.from(m)))
        .toList();
  }

  Future<int> getUnreadCount() async {
    final response = await _api.post('get-unread-notification-count', body: {});
    if (response['success'] != true) {
      return 0;
    }
    return (response['count'] as num?)?.toInt() ?? 0;
  }

  Future<void> markRead(String notificationId) async {
    final response = await _api.post(
      'mark-notification-read',
      body: {'notificationId': notificationId},
    );
    if (response['success'] != true) {
      throw Exception(response['error']?.toString() ?? 'Failed to mark read');
    }
  }

  Future<void> markAllRead() async {
    final response = await _api.post('mark-all-notifications-read', body: {});
    if (response['success'] != true) {
      throw Exception(response['error']?.toString() ?? 'Failed to mark all read');
    }
  }

  Future<void> registerPushToken(String pushToken) async {
    final response = await _api.post(
      'register-push-token',
      body: {'pushToken': pushToken},
    );
    if (response['success'] != true) {
      throw Exception(response['error']?.toString() ?? 'Failed to register push token');
    }
  }
}
