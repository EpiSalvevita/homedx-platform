import 'package:flutter/material.dart';
import '../config/app_theme.dart';
import 'figma_ui.dart';

/// Generic status pill matching [TestResultBadge] / [AppointmentStatusBadge]
/// styling — for statuses that don't warrant their own badge class
/// (payments, certificates).
class StatusPill extends StatelessWidget {
  final String label;
  final Color background;
  final Color foreground;

  const StatusPill({
    super.key,
    required this.label,
    required this.background,
    required this.foreground,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: AppTheme.resultBadgePadding,
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(AppTheme.resultBadgeRadius),
      ),
      child: Text(
        label,
        style: FigmaUi.rubik(
          fontSize: 12,
          fontWeight: FontWeight.w500,
          color: foreground,
        ),
      ),
    );
  }
}
