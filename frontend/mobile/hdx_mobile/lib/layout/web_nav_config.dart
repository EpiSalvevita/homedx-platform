import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

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

  static const List<WebNavItem> patientItems = [
    WebNavItem(label: 'Home', icon: Icons.home_outlined, path: '/home', routeName: 'home'),
    WebNavItem(label: 'Termine', icon: Icons.calendar_today_outlined, path: '/appointments', routeName: 'appointments'),
    WebNavItem(label: 'Ergebnisse', icon: Icons.assignment_outlined, path: '/results', routeName: 'results'),
    WebNavItem(label: 'Fragebögen', icon: Icons.quiz_outlined, path: '/questionnaires', routeName: 'questionnaires'),
    WebNavItem(label: 'Shop', icon: Icons.shopping_bag_outlined, path: '/shop', routeName: 'shop'),
    WebNavItem(label: 'Benachrichtigungen', icon: Icons.notifications_outlined, path: '/notifications', routeName: 'notifications'),
    WebNavItem(label: 'Zahlungsverlauf', icon: Icons.payment_outlined, path: '/payments', routeName: 'payments'),
    WebNavItem(label: 'Profil', icon: Icons.person_outline, path: '/profile', routeName: 'profile'),
  ];

  static const List<WebNavItem> doctorItems = [
    WebNavItem(label: 'Dashboard', icon: Icons.dashboard_outlined, path: '/doctor/dashboard', routeName: 'doctor-dashboard'),
    WebNavItem(label: 'Termine', icon: Icons.calendar_today_outlined, path: '/doctor/appointments', routeName: 'doctor-appointments'),
    WebNavItem(label: 'Fragebögen', icon: Icons.quiz_outlined, path: '/doctor/questionnaires', routeName: 'doctor-questionnaires'),
    WebNavItem(label: 'Verfügbarkeit', icon: Icons.schedule_outlined, path: '/doctor/availability', routeName: 'doctor-availability'),
    WebNavItem(label: 'Profil', icon: Icons.person_outline, path: '/profile', routeName: 'profile'),
  ];

  static List<WebNavItem> itemsForRole(String? role) {
    return role == 'DOCTOR' ? doctorItems : patientItems;
  }

  static void goAppHome(BuildContext context, {String? role}) {
    if (role == 'DOCTOR') {
      context.goNamed('doctor-dashboard');
    } else {
      context.goNamed('home');
    }
  }

  /// Sidebar label for the current route, or a sensible fallback for nested paths.
  static String titleForPath(String path) {
    final items = [...patientItems, ...doctorItems];
    for (final item in items) {
      if (item.matchesPath(path)) return item.label;
    }
    if (path.startsWith('/questionnaires')) return 'Fragebögen';
    if (path.startsWith('/doctor/questionnaires')) return 'Fragebögen';
    if (path.startsWith('/appointments/') && path.endsWith('/call')) return 'Videoanruf';
    if (path.startsWith('/appointments/')) return 'Termin';
    if (path.startsWith('/shop/')) return 'Shop';
    if (path.startsWith('/results/')) return 'Ergebnis';
    if (path.startsWith('/tests')) return 'Tests';
    if (path.startsWith('/bluetooth')) return 'Bluetooth';
    return 'HomeDX';
  }
}
