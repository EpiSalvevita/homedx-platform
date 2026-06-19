import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../config/app_theme.dart';
import '../config/auth_routes.dart';
import '../providers/auth_provider.dart';
import '../widgets/figma_ui.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _handleLogin() async {
    if (!_formKey.currentState!.validate()) return;

    final authProvider = context.read<AuthProvider>();
    final success = await authProvider.login(
      _emailController.text.trim(),
      _passwordController.text,
    );

    if (success && mounted) {
      context.go(homeRouteForRole(authProvider.userRole));
    } else if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(authProvider.error ?? 'Anmeldung fehlgeschlagen'),
          backgroundColor: AppTheme.errorColor,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      body: SafeArea(
        top: false,
        child: SingleChildScrollView(
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const LoginHeroBanner(),
                Padding(
                  padding: const EdgeInsets.fromLTRB(AppTheme.screenHorizontalPadding, 32, AppTheme.screenHorizontalPadding, 24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'In Ihr Konto einloggen',
                        style: FigmaUi.rubik(fontSize: 24, fontWeight: FontWeight.w500, color: AppTheme.textColor),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Geben Sie Ihre Anmeldedaten ein.',
                        style: FigmaUi.rubik(fontSize: 18, fontWeight: FontWeight.w400, color: AppTheme.primaryBlue),
                      ),
                      const SizedBox(height: 32),
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
                      const SizedBox(height: 24),
                      NeumorphicInsetField(
                        controller: _passwordController,
                        label: 'Passwort',
                        prefixIcon: Icons.lock_outline,
                        obscureText: _obscurePassword,
                        validator: (v) {
                          if (v == null || v.isEmpty) return 'Bitte Passwort eingeben';
                          if (v.length < 6) return 'Mindestens 6 Zeichen';
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
                          onTap: () => context.go('/signup'),
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
                    ],
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
