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
  static const double sidebarWidth = 240;
  static const double maxContentWidth = 1100;

  static const List<WebNavItem> patientItems = [
    WebNavItem(label: 'Home', icon: Icons.home_outlined, path: '/home', routeName: 'home'),
    WebNavItem(label: 'Termine', icon: Icons.calendar_today_outlined, path: '/appointments', routeName: 'appointments'),
    WebNavItem(label: 'Ergebnisse', icon: Icons.assignment_outlined, path: '/results', routeName: 'results'),
    WebNavItem(label: 'Shop', icon: Icons.shopping_bag_outlined, path: '/shop', routeName: 'shop'),
    WebNavItem(label: 'Benachrichtigungen', icon: Icons.notifications_outlined, path: '/notifications', routeName: 'notifications'),
    WebNavItem(label: 'Zahlungsverlauf', icon: Icons.payment_outlined, path: '/payments', routeName: 'payments'),
    WebNavItem(label: 'Profil', icon: Icons.person_outline, path: '/profile', routeName: 'profile'),
  ];

  static const List<WebNavItem> doctorItems = [
    WebNavItem(label: 'Dashboard', icon: Icons.dashboard_outlined, path: '/doctor/dashboard', routeName: 'doctor-dashboard'),
    WebNavItem(label: 'Termine', icon: Icons.calendar_today_outlined, path: '/doctor/appointments', routeName: 'doctor-appointments'),
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
}
