import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../config/app_theme.dart';
import '../utils/app_assets.dart';
import 'figma_ui.dart';

enum AuthBrandPanelVariant {
  login,
  signup,
  confirmation,
  forgotPassword,
  resetPassword,
}

ButtonStyle authLinkButtonStyle({
  Color? foregroundColor,
  EdgeInsetsGeometry? padding,
}) {
  return TextButton.styleFrom(
    minimumSize: const Size(0, AppTheme.largeTouchTarget),
    padding: padding ?? const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
    foregroundColor: foregroundColor ?? AppTheme.primaryBlue,
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

/// Left gradient panel for wide web login/signup layouts.
class AuthBrandPanel extends StatelessWidget {
  final bool isDoctor;
  final AuthBrandPanelVariant variant;

  const AuthBrandPanel({
    super.key,
    required this.isDoctor,
    required this.variant,
  });

  @override
  Widget build(BuildContext context) {
    final isSignup = variant == AuthBrandPanelVariant.signup;
    final isConfirmation = variant == AuthBrandPanelVariant.confirmation;
    final isForgotPassword = variant == AuthBrandPanelVariant.forgotPassword;
    final isResetPassword = variant == AuthBrandPanelVariant.resetPassword;

    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppTheme.navy,
            AppTheme.primaryBlue,
            AppTheme.accentBlue.withValues(alpha: 0.85),
          ],
        ),
      ),
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(48),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 420),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                GestureDetector(
                  onTap: () => context.go('/'),
                  child: Image.asset(
                    AppAssets.logo,
                    height: 36,
                    fit: BoxFit.contain,
                    color: Colors.white,
                    colorBlendMode: BlendMode.srcIn,
                  ),
                ),
                const SizedBox(height: 28),
                if (isDoctor) ...[
                  Text(
                    isResetPassword
                        ? 'Neues Passwort'
                        : isForgotPassword
                            ? 'Passwort zurücksetzen'
                            : isConfirmation
                                ? 'Praxis angelegt'
                                : isSignup
                                    ? 'Praxis registrieren'
                                    : 'Portal für Ärzte',
                    style: FigmaUi.rubik(
                      fontSize: 32,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                      height: 1.2,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    isResetPassword
                        ? 'Wählen Sie ein neues Passwort für Ihr Arztkonto.'
                        : isForgotPassword
                            ? 'Geben Sie die E-Mail Ihres Arztkontos ein — wir senden Ihnen einen Link.'
                            : isConfirmation
                                ? 'Bestätigen Sie Ihre E-Mail-Adresse, um Ihr Arztkonto zu aktivieren.'
                                : isSignup
                                    ? 'Termine verwalten und Video-Konsultationen mit Patienten durchführen.'
                                    : 'Verwalten Sie Termine, Verfügbarkeit und Video-Konsultationen im Browser.',
                    style: FigmaUi.rubik(
                      fontSize: 18,
                      fontWeight: FontWeight.w400,
                      color: Colors.white.withValues(alpha: 0.9),
                      height: 1.5,
                    ),
                  ),
                ] else
                  Text(
                    isResetPassword
                        ? 'Wählen Sie ein neues Passwort und melden Sie sich danach wieder an.'
                        : isForgotPassword
                            ? 'Wir senden Ihnen einen Link per E-Mail, mit dem Sie Ihr Passwort zurücksetzen können.'
                            : isConfirmation
                                ? 'Fast geschafft — bestätigen Sie Ihre E-Mail und schon können Sie loslegen.'
                                : isSignup
                                    ? 'Testen Sie zu Hause, buchen Sie einen Arzt und erhalten Sie Ihre Ergebnisse online.'
                                    : 'Schnelltests, Arzttermine und Ergebnisse — alles an einem Ort.',
                    style: FigmaUi.rubik(
                      fontSize: 24,
                      fontWeight: FontWeight.w500,
                      color: Colors.white,
                      height: 1.35,
                    ),
                  ),
                const SizedBox(height: 32),
                Image.asset(
                  isDoctor ? AppAssets.loginDoctor : AppAssets.iconHomeHeart,
                  height: isDoctor ? 160 : 72,
                  fit: BoxFit.contain,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
