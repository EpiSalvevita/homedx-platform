import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../config/app_theme.dart';
import '../utils/app_assets.dart';
import '../widgets/auth_ui.dart';
import '../widgets/figma_ui.dart';

/// Shown after successful signup — prompts the user to verify their email.
class RegistrationConfirmationScreen extends StatelessWidget {
  final String email;
  final bool isDoctor;

  const RegistrationConfirmationScreen({
    super.key,
    required this.email,
    this.isDoctor = false,
  });

  String get _loginRoute => isDoctor ? '/login/doctor' : '/login';

  Widget _buildContent(BuildContext context, {required bool isWideWeb}) {
    final showWebLogo = kIsWeb && !isWideWeb;
    final displayEmail = email.trim().isEmpty ? 'Ihre E-Mail-Adresse' : email.trim();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (!kIsWeb) LoginHeroBanner(isDoctor: isDoctor),
        Padding(
          padding: EdgeInsets.fromLTRB(
            kIsWeb ? 32 : AppTheme.screenHorizontalPadding,
            kIsWeb ? 32 : 32,
            kIsWeb ? 32 : AppTheme.screenHorizontalPadding,
            24,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (showWebLogo) ...[
                Center(
                  child: GestureDetector(
                    onTap: () => context.go('/'),
                    child: Image.asset(AppAssets.logo, height: 36, fit: BoxFit.contain),
                  ),
                ),
                const SizedBox(height: 24),
              ],
              Center(
                child: Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    color: AppTheme.successColor.withValues(alpha: 0.2),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.mark_email_read_outlined,
                    size: 40,
                    color: AppTheme.primaryBlue,
                  ),
                ),
              ),
              const SizedBox(height: 24),
              Text(
                'Registrierung erfolgreich',
                textAlign: TextAlign.center,
                style: FigmaUi.rubik(
                  fontSize: 26,
                  fontWeight: FontWeight.w600,
                  color: AppTheme.textColor,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                isDoctor
                    ? 'Ihr Arztkonto wurde angelegt. Bitte bestätigen Sie Ihre E-Mail-Adresse, um fortzufahren.'
                    : 'Ihr Konto wurde angelegt. Bitte bestätigen Sie Ihre E-Mail-Adresse, um fortzufahren.',
                textAlign: TextAlign.center,
                style: FigmaUi.bodyLight(fontSize: 18, color: AppTheme.textColorSecondary),
              ),
              const SizedBox(height: 24),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: AppTheme.successColor.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: AppTheme.successColor.withValues(alpha: 0.35)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Nächster Schritt',
                      style: FigmaUi.rubik(
                        fontSize: 17,
                        fontWeight: FontWeight.w600,
                        color: AppTheme.textColor,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      'Prüfen Sie Ihr Postfach unter dieser Adresse und aktivieren Sie Ihr Konto über den Bestätigungslink:',
                      style: FigmaUi.bodyLight(fontSize: 17),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      displayEmail,
                      style: FigmaUi.rubik(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: AppTheme.primaryBlue,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'Öffnen Sie den Link in der E-Mail, um Ihr Konto zu aktivieren. Prüfen Sie auch Ihren Spam-Ordner.',
                      style: FigmaUi.bodyLight(fontSize: 17),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 28),
              NeumorphicPillButton(
                label: 'Zur Anmeldung',
                leadingIcon: Icons.login,
                onPressed: () => context.go(_loginRoute),
              ),
              const SizedBox(height: 8),
              Center(
                child: TextButton(
                  onPressed: () => context.go('/'),
                  style: authLinkButtonStyle(),
                  child: Text(
                    'Zur Startseite',
                    style: FigmaUi.rubik(
                      fontSize: 17,
                      fontWeight: FontWeight.w500,
                      color: AppTheme.primaryBlue,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildCard(BuildContext context, {required bool isWideWeb}) {
    return Material(
      elevation: 0,
      color: AppTheme.background,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: AppTheme.navy.withValues(alpha: 0.08)),
      ),
      child: _buildContent(context, isWideWeb: isWideWeb),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (kIsWeb) {
      return Scaffold(
        backgroundColor: AppTheme.surface,
        body: LayoutBuilder(
          builder: (context, constraints) {
            final isWide = constraints.maxWidth >= 960;
            final card = _buildCard(context, isWideWeb: isWide);

            if (isWide) {
              return Row(
                children: [
                  Expanded(
                    child: AuthBrandPanel(
                      isDoctor: isDoctor,
                      variant: AuthBrandPanelVariant.confirmation,
                    ),
                  ),
                  Expanded(
                    child: Center(
                      child: SingleChildScrollView(
                        padding: const EdgeInsets.all(48),
                        child: ConstrainedBox(
                          constraints: const BoxConstraints(maxWidth: 480),
                          child: card,
                        ),
                      ),
                    ),
                  ),
                ],
              );
            }

            return Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 480),
                  child: _buildCard(context, isWideWeb: false),
                ),
              ),
            );
          },
        ),
      );
    }

    return Scaffold(
      backgroundColor: AppTheme.background,
      body: SafeArea(
        top: false,
        child: SingleChildScrollView(child: _buildContent(context, isWideWeb: false)),
      ),
    );
  }
}
