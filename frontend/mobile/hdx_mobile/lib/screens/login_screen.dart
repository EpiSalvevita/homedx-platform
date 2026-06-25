import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../config/app_theme.dart';
import '../config/auth_routes.dart';
import '../providers/auth_provider.dart';
import '../utils/app_assets.dart';
import '../utils/login_errors.dart';
import '../widgets/figma_ui.dart';

class LoginScreen extends StatefulWidget {
  final bool isDoctor;

  const LoginScreen({super.key, this.isDoctor = false});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _passwordFocusNode = FocusNode();
  bool _obscurePassword = true;
  String? _loginError;

  @override
  void initState() {
    super.initState();
    _emailController.addListener(_clearLoginError);
    _passwordController.addListener(_clearLoginError);
  }

  void _clearLoginError() {
    if (_loginError != null) {
      setState(() => _loginError = null);
    }
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _passwordFocusNode.dispose();
    super.dispose();
  }

  void _submitLogin() {
    if (context.read<AuthProvider>().isLoading) return;
    _handleLogin();
  }

  Future<void> _handleLogin() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _loginError = null);

    final authProvider = context.read<AuthProvider>();
    final success = await authProvider.login(
      _emailController.text.trim(),
      _passwordController.text,
    );

    if (success && mounted) {
      context.go(homeRouteForRole(authProvider.userRole));
    } else if (mounted) {
      final error = localizeLoginError(authProvider.error ?? 'Anmeldung fehlgeschlagen');
      setState(() => _loginError = error);
    }
  }

  String get _forgotPasswordRoute =>
      widget.isDoctor ? '/forgot-password/doctor' : '/forgot-password';

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
                widget.isDoctor ? 'Arzt-Login' : 'In Ihr Konto einloggen',
                style: FigmaUi.rubik(fontSize: 24, fontWeight: FontWeight.w500, color: AppTheme.textColor),
              ),
              const SizedBox(height: 8),
              Text(
                widget.isDoctor
                    ? 'Melden Sie sich mit Ihrem Arztkonto an.'
                    : 'Geben Sie Ihre Anmeldedaten ein.',
                style: FigmaUi.rubik(fontSize: 18, fontWeight: FontWeight.w400, color: AppTheme.primaryBlue),
              ),
              const SizedBox(height: 32),
              NeumorphicInsetField(
                controller: _emailController,
                label: 'E-mail',
                hint: 'email@example.com',
                prefixIcon: Icons.mail_outline,
                keyboardType: TextInputType.emailAddress,
                textInputAction: TextInputAction.next,
                onFieldSubmitted: () => _passwordFocusNode.requestFocus(),
                validator: (v) {
                  if (v == null || v.isEmpty) return 'Bitte E-Mail eingeben';
                  if (!v.contains('@')) return 'Ungültige E-Mail';
                  return null;
                },
              ),
              const SizedBox(height: 24),
              NeumorphicInsetField(
                controller: _passwordController,
                focusNode: _passwordFocusNode,
                label: 'Passwort',
                prefixIcon: Icons.lock_outline,
                obscureText: _obscurePassword,
                textInputAction: TextInputAction.done,
                onFieldSubmitted: _submitLogin,
                validator: (v) {
                  if (v == null || v.isEmpty) return 'Bitte Passwort eingeben';
                  return null;
                },
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
              if (_loginError != null) ...[
                const SizedBox(height: 16),
                NeumorphicFieldError(text: _loginError),
              ],
              const SizedBox(height: 32),
              Consumer<AuthProvider>(
                builder: (context, auth, _) => NeumorphicPillButton(
                  label: 'Anmelden',
                  loading: auth.isLoading,
                  onPressed: auth.isLoading ? null : _handleLogin,
                ),
              ),
              const SizedBox(height: 24),
              Center(
                child: GestureDetector(
                  onTap: () => context.go(widget.isDoctor ? '/signup/doctor' : '/signup'),
                  child: Text.rich(
                    TextSpan(
                      text: 'Noch kein Konto? ',
                      style: FigmaUi.rubik(fontSize: 16, fontWeight: FontWeight.w300, color: AppTheme.textColor),
                      children: [
                        TextSpan(
                          text: 'Registrieren',
                          style: FigmaUi.rubik(fontSize: 16, fontWeight: FontWeight.w500, color: AppTheme.textColor),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Center(
                child: GestureDetector(
                  onTap: () => context.go(_forgotPasswordRoute),
                  child: Text(
                    'Passwort vergessen?',
                    style: FigmaUi.rubik(fontSize: 16, fontWeight: FontWeight.w500, color: AppTheme.primaryBlue),
                  ),
                ),
              ),
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
