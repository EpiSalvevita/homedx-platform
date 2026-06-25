import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../config/app_theme.dart';
import '../services/auth_service.dart';
import '../utils/app_assets.dart';
import '../utils/password_validation.dart';
import '../widgets/figma_ui.dart';

class ResetPasswordScreen extends StatefulWidget {
  final String? token;
  final bool isDoctor;

  const ResetPasswordScreen({
    super.key,
    this.token,
    this.isDoctor = false,
  });

  @override
  State<ResetPasswordScreen> createState() => _ResetPasswordScreenState();
}

class _ResetPasswordScreenState extends State<ResetPasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
  bool _isLoading = false;
  bool _autovalidate = false;
  String? _error;
  String? _successMessage;

  @override
  void initState() {
    super.initState();
    _passwordController.addListener(() {
      setState(() {});
      if (_autovalidate) _formKey.currentState?.validate();
    });
  }

  @override
  void dispose() {
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  String get _loginRoute => widget.isDoctor ? '/login/doctor' : '/login';
  String get _forgotRoute => widget.isDoctor ? '/forgot-password/doctor' : '/forgot-password';

  Future<void> _handleSubmit() async {
    setState(() => _autovalidate = true);
    if (!_formKey.currentState!.validate()) return;

    final token = widget.token?.trim();
    if (token == null || token.isEmpty) {
      setState(() => _error = 'Der Link zum Zurücksetzen ist ungültig. Bitte fordern Sie einen neuen Link an.');
      return;
    }

    setState(() {
      _isLoading = true;
      _error = null;
      _successMessage = null;
    });

    final authService = context.read<AuthService>();
    final result = await authService.resetPassword(
      token: token,
      password: _passwordController.text,
    );

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

  Widget _buildForm() {
    final tokenMissing = widget.token == null || widget.token!.trim().isEmpty;

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
                'Neues Passwort',
                style: FigmaUi.rubik(fontSize: 24, fontWeight: FontWeight.w500, color: AppTheme.textColor),
              ),
              const SizedBox(height: 8),
              Text(
                'Legen Sie ein neues Passwort für Ihr Konto fest.',
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
                  label: 'Zur Anmeldung',
                  onPressed: () => context.go(_loginRoute),
                ),
              ] else if (tokenMissing) ...[
                NeumorphicFieldError(
                  text: 'Der Link zum Zurücksetzen ist ungültig oder abgelaufen. Bitte fordern Sie einen neuen Link an.',
                ),
                const SizedBox(height: 24),
                NeumorphicPillButton(
                  label: 'Neuen Link anfordern',
                  onPressed: () => context.go(_forgotRoute),
                ),
              ] else ...[
                PasswordRulesHint(password: _passwordController.text),
                const SizedBox(height: 16),
                NeumorphicInsetField(
                  controller: _passwordController,
                  label: 'Neues Passwort',
                  prefixIcon: Icons.lock_outline,
                  obscureText: _obscurePassword,
                  validator: (v) => PasswordPolicy.validate(v),
                  suffix: IconButton(
                    style: IconButton.styleFrom(
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      minimumSize: const Size(40, 40),
                      padding: EdgeInsets.zero,
                    ),
                    icon: Icon(
                      _obscurePassword ? Icons.visibility_outlined : Icons.visibility_off_outlined,
                      color: AppTheme.textColorSecondary,
                      size: 20,
                    ),
                    onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                  ),
                ),
                const SizedBox(height: 24),
                NeumorphicInsetField(
                  controller: _confirmPasswordController,
                  label: 'Passwort bestätigen',
                  prefixIcon: Icons.lock_outline,
                  obscureText: _obscureConfirmPassword,
                  validator: (v) {
                    if (v == null || v.isEmpty) return 'Bitte Passwort bestätigen';
                    if (v != _passwordController.text) return 'Passwörter stimmen nicht überein';
                    return null;
                  },
                  suffix: IconButton(
                    style: IconButton.styleFrom(
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      minimumSize: const Size(40, 40),
                      padding: EdgeInsets.zero,
                    ),
                    icon: Icon(
                      _obscureConfirmPassword ? Icons.visibility_outlined : Icons.visibility_off_outlined,
                      color: AppTheme.textColorSecondary,
                      size: 20,
                    ),
                    onPressed: () => setState(() => _obscureConfirmPassword = !_obscureConfirmPassword),
                  ),
                ),
                if (_error != null) ...[
                  const SizedBox(height: 12),
                  NeumorphicFieldError(text: _error),
                ],
                const SizedBox(height: 32),
                NeumorphicPillButton(
                  label: 'Passwort speichern',
                  loading: _isLoading,
                  onPressed: _isLoading ? null : _handleSubmit,
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
