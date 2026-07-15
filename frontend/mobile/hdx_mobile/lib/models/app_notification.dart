import 'dart:convert';

class AppNotification {
  final String id;
  final String type;
  final String status;
  final String priority;
  final String title;
  final String message;
  final String? data;
  final DateTime? readAt;
  final DateTime createdAt;

  AppNotification({
    required this.id,
    required this.type,
    required this.status,
    required this.priority,
    required this.title,
    required this.message,
    this.data,
    this.readAt,
    required this.createdAt,
  });

  bool get isUnread => status == 'UNREAD';

  /// Parsed JSON from [data], or null if missing/invalid.
  Map<String, dynamic>? get dataMap {
    final raw = data;
    if (raw == null || raw.isEmpty) return null;
    try {
      final decoded = jsonDecode(raw);
      return decoded is Map<String, dynamic> ? decoded : null;
    } catch (_) {
      return null;
    }
  }

  String? get appointmentId {
    final id = dataMap?['appointmentId'];
    return id is String && id.isNotEmpty ? id : null;
  }

  factory AppNotification.fromJson(Map<String, dynamic> json) {
    return AppNotification(
      id: json['id'] as String,
      type: json['type'] as String,
      status: json['status'] as String,
      priority: json['priority'] as String,
      title: json['title'] as String,
      message: json['message'] as String,
      data: json['data'] as String?,
      readAt: json['readAt'] != null
          ? DateTime.parse(json['readAt'] as String)
          : null,
      createdAt: DateTime.parse(json['createdAt'] as String),
    );
  }
}
