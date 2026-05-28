import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../config/app_theme.dart';
import '../providers/auth_provider.dart';
import '../widgets/figma_ui.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final _formKey = GlobalKey<FormState>();
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _handleSignup() async {
    if (!_formKey.currentState!.validate()) return;

    final authProvider = context.read<AuthProvider>();
    final success = await authProvider.register(
      email: _emailController.text.trim(),
      password: _passwordController.text,
      firstName: _firstNameController.text.trim(),
      lastName: _lastNameController.text.trim(),
    );

    if (success && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Registrierung erfolgreich. Bitte anmelden.'), backgroundColor: AppTheme.successColor),
      );
      context.go('/login');
    } else if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(authProvider.error ?? 'Registrierung fehlgeschlagen'), backgroundColor: AppTheme.errorColor),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return FigmaScreen(
      header: FigmaBackHeader(title: 'Registrieren', onBack: () => context.go('/login')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppTheme.screenHorizontalPadding),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 8),
              Text('Konto erstellen', style: FigmaUi.rubik(fontSize: 24, fontWeight: FontWeight.w500, color: AppTheme.textColor)),
              const SizedBox(height: 8),
              Text('Registrieren Sie sich, um zu beginnen.', style: FigmaUi.rubik(fontSize: 18, fontWeight: FontWeight.w400, color: AppTheme.primaryBlue)),
              const SizedBox(height: 28),
              NeumorphicInsetField(controller: _firstNameController, label: 'Vorname', prefixIcon: Icons.person_outline, validator: (v) => (v == null || v.isEmpty) ? 'Bitte Vorname eingeben' : null),
              const SizedBox(height: 20),
              NeumorphicInsetField(controller: _lastNameController, label: 'Nachname', prefixIcon: Icons.person_outline, validator: (v) => (v == null || v.isEmpty) ? 'Bitte Nachname eingeben' : null),
              const SizedBox(height: 20),
              NeumorphicInsetField(controller: _emailController, label: 'E-mail', prefixIcon: Icons.mail_outline, keyboardType: TextInputType.emailAddress, validator: (v) {
                if (v == null || v.isEmpty) return 'Bitte E-Mail eingeben';
                if (!v.contains('@')) return 'Ungültige E-Mail';
                return null;
              }),
              const SizedBox(height: 20),
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
                  icon: Icon(_obscurePassword ? Icons.visibility_outlined : Icons.visibility_off_outlined, color: AppTheme.textColorSecondary, size: 20),
                  onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                ),
              ),
              const SizedBox(height: 20),
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
                  icon: Icon(_obscureConfirmPassword ? Icons.visibility_outlined : Icons.visibility_off_outlined, color: AppTheme.textColorSecondary, size: 20),
                  onPressed: () => setState(() => _obscureConfirmPassword = !_obscureConfirmPassword),
                ),
              ),
              const SizedBox(height: 28),
              Consumer<AuthProvider>(
                builder: (context, auth, _) => NeumorphicPillButton(
                  label: 'Registrieren',
                  loading: auth.isLoading,
                  onPressed: auth.isLoading ? null : _handleSignup,
                ),
              ),
              const SizedBox(height: 20),
              Center(
                child: GestureDetector(
                  onTap: () => context.go('/login'),
                  child: Text.rich(
                    TextSpan(
                      text: 'Bereits ein Konto? ',
                      style: FigmaUi.rubik(fontSize: 16, fontWeight: FontWeight.w300, color: AppTheme.textColor),
                      children: [
                        TextSpan(text: 'Anmelden', style: FigmaUi.rubik(fontSize: 16, fontWeight: FontWeight.w500, color: AppTheme.textColor)),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
