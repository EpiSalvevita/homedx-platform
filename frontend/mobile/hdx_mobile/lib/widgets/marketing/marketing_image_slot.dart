import 'package:flutter/material.dart';
import '../../config/app_theme.dart';
import '../../widgets/figma_ui.dart';
import '../../widgets/neumorphic.dart';

/// Image slot for marketing pages. Shows [assetPath] when provided, otherwise a placeholder.
class MarketingImageSlot extends StatelessWidget {
  final String? assetPath;
  final String placeholderLabel;
  final double height;
  final Color accentColor;

  const MarketingImageSlot({
    super.key,
    this.assetPath,
    required this.placeholderLabel,
    this.height = 220,
    this.accentColor = AppTheme.accentBlue,
  });

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(24),
      child: NeumorphicContainer(
        borderRadius: 24,
        padding: const EdgeInsets.all(0),
        child: SizedBox(
          height: height,
          width: double.infinity,
          child: assetPath != null
              ? Image.asset(
                  assetPath!,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => _Placeholder(
                    label: placeholderLabel,
                    accentColor: accentColor,
                  ),
                )
              : _Placeholder(
                  label: placeholderLabel,
                  accentColor: accentColor,
                ),
        ),
      ),
    );
  }
}

class _Placeholder extends StatelessWidget {
  final String label;
  final Color accentColor;

  const _Placeholder({
    required this.label,
    required this.accentColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      color: accentColor.withValues(alpha: 0.12),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.image_outlined,
              size: 48,
              color: accentColor.withValues(alpha: 0.6),
            ),
            const SizedBox(height: 12),
            Text(
              label,
              style: FigmaUi.rubik(
                fontSize: 14,
                fontWeight: FontWeight.w400,
                color: AppTheme.textColorSecondary,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
