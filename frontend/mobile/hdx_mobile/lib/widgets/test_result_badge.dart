import 'package:flutter/material.dart';
import '../config/app_theme.dart';
import '../models/user_test_result.dart';
import 'figma_ui.dart';

/// Pill badge for test results — same palette logic as [AppointmentStatusBadge].
class TestResultBadge extends StatelessWidget {
  final UserTestResult result;

  const TestResultBadge({super.key, required this.result, this.showIcon = true});

  /// When false, the leading status icon is hidden (use where an adjacent icon
  /// already conveys the status, to avoid duplication).
  final bool showIcon;

  @override
  Widget build(BuildContext context) {
    final kind = result.resultKind;
    final (background, foreground) = colorsForKind(kind);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(AppTheme.resultBadgeRadius),
        border: kind == TestResultKind.pending
            ? Border.all(color: AppTheme.primaryBlue, width: 1.5)
            : null,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (showIcon) ...[
            Icon(iconForKind(kind), size: 16, color: foreground),
            const SizedBox(width: 6),
          ],
          Text(
            result.resultLabel,
            style: FigmaUi.rubik(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: foreground,
            ),
          ),
        ],
      ),
    );
  }

  static (Color background, Color foreground) colorsForKind(TestResultKind kind) {
    switch (kind) {
      case TestResultKind.positive:
        return (
          AppTheme.accentCoral.withValues(alpha: 0.55),
          AppTheme.navy,
        );
      case TestResultKind.negative:
        return (AppTheme.successColor, AppTheme.navy);
      case TestResultKind.pending:
        return (Colors.white, AppTheme.primaryBlue);
      case TestResultKind.inconclusive:
        return (
          const Color(0xFFE8E0F5),
          const Color(0xFF5B4B8A),
        );
      case TestResultKind.invalid:
        return (
          AppTheme.navy.withValues(alpha: 0.08),
          AppTheme.textColorSecondary,
        );
    }
  }

  static IconData iconForKind(TestResultKind kind) {
    switch (kind) {
      case TestResultKind.positive:
        return Icons.error_outline;
      case TestResultKind.negative:
        return Icons.check_circle_outline;
      case TestResultKind.pending:
        return Icons.schedule;
      case TestResultKind.inconclusive:
        return Icons.help_outline;
      case TestResultKind.invalid:
        return Icons.block;
    }
  }

  static Color iconColorForKind(TestResultKind kind) {
    switch (kind) {
      case TestResultKind.positive:
        return AppTheme.accentCoral;
      case TestResultKind.negative:
        return AppTheme.successColor;
      case TestResultKind.pending:
        return AppTheme.primaryBlue;
      case TestResultKind.inconclusive:
        return const Color(0xFF5B4B8A);
      case TestResultKind.invalid:
        return AppTheme.textColorSecondary;
    }
  }
}
