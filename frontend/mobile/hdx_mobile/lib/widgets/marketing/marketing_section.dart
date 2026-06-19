import 'package:flutter/material.dart';
import '../../config/app_theme.dart';
import '../../widgets/figma_ui.dart';

class MarketingSection extends StatelessWidget {
  final String title;
  final String? subtitle;
  final Widget child;
  final EdgeInsetsGeometry padding;

  static const double maxContentWidth = 1100;
  static const double wideBreakpoint = 768;

  const MarketingSection({
    super.key,
    required this.title,
    this.subtitle,
    required this.child,
    this.padding = const EdgeInsets.fromLTRB(
      AppTheme.screenHorizontalPadding,
      48,
      AppTheme.screenHorizontalPadding,
      16,
    ),
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: maxContentWidth),
        child: Padding(
          padding: padding,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: FigmaUi.rubik(
                  fontSize: 28,
                  fontWeight: FontWeight.w600,
                  color: AppTheme.textColor,
                ),
              ),
              if (subtitle != null) ...[
                const SizedBox(height: 8),
                Text(
                  subtitle!,
                  style: FigmaUi.rubik(
                    fontSize: 18,
                    fontWeight: FontWeight.w400,
                    color: AppTheme.textColorSecondary,
                  ),
                ),
              ],
              const SizedBox(height: 28),
              child,
            ],
          ),
        ),
      ),
    );
  }
}
