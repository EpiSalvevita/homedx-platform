import 'package:flutter/material.dart';
import '../../config/app_theme.dart';
import '../../l10n/marketing_strings.dart';
import '../../utils/app_assets.dart';
import 'marketing_section.dart';
import 'product_showcase_card.dart';

/// Four-card product showcase (Cube, appointments, video, results/shop).
/// Restored from the former About page onto the landing marketing flow.
class ProductShowcaseSection extends StatelessWidget {
  final bool isWide;

  const ProductShowcaseSection({super.key, required this.isWide});

  @override
  Widget build(BuildContext context) {
    final strings = MarketingStrings.of(context);
    final crossAxisCount = isWide ? 2 : 1;

    return MarketingSection(
      title: strings.productTitle,
      subtitle: strings.productSubtitle,
      child: GridView(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: crossAxisCount,
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
          mainAxisExtent: isWide ? 440 : 500,
        ),
        children: [
          ProductShowcaseCard(
            imagePath: AppAssets.marketingSchnelltestProduct,
            imagePlaceholderLabel: strings.imageComingSoon,
            title: strings.productCubeTitle,
            description: strings.productCubeBody,
            accentColor: AppTheme.accentBlue,
          ),
          ProductShowcaseCard(
            imagePath: AppAssets.marketingTerminBuchen,
            imagePlaceholderLabel: strings.imageComingSoon,
            title: strings.productAppointmentTitle,
            description: strings.productAppointmentBody,
            accentColor: AppTheme.accentMint,
          ),
          ProductShowcaseCard(
            imagePath: AppAssets.marketingVideoConsultation,
            imagePlaceholderLabel: strings.imageComingSoon,
            title: strings.productVideoTitle,
            description: strings.productVideoBody,
            accentColor: AppTheme.accentCoral,
          ),
          ProductShowcaseCard(
            imagePath: null,
            imagePlaceholderLabel: strings.imageComingSoon,
            title: strings.productResultsTitle,
            description: strings.productResultsBody,
            accentColor: AppTheme.accentBlue,
          ),
        ],
      ),
    );
  }
}
