import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../config/app_theme.dart';
import '../models/app_notification.dart';
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
    switch (notification.type.toUpperCase()) {
      case 'APPOINTMENT':
        return Icons.calendar_today_outlined;
      case 'TEST_RESULT':
        return Icons.assignment_outlined;
      case 'PAYMENT':
        return Icons.payment_outlined;
      default:
        return Icons.notifications_outlined;
    }
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<NotificationProvider>();

    return AdaptiveScreen(
      title: 'Benachrichtigungen',
      blueTopBar: true,
      showBackOnMobile: false,
      onBack: () => context.go('/home'),
      body: provider.isLoading
          ? const Center(child: CircularProgressIndicator())
          : provider.error != null
              ? Center(child: Text(provider.error!))
              : RefreshIndicator(
                  onRefresh: provider.refresh,
                  child: ListView(
                    padding: const EdgeInsets.all(AppTheme.screenHorizontalPadding),
                    physics: const AlwaysScrollableScrollPhysics(),
                    children: [
                      if (provider.notifications.isEmpty)
                        const FigmaInsetInfoCard(
                          icon: Icons.info_outline,
                          title: 'Keine Benachrichtigungen',
                          subtitle: 'Sie sind auf dem neuesten Stand.',
                        )
                      else
                        ...provider.notifications.map((notification) => Padding(
                              padding: const EdgeInsets.only(bottom: AppTheme.infoInsetCardSpacing),
                              child: FigmaInsetInfoCard(
                                icon: _iconForNotification(notification),
                                iconColor: notification.isUnread ? AppTheme.primaryBlue : AppTheme.textColorSecondary,
                                title: notification.title,
                                subtitle: notification.message,
                                trailing: notification.isUnread
                                    ? const Icon(Icons.circle, size: 12, color: AppTheme.primaryBlue)
                                    : null,
                                onTap: () => provider.markRead(notification.id),
                              ),
                            )),
                    ],
                  ),
                ),
    );
  }
}
