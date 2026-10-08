import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../config/app_theme.dart';
import '../services/auth_service.dart';
import '../utils/app_assets.dart';
import '../widgets/auth_ui.dart';
import '../widgets/figma_ui.dart';

/// Opens from the signup confirmation email and activates the account.
class VerifyEmailScreen extends StatefulWidget {
  final String? token;
  final bool isDoctor;

  const VerifyEmailScreen({
    super.key,
    this.token,
    this.isDoctor = false,
  });

  @override
  State<VerifyEmailScreen> createState() => _VerifyEmailScreenState();
}

class _VerifyEmailScreenState extends State<VerifyEmailScreen> {
  bool _isLoading = false;
  bool _didStart = false;
  String? _error;
  String? _successMessage;

  String get _loginRoute => widget.isDoctor ? '/login/doctor' : '/login';
  String get _signupRoute => widget.isDoctor ? '/signup/doctor' : '/signup';

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_didStart) return;
    _didStart = true;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) _verify();
    });
  }

  Future<void> _verify() async {
    final token = widget.token?.trim();
    if (token == null || token.isEmpty) {
      setState(() {
        _error =
            'Der Bestätigungslink ist ungültig oder abgelaufen. Bitte fordern Sie eine neue E-Mail an.';
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _error = null;
      _successMessage = null;
    });

    final authService = context.read<AuthService>();
    final result = await authService.verifyEmail(token);

    if (!mounted) return;

    setState(() {
      _isLoading = false;
      if (result.success) {
        _successMessage = result.message;
      } else {
        _error = result.error;
      }
    });
  }

  Widget _buildContent(BuildContext context, {required bool isWideWeb}) {
    final showWebLogo = kIsWeb && !isWideWeb;

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
              Text(
                'E-Mail bestätigen',
                style: FigmaUi.rubik(
                  fontSize: 26,
                  fontWeight: FontWeight.w600,
                  color: AppTheme.textColor,
                ),
              ),
              const SizedBox(height: 12),
              if (_isLoading)
                Text(
                  'Ihr Konto wird aktiviert…',
                  style: FigmaUi.bodyLight(fontSize: 18, color: AppTheme.textColorSecondary),
                )
              else if (_successMessage != null)
                Text(
                  _successMessage!,
                  style: FigmaUi.bodyLight(fontSize: 18, color: AppTheme.textColorSecondary),
                )
              else
                Text(
                  'Der Bestätigungslink aus Ihrer E-Mail wird geprüft.',
                  style: FigmaUi.bodyLight(fontSize: 18, color: AppTheme.textColorSecondary),
                ),
              const SizedBox(height: 24),
              if (_isLoading)
                const Center(child: CircularProgressIndicator())
              else if (_successMessage != null) ...[
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: AppTheme.successColor.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: AppTheme.successColor.withValues(alpha: 0.35)),
                  ),
                  child: Text(
                    'Sie können sich jetzt anmelden.',
                    style: FigmaUi.bodyLight(fontSize: 17, color: AppTheme.textColor),
                  ),
                ),
                const SizedBox(height: 24),
                NeumorphicPillButton(
                  label: 'Zur Anmeldung',
                  leadingIcon: Icons.login,
                  onPressed: () => context.go(_loginRoute),
                ),
              ] else ...[
                if (_error != null) NeumorphicFieldError(text: _error),
                const SizedBox(height: 24),
                NeumorphicPillButton(
                  label: 'Erneut versuchen',
                  onPressed: _isLoading ? null : _verify,
                ),
                const SizedBox(height: 12),
                Center(
                  child: TextButton(
                    onPressed: () => context.go(_signupRoute),
                    style: authLinkButtonStyle(),
                    child: Text(
                      'Zurück zur Registrierung',
                      style: FigmaUi.rubik(
                        fontSize: 17,
                        fontWeight: FontWeight.w500,
                        color: AppTheme.primaryBlue,
                      ),
                    ),
                  ),
                ),
              ],
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
