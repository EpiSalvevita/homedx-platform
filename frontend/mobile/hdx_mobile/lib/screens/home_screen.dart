import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../config/app_theme.dart';
import '../providers/auth_provider.dart';
import '../services/user_service.dart';
import '../services/api_service.dart';
import '../widgets/neumorphic.dart';
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

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();
    final firstName = _userData?.firstName ?? authProvider.userEmail?.split('@').first ?? 'Benutzer';
    final email = _userData?.email ?? authProvider.userEmail ?? '';

    return Scaffold(
      appBar: AppBar(
        title: const Text('HomeDX'),
        actions: [
          IconButton(
            icon: const Icon(Icons.menu),
            onPressed: () {
              showModalBottomSheet(
                context: context,
                builder: (_) => SafeArea(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      ListTile(
                        leading: const Icon(Icons.person_outline),
                        title: const Text('Profil'),
                        onTap: () {
                          Navigator.pop(context);
                          Navigator.push(context, MaterialPageRoute(builder: (_) => const ProfileScreen()));
                        },
                      ),
                      ListTile(
                        leading: const Icon(Icons.logout, color: AppTheme.errorColor),
                        title: const Text('Abmelden', style: TextStyle(color: AppTheme.errorColor)),
                        onTap: () { Navigator.pop(context); _handleLogout(); },
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ],
      ),
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: _loadUserData,
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Welcome card
                NeumorphicContainer(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      Container(
                        width: 52,
                        height: 52,
                        decoration: BoxDecoration(
                          color: AppTheme.primaryLight,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.person_outline, color: AppTheme.primaryBlue, size: 28),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Willkommen,', style: TextStyle(fontSize: 14, color: AppTheme.textColorSecondary)),
                            Text(firstName, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppTheme.textColor)),
                            if (email.isNotEmpty)
                              Text(email, style: TextStyle(fontSize: 13, color: AppTheme.textColorSecondary)),
                          ],
                        ),
                      ),
                      GestureDetector(
                        onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const ProfileScreen())),
                        child: const Icon(Icons.arrow_forward_ios, size: 18, color: AppTheme.textColorSecondary),
                      ),
                    ],
                  ),
                ),
                if (_isLoading)
                  const Padding(padding: EdgeInsets.only(top: 8), child: LinearProgressIndicator()),

                const SizedBox(height: 24),
                const Text('Schnellaktionen', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppTheme.textColor)),
                const SizedBox(height: 14),

                // 2x2 grid of quick actions
                GridView.count(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  crossAxisCount: 2,
                  crossAxisSpacing: 14,
                  mainAxisSpacing: 14,
                  childAspectRatio: 1.4,
                  children: [
                    _ActionCard(icon: Icons.medical_services, label: 'Test starten', onTap: () => context.go('/tests')),
                    _ActionCard(icon: Icons.calendar_today, label: 'Arzttermin', onTap: () => context.push('/doctors')),
                    _ActionCard(icon: Icons.assignment, label: 'Ergebnisse', onTap: () => context.push('/results')),
                    _ActionCard(icon: Icons.shopping_bag, label: 'Shop', onTap: () => context.push('/shop')),
                  ],
                ),

                const SizedBox(height: 24),
                const Text('Letzte Aktivität', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppTheme.textColor)),
                const SizedBox(height: 14),

                _ActivityTile(
                  icon: Icons.info_outline,
                  title: 'Erste Schritte',
                  subtitle: 'Vervollständigen Sie Ihr Profil, um zu beginnen',
                  onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const ProfileScreen())),
                ),
                const SizedBox(height: 10),
                _ActivityTile(
                  icon: Icons.notifications_none,
                  title: 'Keine Aktuellen Benachrichtigungen',
                  subtitle: 'Sie sind auf dem neuesten Stand!',
                  onTap: () {},
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _ActionCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _ActionCard({required this.icon, required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: AppTheme.cardColor,
          borderRadius: BorderRadius.circular(16),
          boxShadow: AppTheme.cardShadow,
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Blue blob icon
            SizedBox(
              width: 56,
              height: 44,
              child: Stack(
                children: [
                  Positioned(
                    left: 4,
                    top: 0,
                    child: Container(
                      width: 36,
                      height: 36,
                      decoration: BoxDecoration(
                        color: AppTheme.primaryBlue.withValues(alpha: 0.6),
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                  Positioned(
                    right: 4,
                    bottom: 0,
                    child: Container(
                      width: 30,
                      height: 30,
                      decoration: BoxDecoration(
                        color: AppTheme.primaryBlue.withValues(alpha: 0.35),
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 10),
            Text(label, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: AppTheme.textColor)),
          ],
        ),
      ),
    );
  }
}

class _ActivityTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  const _ActivityTile({required this.icon, required this.title, required this.subtitle, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: AppTheme.cardColor,
          borderRadius: BorderRadius.circular(14),
          boxShadow: AppTheme.cardShadow,
        ),
        child: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: AppTheme.primaryLight,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: AppTheme.primaryBlue, size: 22),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: AppTheme.textColor)),
                  const SizedBox(height: 3),
                  Text(subtitle, style: TextStyle(fontSize: 13, color: AppTheme.textColorSecondary)),
                ],
              ),
            ),
            const Icon(Icons.chevron_right, color: AppTheme.textColorSecondary, size: 20),
          ],
        ),
      ),
    );
  }
}
