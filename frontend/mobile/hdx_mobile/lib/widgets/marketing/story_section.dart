import 'package:flutter/material.dart';
import '../../config/app_theme.dart';
import '../../widgets/figma_ui.dart';
import 'marketing_image_slot.dart';
import 'marketing_section.dart';

class StorySection extends StatelessWidget {
  final String title;
  final String subtitle;
  final String body;
  final String? imagePath;
  final String imagePlaceholderLabel;
  final bool isWide;

  const StorySection({
    super.key,
    required this.title,
    required this.subtitle,
    required this.body,
    this.imagePath,
    required this.imagePlaceholderLabel,
    required this.isWide,
  });

  @override
  Widget build(BuildContext context) {
    final textColumn = Column(
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
        const SizedBox(height: 8),
        Text(
          subtitle,
          style: FigmaUi.rubik(
            fontSize: 18,
            fontWeight: FontWeight.w400,
            color: AppTheme.textColorSecondary,
          ),
        ),
        const SizedBox(height: 20),
        Text(
          body,
          style: FigmaUi.rubik(
            fontSize: 16,
            fontWeight: FontWeight.w400,
            color: AppTheme.textColor,
            height: 1.5,
          ),
        ),
      ],
    );

    final imageSlot = MarketingImageSlot(
      assetPath: imagePath,
      placeholderLabel: imagePlaceholderLabel,
      height: isWide ? 320 : 220,
      accentColor: AppTheme.accentMint,
    );

    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: MarketingSection.maxContentWidth),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(
            AppTheme.screenHorizontalPadding,
            48,
            AppTheme.screenHorizontalPadding,
            16,
          ),
          child: isWide
              ? Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(child: textColumn),
                    const SizedBox(width: 48),
                    Expanded(child: imageSlot),
                  ],
                )
              : Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    textColumn,
                    const SizedBox(height: 28),
                    imageSlot,
                  ],
                ),
        ),
      ),
    );
  }
}
