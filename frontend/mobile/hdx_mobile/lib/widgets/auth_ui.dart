import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../l10n/l10n_ext.dart';
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
                    AppAssets.logoOnDark,
                    height: 36,
                    fit: BoxFit.contain,
                  ),
                ),
                const SizedBox(height: 28),
                if (isDoctor) ...[
                  Text(
                    isResetPassword
                        ? context.l10n.authNewPassword
                        : isForgotPassword
                            ? context.l10n.authResetPasswordTitle
                            : isConfirmation
                                ? context.l10n.authBrandConfirmationTitle
                                : isSignup
                                    ? context.l10n.authBrandSignupTitle
                                    : context.l10n.authBrandDoctorPortalTitle,
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
                        ? context.l10n.authBrandResetDoctorSubtitle
                        : isForgotPassword
                            ? context.l10n.authBrandForgotDoctorSubtitle
                            : isConfirmation
                                ? context.l10n.authBrandConfirmationDoctorSubtitle
                                : isSignup
                                    ? context.l10n.authBrandSignupDoctorSubtitle
                                    : context.l10n.authBrandDoctorLoginSubtitle,
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
                        ? context.l10n.authBrandResetSubtitle
                        : isForgotPassword
                            ? context.l10n.authBrandForgotSubtitle
                            : isConfirmation
                                ? context.l10n.authBrandConfirmationSubtitle
                                : isSignup
                                    ? context.l10n.authBrandSignupSubtitle
                                    : context.l10n.authBrandLoginSubtitle,
                    style: FigmaUi.rubik(
                      fontSize: 24,
                      fontWeight: FontWeight.w500,
                      color: Colors.white,
                      height: 1.35,
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
