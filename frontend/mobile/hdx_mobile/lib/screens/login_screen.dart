import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../config/app_theme.dart';
import '../providers/auth_provider.dart';

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
      context.go('/');
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
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 28),
            child: Form(
              key: _formKey,
              child: Column(
                children: [
                  const SizedBox(height: 20),
                  _buildIllustration(),
                  const SizedBox(height: 32),
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      'In Ihr Konto einloggen',
                      style: Theme.of(context).textTheme.displaySmall?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      'Geben Sie Ihre Anmeldedaten ein.',
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                            color: AppTheme.primaryBlue,
                          ),
                    ),
                  ),
                  const SizedBox(height: 32),
                  TextFormField(
                    controller: _emailController,
                    keyboardType: TextInputType.emailAddress,
                    decoration: const InputDecoration(
                      labelText: 'E-mail',
                      prefixIcon: Icon(Icons.email_outlined),
                    ),
                    validator: (v) {
                      if (v == null || v.isEmpty) return 'Bitte E-Mail eingeben';
                      if (!v.contains('@')) return 'Ungültige E-Mail';
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _passwordController,
                    obscureText: _obscurePassword,
                    decoration: InputDecoration(
                      labelText: 'Passwort',
                      prefixIcon: const Icon(Icons.lock_outline),
                      suffixIcon: IconButton(
                        icon: Icon(_obscurePassword ? Icons.visibility_outlined : Icons.visibility_off_outlined),
                        onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                      ),
                    ),
                    validator: (v) {
                      if (v == null || v.isEmpty) return 'Bitte Passwort eingeben';
                      if (v.length < 6) return 'Mindestens 6 Zeichen';
                      return null;
                    },
                  ),
                  const SizedBox(height: 32),
                  Consumer<AuthProvider>(
                    builder: (context, auth, _) {
                      return SizedBox(
                        width: double.infinity,
                        height: 52,
                        child: ElevatedButton(
                          onPressed: auth.isLoading ? null : _handleLogin,
                          child: auth.isLoading
                              ? const SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                                )
                              : const Text('Anmelden', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 24),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text('Noch kein Konto? ', style: TextStyle(color: AppTheme.textColorSecondary)),
                      GestureDetector(
                        onTap: () => context.go('/signup'),
                        child: Text(
                          'Registrieren',
                          style: TextStyle(color: AppTheme.primaryBlue, fontWeight: FontWeight.bold),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildIllustration() {
    return SizedBox(
      height: 220,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Phone frame
          Container(
            width: 140,
            height: 190,
            decoration: BoxDecoration(
              color: AppTheme.primaryLight,
              borderRadius: BorderRadius.circular(24),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    color: AppTheme.primaryBlue.withValues(alpha: 0.15),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.person, size: 36, color: AppTheme.primaryBlue),
                ),
                const SizedBox(height: 12),
                Container(width: 60, height: 6, decoration: BoxDecoration(color: AppTheme.primaryBlue.withValues(alpha: 0.2), borderRadius: BorderRadius.circular(3))),
                const SizedBox(height: 6),
                Container(width: 80, height: 6, decoration: BoxDecoration(color: AppTheme.primaryBlue.withValues(alpha: 0.12), borderRadius: BorderRadius.circular(3))),
              ],
            ),
          ),
          // Floating medical icons
          Positioned(
            top: 10,
            right: 40,
            child: _floatingIcon(Icons.medication, const Color(0xFFFF9F43), 36),
          ),
          Positioned(
            top: 30,
            right: 20,
            child: _floatingIcon(Icons.show_chart, const Color(0xFFEF5B5B), 28),
          ),
          Positioned(
            top: 5,
            left: 60,
            child: _floatingIcon(Icons.local_pharmacy, AppTheme.primaryBlue, 28),
          ),
          Positioned(
            bottom: 30,
            right: 30,
            child: _floatingIcon(Icons.medical_services, AppTheme.successColor, 32),
          ),
          Positioned(
            bottom: 20,
            left: 40,
            child: _floatingIcon(Icons.biotech, const Color(0xFF8B5CF6), 28),
          ),
          Positioned(
            top: 60,
            left: 20,
            child: _floatingIcon(Icons.auto_awesome, const Color(0xFFFFBB33), 20),
          ),
        ],
      ),
    );
  }

  Widget _floatingIcon(IconData icon, Color color, double size) {
    return Container(
      padding: const EdgeInsets.all(6),
      decoration: BoxDecoration(
        color: Colors.white,
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(color: color.withValues(alpha: 0.2), blurRadius: 8, offset: const Offset(0, 2)),
        ],
      ),
      child: Icon(icon, color: color, size: size),
    );
  }
}
