import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../config/app_theme.dart';
import '../providers/locale_provider.dart';
import '../l10n/marketing_strings.dart';
import '../utils/app_assets.dart';
import '../core/constants.dart';
import '../widgets/figma_ui.dart';
import '../widgets/neumorphic.dart';
import '../widgets/marketing/how_it_works_section.dart';
import '../widgets/marketing/marketing_section.dart';
import '../widgets/marketing/story_section.dart';

ButtonStyle _landingLinkButtonStyle({
  EdgeInsetsGeometry? padding,
  double minHeight = AppTheme.minTouchTarget,
  Color? foregroundColor,
}) {
  return TextButton.styleFrom(
    minimumSize: Size(0, minHeight),
    padding: padding ?? const EdgeInsets.symmetric(horizontal: 12),
    foregroundColor: foregroundColor,
  ).copyWith(
    overlayColor: WidgetStateProperty.resolveWith((states) {
      if (states.contains(WidgetState.hovered)) {
        return AppTheme.primaryBlue.withValues(alpha: 0.1);
      }
      if (states.contains(WidgetState.focused)) {
        return AppTheme.primaryBlue.withValues(alpha: 0.14);
      }
      return null;
    }),
  );
}

class LandingScreen extends StatefulWidget {
  /// When `about`, scrolls to the merged About block after first frame
  /// (used by `/about` redirect and in-page nav).
  final String? initialSection;

  const LandingScreen({super.key, this.initialSection});

  static const double maxContentWidth = 1100;

  @override
  State<LandingScreen> createState() => _LandingScreenState();
}

class _LandingScreenState extends State<LandingScreen> {
  final ScrollController _scrollController = ScrollController();
  final GlobalKey _aboutSectionKey = GlobalKey();

  @override
  void initState() {
    super.initState();
    if (widget.initialSection == 'about') {
      WidgetsBinding.instance.addPostFrameCallback((_) => _scrollToAbout());
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollToAbout() {
    final target = _aboutSectionKey.currentContext;
    if (target == null) return;
    Scrollable.ensureVisible(
      target,
      duration: const Duration(milliseconds: 450),
      curve: Curves.easeInOut,
      alignment: 0.05,
    );
  }

  @override
  Widget build(BuildContext context) {
    final strings = MarketingStrings.of(context);

    return Scaffold(
      backgroundColor: AppTheme.background,
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final isWide = constraints.maxWidth >= MarketingSection.wideBreakpoint;
            return SingleChildScrollView(
              controller: _scrollController,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _LandingNav(isWide: isWide),
                  _HeroSection(isWide: isWide),
                  HowItWorksSection(isWide: isWide),
                  _FeatureSection(
                    title: strings.patientsTitle,
                    subtitle: strings.patientsSubtitle,
                    features: [
                      _FeatureItem(
                        iconPath: AppAssets.iconDna,
                        title: strings.patientResultsTitle,
                        description: strings.patientResultsBody,
                      ),
                      _FeatureItem(
                        iconPath: AppAssets.iconHomeBag,
                        title: strings.patientShopTitle,
                        description: strings.patientShopBody,
                      ),
                      _FeatureItem(
                        iconPath: AppAssets.iconHeartbeat,
                        title: strings.patientCertificatesTitle,
                        description: strings.patientCertificatesBody,
                      ),
                    ],
                    isWide: isWide,
                  ),
                  _FeatureSection(
                    title: 'Für Ärzte',
                    subtitle: 'Dashboard, Verfügbarkeit und Videoanrufe im Browser.',
                    features: const [
                      _FeatureItem(
                        iconPath: AppAssets.iconHomeCalendar,
                        title: 'Dashboard',
                        description: 'Heutige Termine und Patienten auf einen Blick.',
                      ),
                      _FeatureItem(
                        iconPath: AppAssets.iconFirstAid,
                        title: 'Verfügbarkeit',
                        description: 'Wöchentliche Sprechzeiten flexibel verwalten.',
                      ),
                      _FeatureItem(
                        iconPath: AppAssets.iconDna,
                        title: 'Videoanrufe',
                        description: 'Sichere Video-Konsultationen mit Patienten.',
                      ),
                    ],
                    isWide: isWide,
                    accentColor: AppTheme.accentMint,
                  ),
                  KeyedSubtree(
                    key: _aboutSectionKey,
                    child: StorySection(
                      title: strings.storyTitle,
                      subtitle: strings.storySubtitle,
                      body: strings.storyBody,
                      imagePath: AppAssets.marketingStoryTeam,
                      imagePlaceholderLabel: strings.imageComingSoon,
                      isWide: isWide,
                    ),
                  ),
                  _DoctorCta(isWide: isWide),
                  const _LandingFooter(),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}

class _LandingNav extends StatelessWidget {
  final bool isWide;

  const _LandingNav({required this.isWide});

  static const double _desktopActionGap = 16;
  static const double _desktopAuthGap = 12;

  @override
  Widget build(BuildContext context) {
    final logo = Image.asset(
      AppAssets.logo,
      width: AppAssets.logoHeaderWidth,
      height: AppAssets.logoHeaderHeight,
      fit: BoxFit.contain,
    );

    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: LandingScreen.maxContentWidth),
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppTheme.screenHorizontalPadding,
            vertical: 16,
          ),
          child: isWide
              ? Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    logo,
                    const Spacer(),
                    const _DesktopNavActions(),
                  ],
                )
              : Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Center(child: logo),
                    const SizedBox(height: 16),
                    const _MobileNavActions(),
                  ],
                ),
        ),
      ),
    );
  }
}

/// Single horizontal bar for wide web: locale · login · register.
class _DesktopNavActions extends StatelessWidget {
  const _DesktopNavActions();

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        const _LocaleToggle(),
        const SizedBox(width: _LandingNav._desktopActionGap),
        TextButton(
          onPressed: () => context.go('/login'),
          style: _landingLinkButtonStyle(
            minHeight: AppTheme.largeTouchTarget,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            foregroundColor: AppTheme.textColor,
          ),
          child: Text(
            'Anmelden',
            style: FigmaUi.rubik(
              fontSize: 16,
              fontWeight: FontWeight.w500,
              color: AppTheme.textColor,
            ),
          ),
        ),
        const SizedBox(width: _LandingNav._desktopAuthGap),
        NeumorphicButton(
          isPrimary: true,
          onPressed: () => context.go('/signup'),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          child: Text(
            'Registrieren',
            style: FigmaUi.rubik(
              fontSize: 16,
              fontWeight: FontWeight.w500,
              color: Colors.white,
            ),
          ),
        ),
      ],
    );
  }
}

/// Stacked/wrapped actions for narrow viewports (unchanged destinations).
class _MobileNavActions extends StatelessWidget {
  const _MobileNavActions();

  @override
  Widget build(BuildContext context) {
    return Wrap(
      alignment: WrapAlignment.end,
      crossAxisAlignment: WrapCrossAlignment.center,
      spacing: 12,
      runSpacing: 12,
      children: [
        const _LocaleToggle(),
        NeumorphicButton(
          onPressed: () => context.go('/login'),
          padding: const EdgeInsets.symmetric(horizontal: 26, vertical: 16),
          child: Text(
            'Anmelden',
            style: FigmaUi.rubik(
              fontSize: 17,
              fontWeight: FontWeight.w500,
              color: AppTheme.textColor,
            ),
          ),
        ),
        NeumorphicButton(
          isPrimary: true,
          onPressed: () => context.go('/signup'),
          padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 16),
          child: Text(
            'Registrieren',
            style: FigmaUi.rubik(
              fontSize: 17,
              fontWeight: FontWeight.w500,
              color: Colors.white,
            ),
          ),
        ),
      ],
    );
  }
}

class _HeroSection extends StatelessWidget {
  final bool isWide;

  const _HeroSection({required this.isWide});

  @override
  Widget build(BuildContext context) {
    final textColumn = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Gesundheitstests\nund Online-Versorgung',
          style: FigmaUi.rubik(
            fontSize: isWide ? 40 : 32,
            fontWeight: FontWeight.w600,
            color: AppTheme.textColor,
            height: 1.15,
          ),
        ),
        const SizedBox(height: 16),
        Text(
          'HomeDX verbindet Schnelltests mit Cube, Arztterminen und Video-Konsultationen — für Patienten und Ärzte.',
          style: FigmaUi.rubik(
            fontSize: isWide ? 20 : 18,
            fontWeight: FontWeight.w400,
            color: AppTheme.textColorSecondary,
            height: 1.4,
          ),
        ),
        const SizedBox(height: 32),
        Wrap(
          spacing: 12,
          runSpacing: 12,
          children: [
            NeumorphicButton(
              isPrimary: true,
              onPressed: () => context.go('/signup'),
              padding: const EdgeInsets.symmetric(horizontal: 36, vertical: 18),
              child: Text(
                'Jetzt starten',
                style: FigmaUi.rubik(
                  fontSize: 18,
                  fontWeight: FontWeight.w500,
                  color: Colors.white,
                ),
              ),
            ),
            NeumorphicButton(
              onPressed: () => context.go('/login/doctor'),
              padding: const EdgeInsets.symmetric(horizontal: 36, vertical: 18),
              child: Text(
                'Für Ärzte',
                style: FigmaUi.rubik(
                  fontSize: 18,
                  fontWeight: FontWeight.w500,
                  color: AppTheme.textColor,
                ),
              ),
            ),
          ],
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
              // TEMPORARY preview swap for asset-generation review — revert
              // to AppAssets.loginDoctor if the generated illustration isn't
              // chosen.
              child: Image.asset(
                AppAssets.elderlyPatientPreview,
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
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppTheme.primaryLight.withValues(alpha: 0.6),
            AppTheme.accentMint.withValues(alpha: 0.12),
            AppTheme.surface,
          ],
          stops: const [0.0, 0.55, 1.0],
        ),
        borderRadius: const BorderRadius.vertical(bottom: Radius.circular(32)),
      ),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: LandingScreen.maxContentWidth),
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

class _FeatureItem {
  final String iconPath;
  final String title;
  final String description;

  const _FeatureItem({
    required this.iconPath,
    required this.title,
    required this.description,
  });
}

class _FeatureSection extends StatelessWidget {
  final String title;
  final String subtitle;
  final List<_FeatureItem> features;
  final bool isWide;
  final Color accentColor;

  const _FeatureSection({
    required this.title,
    required this.subtitle,
    required this.features,
    required this.isWide,
    this.accentColor = AppTheme.accentBlue,
  });

  @override
  Widget build(BuildContext context) {
    final crossAxisCount = isWide ? 3 : 2;

    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: LandingScreen.maxContentWidth),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(
            AppTheme.screenHorizontalPadding,
            48,
            AppTheme.screenHorizontalPadding,
            16,
          ),
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
              const SizedBox(height: 8),
              Text(
                subtitle,
                style: FigmaUi.rubik(
                  fontSize: 18,
                  fontWeight: FontWeight.w400,
                  color: AppTheme.textColorSecondary,
                ),
              ),
              const SizedBox(height: 28),
              GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: crossAxisCount,
                  crossAxisSpacing: 16,
                  mainAxisSpacing: 16,
                  childAspectRatio: isWide ? 1.3 : 0.95,
                ),
                itemCount: features.length,
                itemBuilder: (context, index) {
                  final feature = features[index];
                  return _HoverFeatureCard(
                    accentColor: accentColor,
                    iconPath: feature.iconPath,
                    title: feature.title,
                    description: feature.description,
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _DoctorCta extends StatelessWidget {
  final bool isWide;

  const _DoctorCta({required this.isWide});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: LandingScreen.maxContentWidth),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(
            AppTheme.screenHorizontalPadding,
            32,
            AppTheme.screenHorizontalPadding,
            48,
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
                              'Sind Sie Arzt?',
                              style: FigmaUi.rubik(
                                fontSize: 24,
                                fontWeight: FontWeight.w600,
                                color: AppTheme.textColor,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Melden Sie sich mit Ihrem Arztkonto an, um Termine und Videoanrufe zu verwalten.',
                              style: FigmaUi.rubik(
                                fontSize: 16,
                                fontWeight: FontWeight.w400,
                                color: AppTheme.textColorSecondary,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 24),
                      NeumorphicButton(
                        onPressed: () => context.go('/signup/doctor'),
                        padding: const EdgeInsets.symmetric(horizontal: 26, vertical: 18),
                        child: Text(
                          'Arzt registrieren',
                          style: FigmaUi.rubik(
                            fontSize: 18,
                            fontWeight: FontWeight.w500,
                            color: AppTheme.textColor,
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      NeumorphicButton(
                        isPrimary: true,
                        onPressed: () => context.go('/login/doctor'),
                        padding: const EdgeInsets.symmetric(horizontal: 34, vertical: 18),
                        child: Text(
                          'Arzt-Login',
                          style: FigmaUi.rubik(
                            fontSize: 18,
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
                        'Sind Sie Arzt?',
                        style: FigmaUi.rubik(
                          fontSize: 22,
                          fontWeight: FontWeight.w600,
                          color: AppTheme.textColor,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Melden Sie sich mit Ihrem Arztkonto an, um Termine und Videoanrufe zu verwalten.',
                        style: FigmaUi.rubik(
                          fontSize: 16,
                          fontWeight: FontWeight.w400,
                          color: AppTheme.textColorSecondary,
                        ),
                      ),
                      const SizedBox(height: 20),
                      NeumorphicButton(
                        onPressed: () => context.go('/signup/doctor'),
                        padding: const EdgeInsets.symmetric(vertical: 18),
                        child: Text(
                          'Arzt registrieren',
                          style: FigmaUi.rubik(
                            fontSize: 18,
                            fontWeight: FontWeight.w500,
                            color: AppTheme.textColor,
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                      NeumorphicButton(
                        isPrimary: true,
                        onPressed: () => context.go('/login/doctor'),
                        padding: const EdgeInsets.symmetric(vertical: 18),
                        child: Text(
                          'Arzt-Login',
                          style: FigmaUi.rubik(
                            fontSize: 18,
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

class _LocaleToggle extends StatelessWidget {
  const _LocaleToggle();

  @override
  Widget build(BuildContext context) {
    final locale = context.watch<LocaleProvider>();
    return DecoratedBox(
      decoration: BoxDecoration(
        color: AppTheme.cardColor,
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: AppTheme.navy.withValues(alpha: 0.12)),
        boxShadow: AppTheme.cardShadow,
      ),
      child: Padding(
        padding: const EdgeInsets.all(4),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            _LocaleChip(
              label: 'DE',
              selected: locale.isGerman,
              onTap: locale.setGerman,
            ),
            // Gap between the two tap zones so a slightly off-target tap
            // doesn't accidentally switch the language.
            const SizedBox(width: 4),
            _LocaleChip(
              label: 'EN',
              selected: !locale.isGerman,
              onTap: locale.setEnglish,
            ),
          ],
        ),
      ),
    );
  }
}

class _LocaleChip extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _LocaleChip({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: selected ? AppTheme.primaryBlue : Colors.transparent,
      borderRadius: BorderRadius.circular(999),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(999),
        hoverColor: selected
            ? Colors.white.withValues(alpha: 0.12)
            : AppTheme.primaryLight,
        child: Container(
          constraints: const BoxConstraints(
            minHeight: AppTheme.minTouchTarget,
            minWidth: AppTheme.minTouchTarget,
          ),
          alignment: Alignment.center,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          child: Text(
            label,
            style: FigmaUi.rubik(
              fontSize: 15,
              fontWeight: FontWeight.w600,
              color: selected ? Colors.white : AppTheme.textColorSecondary,
            ),
          ),
        ),
      ),
    );
  }
}

class _HoverFeatureCard extends StatefulWidget {
  final Color accentColor;
  final String iconPath;
  final String title;
  final String description;

  const _HoverFeatureCard({
    required this.accentColor,
    required this.iconPath,
    required this.title,
    required this.description,
  });

  @override
  State<_HoverFeatureCard> createState() => _HoverFeatureCardState();
}

class _HoverFeatureCardState extends State<_HoverFeatureCard> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        transform: Matrix4.translationValues(0, _hovered ? -4 : 0, 0),
        child: NeumorphicContainer(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: widget.accentColor.withValues(alpha: _hovered ? 0.35 : 0.25),
                  borderRadius: BorderRadius.circular(12),
                ),
                padding: const EdgeInsets.all(10),
                child: Image.asset(widget.iconPath, fit: BoxFit.contain),
              ),
              const SizedBox(height: 16),
              Text(
                widget.title,
                style: FigmaUi.rubik(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: AppTheme.textColor,
                ),
              ),
              const SizedBox(height: 8),
              Expanded(
                child: Text(
                  widget.description,
                  style: FigmaUi.bodyLight(fontSize: 16),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _LandingFooter extends StatelessWidget {
  const _LandingFooter();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      color: AppTheme.navy,
      padding: const EdgeInsets.symmetric(vertical: 32, horizontal: AppTheme.screenHorizontalPadding),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: LandingScreen.maxContentWidth),
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
                  fontSize: 15,
                  fontWeight: FontWeight.w400,
                  color: Colors.white70,
                ),
              ),
              const SizedBox(height: 4),
              Wrap(
                alignment: WrapAlignment.center,
                crossAxisAlignment: WrapCrossAlignment.center,
                children: [
                  _FooterLink(label: 'Impressum', legalPageType: 'IMPRESSUM'),
                  _FooterLinkDivider(),
                  _FooterLink(label: 'Datenschutz', legalPageType: 'PRIVACY_POLICY'),
                  _FooterLinkDivider(),
                  _FooterLink(label: 'AGB', legalPageType: 'TERMS_CONDITIONS'),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Tappable footer legal link — real navigation, a real tap target, and
/// enough contrast on the navy background to still read as clickable text
/// (the previous plain `Text` was neither tappable nor a strong contrast).
class _FooterLink extends StatelessWidget {
  final String label;
  final String legalPageType;

  const _FooterLink({required this.label, required this.legalPageType});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () => context.push('/legal/$legalPageType'),
        borderRadius: BorderRadius.circular(8),
        child: Container(
          constraints: const BoxConstraints(minHeight: AppTheme.minTouchTarget),
          alignment: Alignment.center,
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 12),
          child: Text(
            label,
            style: FigmaUi.rubik(
              fontSize: 15,
              fontWeight: FontWeight.w400,
              color: Colors.white,
              height: 1,
            ).copyWith(decoration: TextDecoration.underline, decorationColor: Colors.white70),
          ),
        ),
      ),
    );
  }
}

class _FooterLinkDivider extends StatelessWidget {
  const _FooterLinkDivider();

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.symmetric(horizontal: 2),
      child: Text('·', style: TextStyle(color: Colors.white54, fontSize: 15)),
    );
  }
}
