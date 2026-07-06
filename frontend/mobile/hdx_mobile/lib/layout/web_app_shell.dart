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
    final fallbackLabel = auth.userEmail?.split('@').first ?? 'Benutzer';
    final userLabel = auth.displayName == null
        ? fallbackLabel
        : (auth.isDoctor ? 'Dr. ${auth.displayName}' : auth.displayName!);

    return Scaffold(
      backgroundColor: AppTheme.surface,
      body: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _WebSidebar(
            navItems: navItems,
            currentPath: currentPath,
            userLabel: userLabel,
            userEmail: auth.userEmail,
            onLogout: () async {
              await auth.logout();
              if (!context.mounted) return;
              context.go('/login');
            },
          ),
          Expanded(
            child: DecoratedBox(
              decoration: BoxDecoration(
                color: AppTheme.background,
                border: Border(
                  left: BorderSide(color: AppTheme.navy.withValues(alpha: 0.06)),
                ),
              ),
              child: Align(
                alignment: Alignment.topCenter,
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: WebNavConfig.maxContentWidth),
                  child: child,
                ),
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
  final String userLabel;
  final String? userEmail;
  final VoidCallback onLogout;

  const _WebSidebar({
    required this.navItems,
    required this.currentPath,
    required this.userLabel,
    required this.userEmail,
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
              child: MouseRegion(
                cursor: SystemMouseCursors.click,
                child: GestureDetector(
                  onTap: () => WebNavConfig.goAppHome(context, role: context.read<AuthProvider>().userRole),
                  child: Image.asset(
                    AppAssets.logo,
                    height: 28,
                    fit: BoxFit.contain,
                    color: Colors.white,
                    colorBlendMode: BlendMode.srcIn,
                  ),
                ),
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
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
              child: _SidebarUserChip(
                label: userLabel,
                email: userEmail,
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
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

class _SidebarUserChip extends StatelessWidget {
  final String label;
  final String? email;

  const _SidebarUserChip({
    required this.label,
    required this.email,
  });

  String get _initials {
    final parts = label.trim().split(RegExp(r'\s+'));
    if (parts.length >= 2) {
      return '${parts.first[0]}${parts[1][0]}'.toUpperCase();
    }
    if (label.length >= 2) return label.substring(0, 2).toUpperCase();
    return label.isNotEmpty ? label[0].toUpperCase() : '?';
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: MouseRegion(
        cursor: SystemMouseCursors.click,
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: () => context.goNamed('profile'),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.06),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.white12),
            ),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 18,
                  backgroundColor: AppTheme.accentBlue.withValues(alpha: 0.35),
                  child: Text(
                    _initials,
                    style: FigmaUi.rubik(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        label,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: FigmaUi.rubik(
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                          color: Colors.white,
                        ),
                      ),
                      if (email != null)
                        Text(
                          email!,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: FigmaUi.rubik(
                            fontSize: 11,
                            fontWeight: FontWeight.w400,
                            color: Colors.white54,
                          ),
                        ),
                    ],
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

class _SidebarNavItem extends StatefulWidget {
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
  State<_SidebarNavItem> createState() => _SidebarNavItemState();
}

class _SidebarNavItemState extends State<_SidebarNavItem> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    final bg = widget.selected
        ? AppTheme.primaryBlue.withValues(alpha: 0.35)
        : _hovered
            ? Colors.white.withValues(alpha: 0.08)
            : Colors.transparent;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 150),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(12),
      ),
      child: MouseRegion(
        cursor: SystemMouseCursors.click,
        onEnter: (_) => setState(() => _hovered = true),
        onExit: (_) => setState(() => _hovered = false),
        child: GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: widget.onTap,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            child: Row(
              children: [
                Icon(
                  widget.icon,
                  size: 22,
                  color: widget.selected ? Colors.white : AppTheme.accentBlue,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    widget.label,
                    style: FigmaUi.rubik(
                      fontSize: 15,
                      fontWeight: widget.selected ? FontWeight.w500 : FontWeight.w400,
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
