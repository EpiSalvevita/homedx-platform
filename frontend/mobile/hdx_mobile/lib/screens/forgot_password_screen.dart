import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../config/app_theme.dart';
import '../services/auth_service.dart';
import '../utils/app_assets.dart';
import '../widgets/auth_ui.dart';
import '../widgets/figma_ui.dart';

class ForgotPasswordScreen extends StatefulWidget {
  final bool isDoctor;

  const ForgotPasswordScreen({super.key, this.isDoctor = false});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  bool _isLoading = false;
  String? _error;
  String? _successMessage;

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  Future<void> _handleSubmit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
      _error = null;
      _successMessage = null;
    });

    final authService = context.read<AuthService>();
    final result = await authService.requestPasswordReset(_emailController.text.trim());

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

  String get _loginRoute => widget.isDoctor ? '/login/doctor' : '/login';

  Widget _buildForm(BuildContext context, {required bool isWideWeb}) {
    final showWebLogo = kIsWeb && !isWideWeb;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (!kIsWeb) const LoginHeroBanner(),
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
                'Passwort zurücksetzen',
                style: FigmaUi.rubik(fontSize: 26, fontWeight: FontWeight.w600, color: AppTheme.textColor),
              ),
              const SizedBox(height: 10),
              Text(
                'Geben Sie Ihre E-Mail-Adresse ein. Wir senden Ihnen einen Link zum Zurücksetzen.',
                style: FigmaUi.bodyLight(fontSize: 18, color: AppTheme.primaryBlue),
              ),
              const SizedBox(height: 32),
              if (_successMessage != null) ...[
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: AppTheme.successColor.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: AppTheme.successColor.withValues(alpha: 0.35)),
                  ),
                  child: Text(
                    _successMessage!,
                    style: FigmaUi.bodyLight(fontSize: 17, color: AppTheme.textColor),
                  ),
                ),
                const SizedBox(height: 24),
                NeumorphicPillButton(
                  label: 'Zurück zur Anmeldung',
                  onPressed: () => context.go(_loginRoute),
                ),
              ] else ...[
                NeumorphicInsetField(
                  controller: _emailController,
                  label: 'E-Mail',
                  hint: 'name@beispiel.de',
                  prefixIcon: Icons.mail_outline,
                  keyboardType: TextInputType.emailAddress,
                  validator: (v) {
                    if (v == null || v.isEmpty) return 'Bitte E-Mail eingeben';
                    if (!v.contains('@')) return 'Ungültige E-Mail';
                    return null;
                  },
                ),
                if (_error != null) ...[
                  const SizedBox(height: 12),
                  NeumorphicFieldError(text: _error),
                ],
                const SizedBox(height: 32),
                NeumorphicPillButton(
                  label: 'Link senden',
                  loading: _isLoading,
                  onPressed: _isLoading ? null : _handleSubmit,
                ),
                const SizedBox(height: 12),
                Center(
                  child: TextButton(
                    onPressed: () => context.go(_loginRoute),
                    style: authLinkButtonStyle(),
                    child: Text(
                      'Zurück zur Anmeldung',
                      style: FigmaUi.rubik(fontSize: 17, fontWeight: FontWeight.w500, color: AppTheme.primaryBlue),
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

  Widget _buildFormCard(BuildContext context, {required bool isWideWeb}) {
    return Material(
      elevation: 0,
      color: AppTheme.background,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: AppTheme.navy.withValues(alpha: 0.08)),
      ),
      child: Form(key: _formKey, child: _buildForm(context, isWideWeb: isWideWeb)),
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
            final card = _buildFormCard(context, isWideWeb: isWide);

            if (isWide) {
              return Row(
                children: [
                  Expanded(
                    child: AuthBrandPanel(
                      isDoctor: widget.isDoctor,
                      variant: AuthBrandPanelVariant.forgotPassword,
                    ),
                  ),
                  Expanded(
                    child: Center(
                      child: SingleChildScrollView(
                        padding: const EdgeInsets.all(48),
                        child: ConstrainedBox(
                          constraints: const BoxConstraints(maxWidth: 440),
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
                  constraints: const BoxConstraints(maxWidth: 440),
                  child: card,
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
        child: SingleChildScrollView(
          child: Form(key: _formKey, child: _buildForm(context, isWideWeb: false)),
        ),
      ),
    );
  }
}
