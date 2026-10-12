import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../l10n/l10n_ext.dart';
import '../config/app_theme.dart';
import '../services/auth_service.dart';
import '../utils/app_assets.dart';
import '../widgets/auth_ui.dart';
import '../widgets/figma_ui.dart';

/// Shown after successful signup — prompts the user to verify their email.
class RegistrationConfirmationScreen extends StatefulWidget {
  final String email;
  final bool isDoctor;

  const RegistrationConfirmationScreen({
    super.key,
    required this.email,
    this.isDoctor = false,
  });

  @override
  State<RegistrationConfirmationScreen> createState() =>
      _RegistrationConfirmationScreenState();
}

class _RegistrationConfirmationScreenState
    extends State<RegistrationConfirmationScreen> {
  bool _isResending = false;
  String? _resendMessage;
  String? _resendError;

  String get _loginRoute => widget.isDoctor ? '/login/doctor' : '/login';

  Future<void> _resendVerification() async {
    final email = widget.email.trim();
    if (email.isEmpty || _isResending) return;

    setState(() {
      _isResending = true;
      _resendMessage = null;
      _resendError = null;
    });

    final result = await context.read<AuthService>().resendVerificationEmail(email);
    if (!mounted) return;

    setState(() {
      _isResending = false;
      if (result.success) {
        _resendMessage = result.message;
      } else {
        _resendError = result.error;
      }
    });
  }

  Widget _buildContent(BuildContext context, {required bool isWideWeb}) {
    final showWebLogo = kIsWeb && !isWideWeb;
    final displayEmail = widget.email.trim().isEmpty ? context.l10n.authYourEmailAddress : widget.email.trim();
    final canResend = widget.email.trim().isNotEmpty;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (!kIsWeb) LoginHeroBanner(isDoctor: widget.isDoctor),
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
                context.l10n.authRegistrationSuccessTitle,
                textAlign: TextAlign.center,
                style: FigmaUi.rubik(
                  fontSize: 26,
                  fontWeight: FontWeight.w600,
                  color: AppTheme.textColor,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                widget.isDoctor
                    ? context.l10n.authConfirmationDoctorBody
                    : context.l10n.authConfirmationBody,
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
                      context.l10n.authNextStep,
                      style: FigmaUi.rubik(
                        fontSize: 17,
                        fontWeight: FontWeight.w600,
                        color: AppTheme.textColor,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      context.l10n.authCheckInboxIntro,
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
                      context.l10n.authOpenLinkHint,
                      style: FigmaUi.bodyLight(fontSize: 17),
                    ),
                  ],
                ),
              ),
              if (_resendMessage != null) ...[
                const SizedBox(height: 16),
                Text(
                  _resendMessage!,
                  style: FigmaUi.bodyLight(fontSize: 16, color: AppTheme.textColorSecondary),
                ),
              ],
              if (_resendError != null) ...[
                const SizedBox(height: 16),
                NeumorphicFieldError(text: _resendError),
              ],
              const SizedBox(height: 28),
              NeumorphicPillButton(
                label: context.l10n.authGoToSignIn,
                leadingIcon: Icons.login,
                onPressed: () => context.go(_loginRoute),
              ),
              if (canResend) ...[
                const SizedBox(height: 8),
                Center(
                  child: TextButton(
                    onPressed: _isResending ? null : _resendVerification,
                    style: authLinkButtonStyle(),
                    child: Text(
                      _isResending ? context.l10n.authSendingEmail : context.l10n.authResendEmail,
                      style: FigmaUi.rubik(
                        fontSize: 17,
                        fontWeight: FontWeight.w500,
                        color: AppTheme.primaryBlue,
                      ),
                    ),
                  ),
                ),
              ],
              const SizedBox(height: 8),
              Center(
                child: TextButton(
                  onPressed: () => context.go('/'),
                  style: authLinkButtonStyle(),
                  child: Text(
                    context.l10n.authGoToHomepage,
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
                      isDoctor: widget.isDoctor,
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
