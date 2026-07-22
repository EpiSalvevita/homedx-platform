import 'package:flutter/material.dart';
import '../../config/app_theme.dart';
import '../../l10n/marketing_strings.dart';
import '../../utils/app_assets.dart';
import '../../core/constants.dart';
import '../../widgets/figma_ui.dart';
import 'marketing_section.dart';

class MarketingFooter extends StatelessWidget {
  const MarketingFooter({super.key});

  @override
  Widget build(BuildContext context) {
    final strings = MarketingStrings.of(context);

    return Container(
      width: double.infinity,
      color: AppTheme.navy,
      padding: const EdgeInsets.symmetric(
        vertical: 32,
        horizontal: AppTheme.screenHorizontalPadding,
      ),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: MarketingSection.maxContentWidth),
          child: Column(
            children: [
              Image.asset(
                AppAssets.logo,
                width: AppAssets.logoHeaderWidth,
                height: AppAssets.logoHeaderHeight,
                fit: BoxFit.contain,
                color: Colors.white,
                colorBlendMode: BlendMode.srcIn,
              ),
              const SizedBox(height: 12),
              Text(
                '${AppConstants.appName} · Version ${AppConstants.appVersion}',
                style: FigmaUi.rubik(
                  fontSize: 14,
                  fontWeight: FontWeight.w400,
                  color: Colors.white70,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                strings.legalPlaceholder,
                style: FigmaUi.rubik(
                  fontSize: 13,
                  fontWeight: FontWeight.w300,
                  color: Colors.white54,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
