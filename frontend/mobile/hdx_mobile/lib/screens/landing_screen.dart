import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../config/app_theme.dart';
import '../providers/locale_provider.dart';
import '../utils/app_assets.dart';
import '../utils/constants.dart';
import '../widgets/figma_ui.dart';
import '../widgets/neumorphic.dart';

class LandingScreen extends StatelessWidget {
  const LandingScreen({super.key});

  static const double _maxContentWidth = 1100;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final isWide = constraints.maxWidth >= 768;
            return SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _LandingNav(isWide: isWide),
                  _HeroSection(isWide: isWide),
                  _FeatureSection(
                    title: 'Für Patienten',
                    subtitle: 'Gesundheitstests und Online-Versorgung von zu Hause.',
                    features: const [
                      _FeatureItem(
                        iconPath: AppAssets.iconHomeHeart,
                        title: 'Cube Schnelltests',
                        description: 'Schnelle Diagnostik mit dem HomeDX Cube-Gerät.',
                      ),
                      _FeatureItem(
                        iconPath: AppAssets.iconHomeCalendar,
                        title: 'Termin buchen',
                        description: 'Online-Konsultationen mit Fachärzten vereinbaren.',
                      ),
                      _FeatureItem(
                        iconPath: AppAssets.iconHeartbeat,
                        title: 'Video-Konsultation',
                        description: 'Sicher per Video mit Ihrem Arzt sprechen.',
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

  @override
  Widget build(BuildContext context) {
    final isGerman = context.watch<LocaleProvider>().isGerman;
    final aboutLabel = isGerman ? 'Über HomeDX' : 'About HomeDX';

    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: LandingScreen._maxContentWidth),
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppTheme.screenHorizontalPadding,
            vertical: 16,
          ),
          child: Row(
            children: [
              Image.asset(
                AppAssets.logo,
                width: AppAssets.logoHeaderWidth,
                height: AppAssets.logoHeaderHeight,
                fit: BoxFit.contain,
              ),
              const Spacer(),
              if (isWide) ...[
                TextButton(
                  onPressed: () => context.go('/about'),
                  child: Text(
                    aboutLabel,
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
                    'Anmelden',
                    style: FigmaUi.rubik(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      color: AppTheme.primaryBlue,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
              ],
              NeumorphicButton(
                isPrimary: true,
                onPressed: () => context.go('/signup'),
                padding: EdgeInsets.symmetric(
                  horizontal: isWide ? 28 : 20,
                  vertical: 14,
                ),
                child: Text(
                  isWide ? 'Registrieren' : 'Start',
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
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
              child: Text(
                'Jetzt starten',
                style: FigmaUi.rubik(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: Colors.white,
                ),
              ),
            ),
            NeumorphicButton(
              onPressed: () => context.go('/login/doctor'),
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
              child: Text(
                'Für Ärzte',
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
          constraints: const BoxConstraints(maxWidth: LandingScreen._maxContentWidth),
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
        constraints: const BoxConstraints(maxWidth: LandingScreen._maxContentWidth),
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
                  return NeumorphicContainer(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          width: 48,
                          height: 48,
                          decoration: BoxDecoration(
                            color: accentColor.withValues(alpha: 0.25),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          padding: const EdgeInsets.all(10),
                          child: Image.asset(feature.iconPath, fit: BoxFit.contain),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          feature.title,
                          style: FigmaUi.rubik(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: AppTheme.textColor,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Expanded(
                          child: Text(
                            feature.description,
                            style: FigmaUi.bodyLight(fontSize: 14),
                          ),
                        ),
                      ],
                    ),
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
        constraints: const BoxConstraints(maxWidth: LandingScreen._maxContentWidth),
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
                        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                        child: Text(
                          'Arzt registrieren',
                          style: FigmaUi.rubik(
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                            color: AppTheme.textColor,
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      NeumorphicButton(
                        isPrimary: true,
                        onPressed: () => context.go('/login/doctor'),
                        padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                        child: Text(
                          'Arzt-Login',
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
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        child: Text(
                          'Arzt registrieren',
                          style: FigmaUi.rubik(
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                            color: AppTheme.textColor,
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                      NeumorphicButton(
                        isPrimary: true,
                        onPressed: () => context.go('/login/doctor'),
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        child: Text(
                          'Arzt-Login',
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
          constraints: const BoxConstraints(maxWidth: LandingScreen._maxContentWidth),
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
                'Impressum · Datenschutz · AGB',
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
