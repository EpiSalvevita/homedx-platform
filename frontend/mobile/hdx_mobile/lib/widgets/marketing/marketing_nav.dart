import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../config/app_theme.dart';
import '../../providers/locale_provider.dart';
import '../../utils/app_assets.dart';
import '../../widgets/figma_ui.dart';
import '../../widgets/neumorphic.dart';
import 'marketing_section.dart';

class MarketingNav extends StatelessWidget {
  final bool isWide;

  const MarketingNav({super.key, required this.isWide});

  @override
  Widget build(BuildContext context) {
    final localeProvider = context.watch<LocaleProvider>();

    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: MarketingSection.maxContentWidth),
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppTheme.screenHorizontalPadding,
            vertical: 16,
          ),
          child: Row(
            children: [
              GestureDetector(
                onTap: () => context.go('/'),
                child: Image.asset(
                  AppAssets.logo,
                  width: AppAssets.logoHeaderWidth,
                  height: AppAssets.logoHeaderHeight,
                  fit: BoxFit.contain,
                ),
              ),
              const Spacer(),
              if (isWide) ...[
                TextButton(
                  onPressed: () => context.go('/'),
                  child: Text(
                    localeProvider.isGerman ? 'App' : 'App',
                    style: FigmaUi.rubik(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      color: AppTheme.primaryBlue,
                    ),
                  ),
                ),
                const SizedBox(width: 4),
                TextButton(
                  onPressed: () => context.go('/login'),
                  child: Text(
                    localeProvider.isGerman ? 'Anmelden' : 'Sign in',
                    style: FigmaUi.rubik(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      color: AppTheme.primaryBlue,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
              ],
              _LocaleToggle(localeProvider: localeProvider),
              const SizedBox(width: 8),
              NeumorphicButton(
                isPrimary: true,
                onPressed: () => context.go('/signup'),
                padding: EdgeInsets.symmetric(
                  horizontal: isWide ? 28 : 20,
                  vertical: 14,
                ),
                child: Text(
                  localeProvider.isGerman ? 'Registrieren' : 'Register',
                  style: FigmaUi.rubik(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _LocaleToggle extends StatelessWidget {
  final LocaleProvider localeProvider;

  const _LocaleToggle({required this.localeProvider});

  @override
  Widget build(BuildContext context) {
    return NeumorphicContainer(
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
      borderRadius: 12,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _LocaleChip(
            label: 'DE',
            isSelected: localeProvider.isGerman,
            onTap: localeProvider.setGerman,
          ),
          _LocaleChip(
            label: 'EN',
            isSelected: !localeProvider.isGerman,
            onTap: localeProvider.setEnglish,
          ),
        ],
      ),
    );
  }
}

class _LocaleChip extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _LocaleChip({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: isSelected ? AppTheme.primaryBlue : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Text(
          label,
          style: FigmaUi.rubik(
            fontSize: 13,
            fontWeight: FontWeight.w500,
            color: isSelected ? Colors.white : AppTheme.textColorSecondary,
          ),
        ),
      ),
    );
  }
}
