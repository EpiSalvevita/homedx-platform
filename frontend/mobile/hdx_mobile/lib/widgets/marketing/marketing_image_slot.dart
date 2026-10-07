import 'package:flutter/material.dart';
import '../../config/app_theme.dart';
import '../../widgets/figma_ui.dart';
import '../../widgets/neumorphic.dart';

/// Image slot for marketing pages. Shows [assetPath] when provided, otherwise a placeholder.
class MarketingImageSlot extends StatelessWidget {
  final String? assetPath;
  /// Optional second illustration, shown beside [assetPath].
  final String? secondaryAssetPath;
  /// Visual scale for [secondaryAssetPath] (jar art has more empty padding).
  final double secondaryScale;
  final String placeholderLabel;
  final double height;
  final Color accentColor;

  const MarketingImageSlot({
    super.key,
    this.assetPath,
    this.secondaryAssetPath,
    this.secondaryScale = 1.0,
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
          child: ColoredBox(
            color: AppTheme.surface,
            child: _buildContent(),
          ),
        ),
      ),
    );
  }

  Widget _buildContent() {
    if (assetPath == null) {
      return _Placeholder(
        label: placeholderLabel,
        accentColor: accentColor,
      );
    }

    final primary = _Illustration(assetPath: assetPath!, fallbackLabel: placeholderLabel, accentColor: accentColor);
    if (secondaryAssetPath == null) {
      return Padding(
        padding: const EdgeInsets.all(12),
        child: primary,
      );
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(child: primary),
          const SizedBox(width: 8),
          Expanded(
            child: _Illustration(
              assetPath: secondaryAssetPath!,
              fallbackLabel: placeholderLabel,
              accentColor: accentColor,
              scale: secondaryScale,
            ),
          ),
        ],
      ),
    );
  }
}

class _Illustration extends StatelessWidget {
  final String assetPath;
  final String fallbackLabel;
  final Color accentColor;
  final double scale;

  const _Illustration({
    required this.assetPath,
    required this.fallbackLabel,
    required this.accentColor,
    this.scale = 1.0,
  });

  @override
  Widget build(BuildContext context) {
    final image = Image.asset(
      assetPath,
      fit: BoxFit.contain,
      errorBuilder: (_, __, ___) => _Placeholder(
        label: fallbackLabel,
        accentColor: accentColor,
      ),
    );
    if (scale == 1.0) return image;
    return Transform.scale(scale: scale, child: image);
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
