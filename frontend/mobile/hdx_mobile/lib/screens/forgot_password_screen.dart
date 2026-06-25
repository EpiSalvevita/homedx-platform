import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../config/app_theme.dart';
import '../services/auth_service.dart';
import '../utils/app_assets.dart';
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

  Widget _buildForm() {
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
              if (kIsWeb)
                Center(
                  child: Image.asset(AppAssets.logo, height: 32, fit: BoxFit.contain),
                ),
              if (kIsWeb) const SizedBox(height: 24),
              Text(
                'Passwort zurücksetzen',
                style: FigmaUi.rubik(fontSize: 24, fontWeight: FontWeight.w500, color: AppTheme.textColor),
              ),
              const SizedBox(height: 8),
              Text(
                'Geben Sie Ihre E-Mail-Adresse ein. Wir senden Ihnen einen Link zum Zurücksetzen Ihres Passworts.',
                style: FigmaUi.rubik(fontSize: 18, fontWeight: FontWeight.w400, color: AppTheme.primaryBlue),
              ),
              const SizedBox(height: 32),
              if (_successMessage != null) ...[
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppTheme.successColor.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppTheme.successColor.withValues(alpha: 0.35)),
                  ),
                  child: Text(
                    _successMessage!,
                    style: FigmaUi.rubik(fontSize: 15, fontWeight: FontWeight.w400, color: AppTheme.textColor),
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
                  label: 'E-mail',
                  hint: 'email@example.com',
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
                const SizedBox(height: 24),
                Center(
                  child: GestureDetector(
                    onTap: () => context.go(_loginRoute),
                    child: Text(
                      'Zurück zur Anmeldung',
                      style: FigmaUi.rubik(fontSize: 16, fontWeight: FontWeight.w500, color: AppTheme.primaryBlue),
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

  @override
  Widget build(BuildContext context) {
    if (kIsWeb) {
      return Scaffold(
        backgroundColor: AppTheme.surface,
        body: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 440),
              child: Material(
                elevation: 0,
                color: AppTheme.background,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                  side: BorderSide(color: AppTheme.navy.withValues(alpha: 0.08)),
                ),
                child: Form(key: _formKey, child: _buildForm()),
              ),
            ),
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: AppTheme.background,
      body: SafeArea(
        top: false,
        child: SingleChildScrollView(
          child: Form(key: _formKey, child: _buildForm()),
        ),
      ),
    );
  }
}
