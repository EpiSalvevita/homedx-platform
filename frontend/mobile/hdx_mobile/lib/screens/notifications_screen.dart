import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../config/app_theme.dart';
import '../models/app_notification.dart';
import '../providers/auth_provider.dart';
import '../providers/notification_provider.dart';
import '../widgets/figma_ui.dart';
import '../widgets/web/adaptive_screen.dart';

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<NotificationProvider>().refresh();
    });
  }

  IconData _iconForNotification(AppNotification notification) {
    if (notification.isUnread) return Icons.notifications_active_outlined;
    final type = notification.type.toUpperCase();
    if (type.contains('APPOINTMENT')) return Icons.calendar_today_outlined;
    if (type.contains('TEST') || type.contains('RESULT')) {
      return Icons.assignment_outlined;
    }
    if (type.contains('PAYMENT')) return Icons.payment_outlined;
    return Icons.notifications_outlined;
  }

  String _formatDate(DateTime dt) {
    return '${dt.day.toString().padLeft(2, '0')}.'
        '${dt.month.toString().padLeft(2, '0')}.'
        '${dt.year}  '
        '${dt.hour.toString().padLeft(2, '0')}:'
        '${dt.minute.toString().padLeft(2, '0')}';
  }

  Future<void> _onNotificationTap(AppNotification notification) async {
    final provider = context.read<NotificationProvider>();
    if (notification.isUnread) {
      await provider.markRead(notification.id);
    }
    if (!mounted) return;

    final appointmentId = notification.appointmentId;
    final type = notification.type.toUpperCase();
    final isAppointmentRelated =
        type.contains('APPOINTMENT') && appointmentId != null;

    if (isAppointmentRelated) {
      final isDoctor = context.read<AuthProvider>().isDoctor;
      final path = isDoctor
          ? '/doctor/appointments/$appointmentId'
          : '/appointments/$appointmentId';
      context.push(path);
    }
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<NotificationProvider>();
    final hasUnread = provider.notifications.any((n) => n.isUnread);

    return AdaptiveScreen(
      title: 'Benachrichtigungen',
      showWebHeader: false,
      showBackOnMobile: false,
      onBack: () => context.go('/home'),
      actions: [
        if (hasUnread && !kIsWeb)
          TextButton(
            style: TextButton.styleFrom(
              minimumSize: const Size(0, AppTheme.largeTouchTarget),
              foregroundColor: AppTheme.primaryBlue,
            ),
            onPressed: () => provider.markAllRead(),
            child: Text(
              'Alle gelesen',
              style: FigmaUi.rubik(fontSize: 15, fontWeight: FontWeight.w600, color: AppTheme.primaryBlue),
            ),
          ),
      ],
      body: provider.isLoading
          ? const Center(child: CircularProgressIndicator())
          : provider.error != null
              ? FigmaEmptyState(
                  icon: Icons.error_outline,
                  title: 'Benachrichtigungen konnten nicht geladen werden',
                  message: 'Bitte prüfen Sie Ihre Verbindung und versuchen Sie es erneut.',
                  actionLabel: 'Erneut versuchen',
                  onAction: provider.refresh,
                )
              : RefreshIndicator(
                  onRefresh: provider.refresh,
                  child: ListView(
                    padding: EdgeInsets.fromLTRB(
                      kIsWeb ? 32 : AppTheme.screenHorizontalPadding,
                      kIsWeb ? 24 : AppTheme.screenHorizontalPadding,
                      kIsWeb ? 32 : AppTheme.screenHorizontalPadding,
                      24,
                    ),
                    physics: const AlwaysScrollableScrollPhysics(),
                    children: [
                      Align(
                        alignment: Alignment.topCenter,
                        child: ConstrainedBox(
                          constraints: const BoxConstraints(maxWidth: 800),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Expanded(
                                    child: Text(
                                      'Tippen Sie auf eine Meldung, um sie als gelesen zu markieren.',
                                      style: FigmaUi.bodyLight(
                                        fontSize: 17,
                                        color: AppTheme.textColorSecondary,
                                      ),
                                    ),
                                  ),
                                  if (hasUnread && kIsWeb) ...[
                                    const SizedBox(width: 12),
                                    TextButton(
                                      style: TextButton.styleFrom(
                                        minimumSize: const Size(0, AppTheme.largeTouchTarget),
                                        foregroundColor: AppTheme.primaryBlue,
                                      ),
                                      onPressed: () => provider.markAllRead(),
                                      child: Text(
                                        'Alle gelesen',
                                        style: FigmaUi.rubik(
                                          fontSize: 15,
                                          fontWeight: FontWeight.w600,
                                          color: AppTheme.primaryBlue,
                                        ),
                                      ),
                                    ),
                                  ],
                                ],
                              ),
                              const SizedBox(height: 24),
                              if (provider.notifications.isEmpty)
                                const FigmaEmptyState(
                                  icon: Icons.notifications_none_outlined,
                                  title: 'Keine Benachrichtigungen',
                                  message: 'Sie sind auf dem neuesten Stand.',
                                )
                              else
                                ...provider.notifications.map(
                                  (notification) => Padding(
                                    padding: const EdgeInsets.only(bottom: AppTheme.testResultCardSpacing),
                                    child: _NotificationCard(
                                      notification: notification,
                                      icon: _iconForNotification(notification),
                                      dateLabel: _formatDate(notification.createdAt),
                                      onTap: () => _onNotificationTap(notification),
                                    ),
                                  ),
                                ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
    );
  }
}

class _NotificationCard extends StatelessWidget {
  final AppNotification notification;
  final IconData icon;
  final String dateLabel;
  final VoidCallback onTap;

  const _NotificationCard({
    required this.notification,
    required this.icon,
    required this.dateLabel,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final unread = notification.isUnread;

    return NeumorphicRaisedCard(
      onTap: onTap,
      height: null,
      padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 18),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: AppTheme.background,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              icon,
              size: 26,
              color: unread ? AppTheme.primaryBlue : AppTheme.textColorSecondary,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  notification.title,
                  style: FigmaUi.rubik(
                    fontSize: 18,
                    fontWeight: unread ? FontWeight.w600 : FontWeight.w500,
                    color: AppTheme.textColor,
                  ),
                ),
                if (notification.message.isNotEmpty) ...[
                  const SizedBox(height: 6),
                  Text(
                    notification.message,
                    style: FigmaUi.rubik(
                      fontSize: 15,
                      fontWeight: FontWeight.w400,
                      color: AppTheme.textColorSecondary,
                      height: 1.35,
                    ),
                  ),
                ],
                const SizedBox(height: 10),
                Text(
                  dateLabel,
                  style: FigmaUi.rubik(
                    fontSize: 15,
                    fontWeight: FontWeight.w400,
                    color: AppTheme.textColorSecondary,
                  ),
                ),
              ],
            ),
          ),
          if (unread) ...[
            const SizedBox(width: 12),
            const Padding(
              padding: EdgeInsets.only(top: 6),
              child: Icon(Icons.circle, size: 12, color: AppTheme.primaryBlue),
            ),
          ],
        ],
      ),
    );
  }
}
