import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../config/app_theme.dart';
import '../providers/auth_provider.dart';
import '../providers/notification_provider.dart';
import '../models/app_notification.dart';
import '../services/user_service.dart';
import '../core/api_service.dart';
import '../widgets/figma_ui.dart';
import '../widgets/responsive_layout.dart';
import '../widgets/web/web_page_header.dart';
import '../utils/app_assets.dart';
import '../utils/platform_capabilities.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  UserData? _userData;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadHomeData();
  }

  Future<void> _loadHomeData() async {
    setState(() => _isLoading = true);
    try {
      final apiService = Provider.of<ApiService>(context, listen: false);
      final userService = UserService(apiService);
      final notificationProvider = context.read<NotificationProvider>();
      final results = await Future.wait([
        userService.getUserData(),
        notificationProvider.refresh(),
      ]);
      if (mounted) {
        final userData = results[0] as UserData;
        setState(() {
          _userData = userData;
          _isLoading = false;
        });
        final fullName = '${userData.firstName} ${userData.lastName}'.trim();
        if (fullName.isNotEmpty) {
          context.read<AuthProvider>().setDisplayName(fullName);
        }
      }
    } catch (e) {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _handleLogout() async {
    final authProvider = context.read<AuthProvider>();
    await authProvider.logout();
    if (mounted) context.go('/login');
  }

  void _openMenu() {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppTheme.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.quiz_outlined, color: AppTheme.textColor),
              title: Text('Fragebögen', style: FigmaUi.rubik(fontWeight: FontWeight.w500, color: AppTheme.textColor)),
              onTap: () {
                Navigator.pop(context);
                context.push('/questionnaires');
              },
            ),
            ListTile(
              leading: const Icon(Icons.person_outline, color: AppTheme.textColor),
              title: Text('Profil', style: FigmaUi.rubik(fontWeight: FontWeight.w500, color: AppTheme.textColor)),
              onTap: () {
                Navigator.pop(context);
                context.push('/profile');
              },
            ),
            ListTile(
              leading: const Icon(Icons.payment_outlined, color: AppTheme.textColor),
              title: Text('Zahlungsverlauf', style: FigmaUi.rubik(fontWeight: FontWeight.w500, color: AppTheme.textColor)),
              onTap: () {
                Navigator.pop(context);
                context.push('/payments');
              },
            ),
            ListTile(
              leading: const Icon(Icons.logout, color: AppTheme.errorColor),
              title: Text('Abmelden', style: FigmaUi.rubik(fontWeight: FontWeight.w500, color: AppTheme.errorColor)),
              onTap: () { Navigator.pop(context); _handleLogout(); },
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();
    final firstName = _userData?.firstName ?? authProvider.userEmail?.split('@').first ?? 'Benutzer';
    final email = _userData?.email ?? authProvider.userEmail ?? '';

    final homeContent = RefreshIndicator(
      onRefresh: _loadHomeData,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: EdgeInsets.fromLTRB(
          kIsWeb ? 32 : AppTheme.screenHorizontalPadding,
          0,
          kIsWeb ? 32 : AppTheme.screenHorizontalPadding,
          24,
        ),
        child: _buildHomeContent(context, firstName, email),
      ),
    );

    if (kIsWeb) {
      return Scaffold(
        backgroundColor: AppTheme.background,
        body: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            WebPageHeader(
              title: 'Willkommen zurück',
              subtitle: 'Hallo $firstName — wählen Sie unten eine Schnellaktion.',
            ),
            Expanded(child: homeContent),
          ],
        ),
      );
    }

    return FigmaScreen(
      header: FigmaHomeHeader(onMenuTap: _openMenu),
      body: homeContent,
    );
  }

  Widget _buildHomeContent(BuildContext context, String firstName, String email) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (!kIsWeb) ...[
          const SizedBox(height: AppTheme.quickActionGridSpacing),
          FigmaWelcomeCard(
            name: firstName,
            email: email,
            onTap: () => context.push('/profile'),
          ),
        ],
        if (_isLoading)
          Padding(
            padding: EdgeInsets.only(top: kIsWeb ? 20 : 12),
            child: const LinearProgressIndicator(),
          ),
        SizedBox(height: kIsWeb ? 24 : 28),
        const FigmaSectionTitle('Schnellaktionen'),
        const SizedBox(height: 16),
        _buildQuickActionGrid(context),
        const SizedBox(height: 28),
        _buildRecentActivitySection(context),
      ],
    );
  }

  Widget _buildRecentActivitySection(BuildContext context) {
    final user = _userData;
    final provider = context.watch<NotificationProvider>();
    final showProfileReminder = user != null && !user.isProfileComplete;

    AppNotification? latestUnread;
    for (final notification in provider.notifications) {
      if (notification.isUnread) {
        latestUnread = notification;
        break;
      }
    }

    final rows = <Widget>[];
    if (showProfileReminder) {
      rows.add(_buildProfileActivityRow(context));
    }
    if (latestUnread != null) {
      rows.add(_buildUnreadNotificationActivityRow(latestUnread));
    }

    if (rows.isEmpty) {
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const FigmaSectionTitle('Letzte Aktivität'),
        const SizedBox(height: 16),
        for (var i = 0; i < rows.length; i++) ...[
          if (i > 0) const SizedBox(height: AppTheme.quickActionGridSpacing),
          rows[i],
        ],
      ],
    );
  }

  Widget _buildProfileActivityRow(BuildContext context) {
    final user = _userData;
    if (user == null || user.isProfileComplete) {
      return const SizedBox.shrink();
    }

    return FigmaActivityRow(
      icon: Icons.person_outline,
      title: 'Erste Schritte',
      subtitle: user.profileCompletionHint,
      onTap: () => context.push('/profile'),
    );
  }

  Widget _buildUnreadNotificationActivityRow(AppNotification notification) {
    return FigmaActivityRow(
      icon: Icons.notifications_active_outlined,
      title: notification.title,
      subtitle: notification.message,
      onTap: () => context.goNamed('notifications'),
    );
  }

  Widget _buildQuickActionGrid(BuildContext context) {
    final tiles = <Widget>[
      if (PlatformCapabilities.canRunCubeTests)
        FigmaQuickActionTile(
          assetPath: AppAssets.iconHomeHeart,
          label: 'Test starten',
          onTap: () => context.go('/tests'),
        ),
      FigmaQuickActionTile(
        assetPath: AppAssets.doctorExplaining,
        label: 'Online Sprechstunde',
        iconHeight: 110,
        onTap: () => context.pushNamed('doctors'),
      ),
      FigmaQuickActionTile(assetPath: AppAssets.iconHomeCalendar, label: 'Meine Termine', onTap: () => context.push('/appointments')),
      FigmaQuickActionTile(assetPath: AppAssets.iconDna, label: 'Ergebnisse', onTap: () => context.push('/results')),
      FigmaQuickActionTile(
        icon: Icons.verified_outlined,
        label: 'Zertifikate',
        onTap: () => context.push('/certificates'),
      ),
      FigmaQuickActionTile(assetPath: AppAssets.iconHomeBag, label: 'Shop', onTap: () => context.push('/shop')),
      FigmaQuickActionTile(
        icon: Icons.notifications_outlined,
        label: 'Benachrichtigungen',
        onTap: () => context.goNamed('notifications'),
      ),
    ];

    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth;
        final spacing = AppTheme.quickActionGridSpacing;
        final aspectRatio = AppTheme.quickActionCardAspectRatio;
        final crossAxisCount = AppBreakpoints.quickActionCrossAxisCount(
          width,
          tiles.length,
          spacing: spacing,
          minTileWidth: kIsWeb ? 185 : 130,
          maxColumns: kIsWeb ? 4 : 3,
        );

        final rows = <List<Widget>>[];
        for (var i = 0; i < tiles.length; i += crossAxisCount) {
          final end = i + crossAxisCount > tiles.length ? tiles.length : i + crossAxisCount;
          rows.add(tiles.sublist(i, end));
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            for (var r = 0; r < rows.length; r++) ...[
              if (r > 0) SizedBox(height: spacing),
              _QuickActionRow(
                width: width,
                spacing: spacing,
                aspectRatio: aspectRatio,
                columnsPerRow: crossAxisCount,
                children: rows[r],
              ),
            ],
          ],
        );
      },
    );
  }
}

class _QuickActionRow extends StatelessWidget {
  final List<Widget> children;
  final double spacing;
  final double width;
  final double aspectRatio;
  final int columnsPerRow;

  const _QuickActionRow({
    required this.width,
    required this.spacing,
    required this.aspectRatio,
    required this.columnsPerRow,
    required this.children,
  });

  @override
  Widget build(BuildContext context) {
    final count = children.length;
    final tileWidth = (width - spacing * (columnsPerRow - 1)) / columnsPerRow;
    final tileHeight = tileWidth / aspectRatio;
    final isPartialRow = count < columnsPerRow;

    return Row(
      mainAxisAlignment: isPartialRow ? MainAxisAlignment.center : MainAxisAlignment.start,
      children: [
        for (var i = 0; i < count; i++) ...[
          SizedBox(
            width: tileWidth,
            height: tileHeight,
            child: children[i],
          ),
          if (i < count - 1) SizedBox(width: spacing),
        ],
      ],
    );
  }
}
