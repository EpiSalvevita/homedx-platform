import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../config/app_theme.dart';
import '../providers/auth_provider.dart';
import '../services/user_service.dart';
import '../services/api_service.dart';
import '../widgets/figma_ui.dart';
import '../utils/app_assets.dart';
import 'profile_screen.dart';

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
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    setState(() => _isLoading = true);
    try {
      final apiService = Provider.of<ApiService>(context, listen: false);
      final userService = UserService(apiService);
      final userData = await userService.getUserData();
      if (mounted) setState(() { _userData = userData; _isLoading = false; });
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
              leading: const Icon(Icons.person_outline, color: AppTheme.textColor),
              title: Text('Profil', style: FigmaUi.rubik(fontWeight: FontWeight.w500, color: AppTheme.textColor)),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(context, MaterialPageRoute(builder: (_) => const ProfileScreen()));
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

    return FigmaScreen(
      header: FigmaHomeHeader(onMenuTap: _openMenu),
      body: RefreshIndicator(
        onRefresh: _loadUserData,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.fromLTRB(AppTheme.screenHorizontalPadding, 0, AppTheme.screenHorizontalPadding, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              FigmaWelcomeCard(
                name: firstName,
                email: email,
                onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const ProfileScreen())),
              ),
              if (_isLoading)
                const Padding(padding: EdgeInsets.only(top: 12), child: LinearProgressIndicator()),
              const SizedBox(height: 28),
              const FigmaSectionTitle('Schnellaktionen'),
              const SizedBox(height: 16),
              GridView.count(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                crossAxisCount: 2,
                crossAxisSpacing: AppTheme.quickActionGridSpacing,
                mainAxisSpacing: AppTheme.quickActionGridSpacing,
                childAspectRatio: AppTheme.quickActionCardAspectRatio,
                children: [
                  FigmaQuickActionTile(assetPath: AppAssets.iconHomeHeart, label: 'Test starten', onTap: () => context.go('/tests')),
                  FigmaQuickActionTile(assetPath: AppAssets.iconHomeCalendar, label: 'Arzttermin', onTap: () => context.push('/doctors')),
                  FigmaQuickActionTile(assetPath: AppAssets.iconDna, label: 'Ergebnisse', onTap: () => context.push('/results')),
                  FigmaQuickActionTile(assetPath: AppAssets.iconHomeBag, label: 'Shop', onTap: () => context.push('/shop')),
                ],
              ),
              const SizedBox(height: 28),
              const FigmaSectionTitle('Letzte Aktivität'),
              const SizedBox(height: 16),
              FigmaActivityRow(
                icon: Icons.person_outline,
                title: 'Erste Schritte',
                subtitle: 'Vervollständigen Sie Ihr Profil, um zu beginnen',
                onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const ProfileScreen())),
              ),
              const SizedBox(height: AppTheme.activityCardSpacing),
              FigmaActivityRow(
                icon: Icons.notifications_none,
                title: 'Keine Aktuellen Benachrichtigungen',
                subtitle: 'Sie sind auf dem neuesten Stand',
                onTap: () {},
              ),
            ],
          ),
        ),
      ),
    );
  }
}
