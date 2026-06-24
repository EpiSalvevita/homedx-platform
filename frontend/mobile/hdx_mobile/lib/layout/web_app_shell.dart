import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../config/app_theme.dart';
import '../providers/auth_provider.dart';
import '../utils/app_assets.dart';
import '../widgets/figma_ui.dart';
import 'web_nav_config.dart';

/// Desktop web shell: persistent sidebar and wide content column.
class WebAppShell extends StatelessWidget {
  final Widget child;

  const WebAppShell({
    super.key,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final navItems = WebNavConfig.itemsForRole(auth.userRole);
    final currentPath = GoRouterState.of(context).uri.path;

    return Scaffold(
      backgroundColor: AppTheme.surface,
      body: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _WebSidebar(
            navItems: navItems,
            currentPath: currentPath,
            onLogout: () async {
              await auth.logout();
              if (!context.mounted) return;
              context.go('/login');
            },
          ),
          Expanded(
            child: Align(
              alignment: Alignment.topCenter,
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: WebNavConfig.maxContentWidth),
                child: child,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _WebSidebar extends StatelessWidget {
  final List<WebNavItem> navItems;
  final String currentPath;
  final VoidCallback onLogout;

  const _WebSidebar({
    required this.navItems,
    required this.currentPath,
    required this.onLogout,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppTheme.navy,
      child: SizedBox(
        width: WebNavConfig.sidebarWidth,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 24, 20, 28),
              child: Image.asset(
                AppAssets.logo,
                height: 28,
                fit: BoxFit.contain,
                color: Colors.white,
                colorBlendMode: BlendMode.srcIn,
              ),
            ),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                children: navItems.map((item) {
                  final selected = item.matchesPath(currentPath);
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 4),
                    child: _SidebarNavItem(
                      label: item.label,
                      icon: item.icon,
                      selected: selected,
                      onTap: () {
                        if (item.routeName != null) {
                          context.goNamed(item.routeName!);
                        } else {
                          context.go(item.path);
                        }
                      },
                    ),
                  );
                }).toList(),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: OutlinedButton.icon(
                onPressed: onLogout,
                icon: const Icon(Icons.logout, size: 18, color: Colors.white70),
                label: Text(
                  'Abmelden',
                  style: FigmaUi.rubik(fontSize: 14, fontWeight: FontWeight.w400, color: Colors.white70),
                ),
                style: OutlinedButton.styleFrom(
                  foregroundColor: Colors.white70,
                  side: const BorderSide(color: Colors.white24),
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SidebarNavItem extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool selected;
  final VoidCallback onTap;

  const _SidebarNavItem({
    required this.label,
    required this.icon,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: selected ? AppTheme.primaryBlue.withValues(alpha: 0.35) : Colors.transparent,
      borderRadius: BorderRadius.circular(12),
      child: MouseRegion(
        cursor: SystemMouseCursors.click,
        child: GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            child: Row(
              children: [
                Icon(
                  icon,
                  size: 22,
                  color: selected ? Colors.white : AppTheme.accentBlue,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    label,
                    style: FigmaUi.rubik(
                      fontSize: 15,
                      fontWeight: selected ? FontWeight.w500 : FontWeight.w400,
                      color: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
