part of '../figma_ui.dart';

class FigmaResultBadge extends StatelessWidget {
  final String label;
  final bool isPositive;
  /// Optional status icon so meaning is not conveyed by color alone
  /// (helps color-blind / low-vision users). Defaults to a sensible icon.
  final IconData? icon;

  const FigmaResultBadge({
    super.key,
    required this.label,
    required this.isPositive,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    final resolvedIcon =
        icon ?? (isPositive ? Icons.error_outline : Icons.check_circle_outline);
    return Container(
      padding: AppTheme.resultBadgePadding,
      decoration: BoxDecoration(
        color: isPositive ? AppTheme.resultBadgePositive : AppTheme.resultBadgeNegative,
        borderRadius: BorderRadius.circular(AppTheme.resultBadgeRadius),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(resolvedIcon, size: 15, color: AppTheme.textColor),
          const SizedBox(width: 6),
          Text(
            label,
            style: FigmaUi.rubik(fontSize: 14, fontWeight: FontWeight.w500, color: AppTheme.textColor, height: 1.05),
          ),
        ],
      ),
    );
  }
}
