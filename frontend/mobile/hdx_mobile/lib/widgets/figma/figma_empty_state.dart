part of '../figma_ui.dart';

/// Reusable, elderly-friendly empty state: illustration or icon, a short title,
/// a supportive message, and an optional primary action.
class FigmaEmptyState extends StatelessWidget {
  final String? assetPath;
  final IconData icon;
  final String title;
  final String message;
  final String? actionLabel;
  final VoidCallback? onAction;

  const FigmaEmptyState({
    super.key,
    this.assetPath,
    this.icon = Icons.inbox_outlined,
    required this.title,
    required this.message,
    this.actionLabel,
    this.onAction,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 48),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 420),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (assetPath != null)
                Image.asset(assetPath!, height: 160, fit: BoxFit.contain)
              else
                Container(
                  width: 104,
                  height: 104,
                  decoration: const BoxDecoration(
                    color: AppTheme.primaryLight,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(icon, size: 52, color: AppTheme.primaryBlue),
                ),
              const SizedBox(height: 24),
              Text(
                title,
                textAlign: TextAlign.center,
                style: FigmaUi.rubik(fontSize: 20, fontWeight: FontWeight.w500, color: AppTheme.textColor),
              ),
              const SizedBox(height: 10),
              Text(
                message,
                textAlign: TextAlign.center,
                style: FigmaUi.rubik(fontSize: 16, fontWeight: FontWeight.w300, color: AppTheme.textColorSecondary, height: 1.4),
              ),
              if (actionLabel != null && onAction != null) ...[
                const SizedBox(height: 28),
                NeumorphicPillButton(
                  label: actionLabel!,
                  onPressed: onAction,
                  expanded: false,
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
