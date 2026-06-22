import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../config/app_theme.dart';
import '../providers/notification_provider.dart';
import '../widgets/figma_ui.dart';

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

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<NotificationProvider>();

    return FigmaScreen(
      header: FigmaBackHeader(
        title: 'Benachrichtigungen',
        blueTopBar: true,
        onBack: () => context.go('/home'),
      ),
      body: provider.isLoading
          ? const Center(child: CircularProgressIndicator())
          : provider.error != null
              ? Center(child: Text(provider.error!))
              : RefreshIndicator(
                  onRefresh: provider.refresh,
                  child: provider.notifications.isEmpty
                      ? ListView(
                          children: const [
                            SizedBox(height: 120),
                            Center(child: Text('Keine Benachrichtigungen')),
                          ],
                        )
                      : ListView.builder(
                          itemCount: provider.notifications.length,
                          itemBuilder: (context, index) {
                            final n = provider.notifications[index];
                            return ListTile(
                              title: Text(n.title),
                              subtitle: Text(n.message),
                              trailing: n.isUnread
                                  ? const Icon(Icons.circle, size: 12, color: AppTheme.primaryColor)
                                  : null,
                              onTap: () => provider.markRead(n.id),
                            );
                          },
                        ),
                ),
    );
  }
}
