import 'package:flutter/material.dart';
import '../../config/app_theme.dart';
import '../../widgets/figma_ui.dart';
import '../../widgets/neumorphic.dart';
import 'marketing_image_slot.dart';

class ProductShowcaseCard extends StatelessWidget {
  final String? imagePath;
  final String imagePlaceholderLabel;
  final String title;
  final String description;
  final Color accentColor;

  const ProductShowcaseCard({
    super.key,
    this.imagePath,
    required this.imagePlaceholderLabel,
    required this.title,
    required this.description,
    this.accentColor = AppTheme.accentBlue,
  });

  @override
  Widget build(BuildContext context) {
    return NeumorphicContainer(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          MarketingImageSlot(
            assetPath: imagePath,
            placeholderLabel: imagePlaceholderLabel,
            height: 220,
            accentColor: accentColor,
          ),
          const SizedBox(height: 16),
          Text(
            title,
            style: FigmaUi.rubik(
              fontSize: 20,
              fontWeight: FontWeight.w600,
              color: AppTheme.textColor,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            description,
            style: FigmaUi.bodyLight(fontSize: 17),
          ),
        ],
      ),
    );
  }
}
