import 'package:flutter/material.dart';
import '../config/app_theme.dart';
import '../models/doctor.dart';
import 'figma_ui.dart';

/// Pill badge for appointment status using the HomeDX palette.
class AppointmentStatusBadge extends StatelessWidget {
  final Appointment appointment;

  const AppointmentStatusBadge({super.key, required this.appointment});

  @override
  Widget build(BuildContext context) {
    final (background, foreground) = _colorsForStatus(appointment.status);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(AppTheme.resultBadgeRadius),
      ),
      child: Text(
        appointment.statusLabelDe,
        style: FigmaUi.rubik(
          fontSize: 12,
          fontWeight: FontWeight.w500,
          color: foreground,
        ),
      ),
    );
  }

  static (Color background, Color foreground) _colorsForStatus(String status) {
    switch (status.toLowerCase()) {
      case 'confirmed':
        return (
          AppTheme.successColor.withValues(alpha: 0.45),
          AppTheme.onMint,
        );
      case 'pending':
        return (AppTheme.primaryLight, AppTheme.primaryBlue);
      case 'cancelled':
        return (
          AppTheme.accentCoral.withValues(alpha: 0.55),
          AppTheme.navy,
        );
      case 'completed':
        return (
          AppTheme.navy.withValues(alpha: 0.08),
          AppTheme.textColorSecondary,
        );
      case 'no_show':
        return (
          AppTheme.accentCoral.withValues(alpha: 0.7),
          AppTheme.navy,
        );
      default:
        return (
          AppTheme.navy.withValues(alpha: 0.08),
          AppTheme.textColorSecondary,
        );
    }
  }
}
