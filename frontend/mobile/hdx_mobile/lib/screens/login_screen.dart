import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../config/app_theme.dart';
import '../config/auth_routes.dart';
import '../providers/auth_provider.dart';
import '../utils/app_assets.dart';
import '../utils/login_errors.dart';
import '../widgets/auth_ui.dart';
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

  Widget _buildForm({required bool isWideWeb}) {
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
                widget.isDoctor ? 'Arzt-Login' : 'In Ihr Konto einloggen',
                style: FigmaUi.rubik(fontSize: 26, fontWeight: FontWeight.w600, color: AppTheme.textColor),
              ),
              const SizedBox(height: 10),
              Text(
                widget.isDoctor
                    ? 'Melden Sie sich mit Ihrem Arztkonto an.'
                    : 'Geben Sie Ihre E-Mail-Adresse und Ihr Passwort ein.',
                style: FigmaUi.bodyLight(fontSize: 18, color: AppTheme.primaryBlue),
              ),
              const SizedBox(height: 32),
              NeumorphicInsetField(
                controller: _emailController,
                label: 'E-Mail',
                hint: 'name@beispiel.de',
                prefixIcon: Icons.mail_outline,
                fontSize: 17,
                labelFontSize: 15,
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
                fontSize: 17,
                labelFontSize: 15,
                obscureText: _obscurePassword,
                textInputAction: TextInputAction.done,
                onFieldSubmitted: _submitLogin,
                validator: (v) {
                  if (v == null || v.isEmpty) return 'Bitte Passwort eingeben';
                  return null;
                },
                suffix: IconButton(
                  tooltip: _obscurePassword ? 'Passwort anzeigen' : 'Passwort verbergen',
                  style: IconButton.styleFrom(
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    minimumSize: const Size(48, 48),
                    padding: EdgeInsets.zero,
                  ),
                  icon: Icon(
                    _obscurePassword ? Icons.visibility_outlined : Icons.visibility_off_outlined,
                    color: AppTheme.textColorSecondary,
                    size: 24,
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
              const SizedBox(height: 20),
              Center(
                child: TextButton(
                  onPressed: () => context.go(widget.isDoctor ? '/signup/doctor' : '/signup'),
                  style: authLinkButtonStyle(foregroundColor: AppTheme.textColor),
                  child: Text.rich(
                    TextSpan(
                      text: 'Noch kein Konto? ',
                      style: FigmaUi.rubik(fontSize: 17, fontWeight: FontWeight.w400, color: AppTheme.textColor),
                      children: [
                        TextSpan(
                          text: 'Registrieren',
                          style: FigmaUi.rubik(fontSize: 17, fontWeight: FontWeight.w600, color: AppTheme.primaryBlue),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              Center(
                child: TextButton(
                  onPressed: () => context.go(_forgotPasswordRoute),
                  style: authLinkButtonStyle(),
                  child: Text(
                    'Passwort vergessen?',
                    style: FigmaUi.rubik(fontSize: 17, fontWeight: FontWeight.w500, color: AppTheme.primaryBlue),
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
        body: LayoutBuilder(
          builder: (context, constraints) {
            final isWide = constraints.maxWidth >= 960;
            final formCard = Material(
              elevation: 0,
              color: AppTheme.background,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
                side: BorderSide(color: AppTheme.navy.withValues(alpha: 0.08)),
              ),
              child: Form(key: _formKey, child: _buildForm(isWideWeb: isWide)),
            );

            if (isWide) {
              return Row(
                children: [
                  Expanded(child: AuthBrandPanel(isDoctor: widget.isDoctor, variant: AuthBrandPanelVariant.login)),
                  Expanded(
                    child: Center(
                      child: SingleChildScrollView(
                        padding: const EdgeInsets.all(48),
                        child: ConstrainedBox(
                          constraints: const BoxConstraints(maxWidth: 440),
                          child: formCard,
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
                  child: formCard,
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
          child: Form(key: _formKey, child: _buildForm(isWideWeb: false)),
        ),
      ),
    );
  }
}
