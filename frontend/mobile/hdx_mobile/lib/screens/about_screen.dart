import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../config/app_theme.dart';
import '../../l10n/marketing_strings.dart';
import '../../utils/app_assets.dart';
import '../../widgets/figma_ui.dart';
import '../../widgets/neumorphic.dart';
import '../../widgets/marketing/marketing_footer.dart';
import '../../widgets/marketing/marketing_nav.dart';
import '../../widgets/marketing/marketing_section.dart';
import '../../widgets/marketing/product_showcase_card.dart';
import '../../widgets/marketing/story_section.dart';

class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final isWide = constraints.maxWidth >= MarketingSection.wideBreakpoint;
            final strings = MarketingStrings.of(context);

            return SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  MarketingNav(isWide: isWide),
                  _HeroSection(strings: strings, isWide: isWide),
                  StorySection(
                    title: strings.storyTitle,
                    subtitle: strings.storySubtitle,
                    body: strings.storyBody,
                    imagePath: AppAssets.marketingStoryTeam,
                    imagePlaceholderLabel: strings.imageComingSoon,
                    isWide: isWide,
                  ),
                  _ProductSection(strings: strings, isWide: isWide),
                  _HowItWorksSection(strings: strings, isWide: isWide),
                  _DoctorsSection(strings: strings, isWide: isWide),
                  _FooterCta(strings: strings, isWide: isWide),
                  const MarketingFooter(),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}

class _HeroSection extends StatelessWidget {
  final MarketingStrings strings;
  final bool isWide;

  const _HeroSection({required this.strings, required this.isWide});

  @override
  Widget build(BuildContext context) {
    final textColumn = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          strings.heroTitle,
          style: FigmaUi.rubik(
            fontSize: isWide ? 44 : 32,
            fontWeight: FontWeight.w600,
            color: AppTheme.textColor,
            height: 1.15,
          ),
        ),
        const SizedBox(height: 16),
        Text(
          strings.heroSubtitle,
          style: FigmaUi.rubik(
            fontSize: isWide ? 20 : 18,
            fontWeight: FontWeight.w400,
            color: AppTheme.textColorSecondary,
            height: 1.4,
          ),
        ),
      ],
    );

    final illustration = ClipRRect(
      borderRadius: BorderRadius.circular(24),
      child: Container(
        color: AppTheme.surface,
        padding: const EdgeInsets.all(24),
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            Align(
              alignment: Alignment.bottomLeft,
              child: Image.asset(
                AppAssets.loginDoctor,
                height: isWide ? 280 : 200,
                fit: BoxFit.contain,
              ),
            ),
            Positioned(
              top: 16,
              right: 16,
              child: Image.asset(AppAssets.iconDna, width: 56, height: 40),
            ),
            Positioned(
              bottom: 24,
              right: 24,
              child: Image.asset(
                AppAssets.logo,
                width: AppAssets.logoLoginWidth * 0.7,
                height: AppAssets.logoLoginHeight * 0.7,
                fit: BoxFit.contain,
              ),
            ),
          ],
        ),
      ),
    );

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: AppTheme.primaryLight.withValues(alpha: 0.35),
        borderRadius: const BorderRadius.vertical(bottom: Radius.circular(32)),
      ),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: MarketingSection.maxContentWidth),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(
              AppTheme.screenHorizontalPadding,
              24,
              AppTheme.screenHorizontalPadding,
              48,
            ),
            child: isWide
                ? Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Expanded(child: textColumn),
                      const SizedBox(width: 48),
                      Expanded(child: illustration),
                    ],
                  )
                : Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      textColumn,
                      const SizedBox(height: 32),
                      illustration,
                    ],
                  ),
          ),
        ),
      ),
    );
  }
}

class _ProductSection extends StatelessWidget {
  final MarketingStrings strings;
  final bool isWide;

  const _ProductSection({required this.strings, required this.isWide});

  @override
  Widget build(BuildContext context) {
    final crossAxisCount = isWide ? 2 : 1;

    return MarketingSection(
      title: strings.productTitle,
      subtitle: strings.productSubtitle,
      child: GridView.count(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        crossAxisCount: crossAxisCount,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
        childAspectRatio: isWide ? 1.15 : 0.95,
        children: [
          ProductShowcaseCard(
            imagePath: AppAssets.marketingCubeProduct,
            imagePlaceholderLabel: strings.imageComingSoon,
            title: strings.productCubeTitle,
            description: strings.productCubeBody,
            accentColor: AppTheme.accentBlue,
          ),
          ProductShowcaseCard(
            imagePath: AppAssets.marketingLifestyleHome,
            imagePlaceholderLabel: strings.imageComingSoon,
            title: strings.productAppointmentTitle,
            description: strings.productAppointmentBody,
            accentColor: AppTheme.accentMint,
          ),
          ProductShowcaseCard(
            imagePath: null,
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

class _HowItWorksSection extends StatelessWidget {
  final MarketingStrings strings;
  final bool isWide;

  const _HowItWorksSection({required this.strings, required this.isWide});

  @override
  Widget build(BuildContext context) {
    final steps = [
      _StepData('1', strings.step1Title, strings.step1Body, AppTheme.accentBlue),
      _StepData('2', strings.step2Title, strings.step2Body, AppTheme.accentMint),
      _StepData('3', strings.step3Title, strings.step3Body, AppTheme.accentCoral),
    ];

    return MarketingSection(
      title: strings.howItWorksTitle,
      subtitle: strings.howItWorksSubtitle,
      child: isWide
          ? Row(
              children: steps
                  .map(
                    (step) => Expanded(
                      child: Padding(
                        padding: const EdgeInsets.only(right: 12),
                        child: _StepCard(step: step),
                      ),
                    ),
                  )
                  .toList(),
            )
          : Column(
              children: steps
                  .map(
                    (step) => Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: _StepCard(step: step),
                    ),
                  )
                  .toList(),
            ),
    );
  }
}

class _StepData {
  final String number;
  final String title;
  final String body;
  final Color color;

  const _StepData(this.number, this.title, this.body, this.color);
}

class _StepCard extends StatelessWidget {
  final _StepData step;

  const _StepCard({required this.step});

  @override
  Widget build(BuildContext context) {
    return NeumorphicContainer(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: step.color.withValues(alpha: 0.25),
              borderRadius: BorderRadius.circular(12),
            ),
            alignment: Alignment.center,
            child: Text(
              step.number,
              style: FigmaUi.rubik(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: AppTheme.textColor,
              ),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            step.title,
            style: FigmaUi.rubik(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: AppTheme.textColor,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            step.body,
            style: FigmaUi.bodyLight(fontSize: 14),
          ),
        ],
      ),
    );
  }
}

class _DoctorsSection extends StatelessWidget {
  final MarketingStrings strings;
  final bool isWide;

  const _DoctorsSection({required this.strings, required this.isWide});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: MarketingSection.maxContentWidth),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(
            AppTheme.screenHorizontalPadding,
            32,
            AppTheme.screenHorizontalPadding,
            16,
          ),
          child: NeumorphicContainer(
            padding: EdgeInsets.all(isWide ? 40 : 24),
            child: isWide
                ? Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              strings.doctorsTitle,
                              style: FigmaUi.rubik(
                                fontSize: 24,
                                fontWeight: FontWeight.w600,
                                color: AppTheme.textColor,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              strings.doctorsSubtitle,
                              style: FigmaUi.rubik(
                                fontSize: 16,
                                fontWeight: FontWeight.w400,
                                color: AppTheme.textColorSecondary,
                              ),
                            ),
                            const SizedBox(height: 12),
                            Text(
                              strings.doctorsBody,
                              style: FigmaUi.bodyLight(fontSize: 14),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 24),
                      NeumorphicButton(
                        isPrimary: true,
                        onPressed: () => context.go('/login/doctor'),
                        padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                        child: Text(
                          strings.doctorsCta,
                          style: FigmaUi.rubik(
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ],
                  )
                : Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Text(
                        strings.doctorsTitle,
                        style: FigmaUi.rubik(
                          fontSize: 22,
                          fontWeight: FontWeight.w600,
                          color: AppTheme.textColor,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        strings.doctorsSubtitle,
                        style: FigmaUi.rubik(
                          fontSize: 16,
                          fontWeight: FontWeight.w400,
                          color: AppTheme.textColorSecondary,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        strings.doctorsBody,
                        style: FigmaUi.bodyLight(fontSize: 14),
                      ),
                      const SizedBox(height: 20),
                      NeumorphicButton(
                        isPrimary: true,
                        onPressed: () => context.go('/login/doctor'),
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        child: Text(
                          strings.doctorsCta,
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
      ),
    );
  }
}

class _FooterCta extends StatelessWidget {
  final MarketingStrings strings;
  final bool isWide;

  const _FooterCta({required this.strings, required this.isWide});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: MarketingSection.maxContentWidth),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(
            AppTheme.screenHorizontalPadding,
            32,
            AppTheme.screenHorizontalPadding,
            48,
          ),
          child: Column(
            children: [
              Text(
                strings.footerCtaTitle,
                style: FigmaUi.rubik(
                  fontSize: isWide ? 28 : 24,
                  fontWeight: FontWeight.w600,
                  color: AppTheme.textColor,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 12),
              Text(
                strings.footerCtaBody,
                style: FigmaUi.rubik(
                  fontSize: 16,
                  fontWeight: FontWeight.w400,
                  color: AppTheme.textColorSecondary,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              Wrap(
                alignment: WrapAlignment.center,
                spacing: 12,
                runSpacing: 12,
                children: [
                  NeumorphicButton(
                    isPrimary: true,
                    onPressed: () => context.go('/signup'),
                    padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                    child: Text(
                      strings.footerCtaPrimary,
                      style: FigmaUi.rubik(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                        color: Colors.white,
                      ),
                    ),
                  ),
                  NeumorphicButton(
                    onPressed: () => context.go('/'),
                    padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                    child: Text(
                      strings.footerCtaSecondary,
                      style: FigmaUi.rubik(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                        color: AppTheme.textColor,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
