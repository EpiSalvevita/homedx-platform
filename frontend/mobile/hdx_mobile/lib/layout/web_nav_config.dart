import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../l10n/app_localizations.dart';

/// Sidebar navigation entries for the web app shell.
class WebNavItem {
  final String label;
  final IconData icon;
  final String path;
  final String? routeName;

  const WebNavItem({
    required this.label,
    required this.icon,
    required this.path,
    this.routeName,
  });

  bool matchesPath(String currentPath) {
    if (currentPath == path) return true;
    return currentPath.startsWith('$path/');
  }
}

class WebNavConfig {
  /// Wide enough for long German labels (e.g. Benachrichtigungen) at 16px on one line.
  static const double sidebarWidth = 272;
  static const double maxContentWidth = 1100;

  static List<WebNavItem> patientItems(AppLocalizations l10n) => [
    WebNavItem(label: l10n.navHome, icon: Icons.home_outlined, path: '/home', routeName: 'home'),
    WebNavItem(label: l10n.navAppointments, icon: Icons.calendar_today_outlined, path: '/appointments', routeName: 'appointments'),
    WebNavItem(label: l10n.navResults, icon: Icons.assignment_outlined, path: '/results', routeName: 'results'),
    WebNavItem(label: l10n.navQuestionnaires, icon: Icons.quiz_outlined, path: '/questionnaires', routeName: 'questionnaires'),
    WebNavItem(label: l10n.navShop, icon: Icons.shopping_bag_outlined, path: '/shop', routeName: 'shop'),
    WebNavItem(label: l10n.navNotifications, icon: Icons.notifications_outlined, path: '/notifications', routeName: 'notifications'),
    WebNavItem(label: l10n.navPayments, icon: Icons.payment_outlined, path: '/payments', routeName: 'payments'),
    WebNavItem(label: l10n.navProfile, icon: Icons.person_outline, path: '/profile', routeName: 'profile'),
  ];

  static List<WebNavItem> doctorItems(AppLocalizations l10n) => [
    WebNavItem(label: l10n.navDashboard, icon: Icons.dashboard_outlined, path: '/doctor/dashboard', routeName: 'doctor-dashboard'),
    WebNavItem(label: l10n.navAppointments, icon: Icons.calendar_today_outlined, path: '/doctor/appointments', routeName: 'doctor-appointments'),
    WebNavItem(label: l10n.navQuestionnaires, icon: Icons.quiz_outlined, path: '/doctor/questionnaires', routeName: 'doctor-questionnaires'),
    WebNavItem(label: l10n.navAvailability, icon: Icons.schedule_outlined, path: '/doctor/availability', routeName: 'doctor-availability'),
    WebNavItem(label: l10n.navProfile, icon: Icons.person_outline, path: '/profile', routeName: 'profile'),
  ];

  static List<WebNavItem> itemsForRole(String? role, AppLocalizations l10n) {
    return role == 'DOCTOR' ? doctorItems(l10n) : patientItems(l10n);
  }

  static void goAppHome(BuildContext context, {String? role}) {
    if (role == 'DOCTOR') {
      context.goNamed('doctor-dashboard');
    } else {
      context.goNamed('home');
    }
  }

  /// Sidebar label for the current route, or a sensible fallback for nested paths.
  static String titleForPath(String path, AppLocalizations l10n) {
    final items = [...patientItems(l10n), ...doctorItems(l10n)];
    for (final item in items) {
      if (item.matchesPath(path)) return item.label;
    }
    if (path.startsWith('/questionnaires')) return l10n.navQuestionnaires;
    if (path.startsWith('/doctor/questionnaires')) return l10n.navQuestionnaires;
    if (path.startsWith('/appointments/') && path.endsWith('/call')) return l10n.navVideoCall;
    if (path.startsWith('/appointments/')) return l10n.navAppointment;
    if (path.startsWith('/shop/')) return l10n.navShop;
    if (path.startsWith('/payments/')) return l10n.paymentDetailsTitle;
    if (path.startsWith('/results/')) return l10n.navResult;
    if (path.startsWith('/tests')) return l10n.navTests;
    if (path.startsWith('/bluetooth')) return 'Bluetooth';
    return 'HomeDX';
  }
}
