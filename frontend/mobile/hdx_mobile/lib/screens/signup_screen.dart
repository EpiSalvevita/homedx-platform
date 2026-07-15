import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../config/app_theme.dart';
import '../providers/auth_provider.dart';
import '../utils/app_assets.dart';
import '../utils/medical_specializations.dart';
import '../utils/password_validation.dart';
import '../utils/registration_errors.dart';
import '../widgets/auth_ui.dart';
import '../widgets/figma_ui.dart';

class SignupScreen extends StatefulWidget {
  final bool isDoctor;

  const SignupScreen({super.key, this.isDoctor = false});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final _formKey = GlobalKey<FormState>();
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _clinicAddressController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  String? _specialization;
  String? _emailServerError;
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
  bool _autovalidate = false;

  @override
  void initState() {
    super.initState();
    _passwordController.addListener(_onPasswordChanged);
    _emailController.addListener(_onEmailChanged);
  }

  void _onPasswordChanged() {
    setState(() {});
    if (_autovalidate) _formKey.currentState?.validate();
  }

  void _onEmailChanged() {
    if (_emailServerError != null) {
      setState(() => _emailServerError = null);
      if (_autovalidate) _formKey.currentState?.validate();
    }
  }

  @override
  void dispose() {
    _passwordController.removeListener(_onPasswordChanged);
    _emailController.removeListener(_onEmailChanged);
    _firstNameController.dispose();
    _lastNameController.dispose();
    _emailController.dispose();
    _clinicAddressController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _handleSignup() async {
    setState(() => _autovalidate = true);
    if (!_formKey.currentState!.validate()) return;

    final authProvider = context.read<AuthProvider>();
    final success = await authProvider.register(
      email: _emailController.text.trim(),
      password: _passwordController.text,
      firstName: _firstNameController.text.trim(),
      lastName: _lastNameController.text.trim(),
      registerAsDoctor: widget.isDoctor,
      specialization: widget.isDoctor ? _specialization : null,
      clinicAddress: widget.isDoctor ? _clinicAddressController.text.trim() : null,
    );

    if (success && mounted) {
      final confirmationPath =
          widget.isDoctor ? '/signup/doctor/confirmation' : '/signup/confirmation';
      context.go(
        Uri(
          path: confirmationPath,
          queryParameters: {'email': _emailController.text.trim()},
        ).toString(),
      );
    } else if (mounted) {
      final error = authProvider.error;
      if (isEmailAlreadyRegisteredError(error)) {
        setState(() => _emailServerError = error);
        _formKey.currentState!.validate();
        return;
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(error ?? 'Registrierung fehlgeschlagen'),
          backgroundColor: AppTheme.errorColor,
        ),
      );
    }
  }

  Widget _passwordVisibilityButton({
    required bool obscure,
    required VoidCallback onPressed,
  }) {
    return IconButton(
      tooltip: obscure ? 'Passwort anzeigen' : 'Passwort verbergen',
      style: IconButton.styleFrom(
        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
        minimumSize: const Size(48, 48),
        padding: EdgeInsets.zero,
      ),
      icon: Icon(
        obscure ? Icons.visibility_outlined : Icons.visibility_off_outlined,
        color: AppTheme.textColorSecondary,
        size: 24,
      ),
      onPressed: onPressed,
    );
  }

  Widget _fieldSpacer() => const SizedBox(height: 24);

  Widget _firstNameField() => NeumorphicInsetField(
        controller: _firstNameController,
        label: 'Vorname',
        prefixIcon: Icons.person_outline,
        validator: (v) => (v == null || v.isEmpty) ? 'Bitte Vorname eingeben' : null,
      );

  Widget _lastNameField() => NeumorphicInsetField(
        controller: _lastNameController,
        label: 'Nachname',
        prefixIcon: Icons.person_outline,
        validator: (v) => (v == null || v.isEmpty) ? 'Bitte Nachname eingeben' : null,
      );

  Widget _emailField() => NeumorphicInsetField(
        controller: _emailController,
        label: 'E-Mail-Adresse',
        hint: 'name@beispiel.de',
        prefixIcon: Icons.mail_outline,
        keyboardType: TextInputType.emailAddress,
        validator: (v) {
          if (_emailServerError != null) return _emailServerError;
          if (v == null || v.isEmpty) return 'Bitte E-Mail eingeben';
          if (!v.contains('@')) return 'Ungültige E-Mail';
          return null;
        },
      );

  Widget _specializationField() => NeumorphicInsetDropdown(
        label: 'Fachrichtung',
        prefixIcon: Icons.medical_services_outlined,
        value: _specialization,
        items: MedicalSpecializations.all,
        onChanged: (value) => setState(() => _specialization = value),
        validator: (v) => (v == null || v.isEmpty) ? 'Bitte Fachrichtung auswählen' : null,
      );

  Widget _clinicAddressField() => NeumorphicInsetField(
        controller: _clinicAddressController,
        label: 'Praxisadresse',
        hint: 'Straße, PLZ, Stadt',
        prefixIcon: Icons.local_hospital_outlined,
        validator: (v) => (v == null || v.isEmpty) ? 'Bitte Praxisadresse eingeben' : null,
      );

  Widget _passwordField() => NeumorphicInsetField(
        controller: _passwordController,
        label: 'Passwort',
        prefixIcon: Icons.lock_outline,
        obscureText: _obscurePassword,
        validator: PasswordPolicy.validate,
        suffix: _passwordVisibilityButton(
          obscure: _obscurePassword,
          onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
        ),
      );

  Widget _confirmPasswordField() => NeumorphicInsetField(
        controller: _confirmPasswordController,
        label: 'Passwort bestätigen',
        prefixIcon: Icons.lock_outline,
        obscureText: _obscureConfirmPassword,
        validator: (v) {
          if (v == null || v.isEmpty) return 'Bitte Passwort bestätigen';
          if (v != _passwordController.text) return 'Passwörter stimmen nicht überein';
          return null;
        },
        suffix: _passwordVisibilityButton(
          obscure: _obscureConfirmPassword,
          onPressed: () => setState(() => _obscureConfirmPassword = !_obscureConfirmPassword),
        ),
      );

  Widget _fieldRowSpacer() => const SizedBox(width: 16);

  Widget _passwordRulesHint() => PasswordRulesHint(password: _passwordController.text);

  List<Widget> _doctorFieldsAfterNames() {
    return [
      _fieldSpacer(),
      _specializationField(),
      _fieldSpacer(),
      _clinicAddressField(),
    ];
  }

  Widget _buildFields({required bool pairedRows}) {
    if (!pairedRows) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _emailField(),
          _fieldSpacer(),
          _firstNameField(),
          _fieldSpacer(),
          _lastNameField(),
          if (widget.isDoctor) ..._doctorFieldsAfterNames(),
          _fieldSpacer(),
          _passwordRulesHint(),
          _fieldSpacer(),
          _passwordField(),
          _fieldSpacer(),
          _confirmPasswordField(),
        ],
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _emailField(),
        _fieldSpacer(),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(child: _firstNameField()),
            _fieldRowSpacer(),
            Expanded(child: _lastNameField()),
          ],
        ),
        if (widget.isDoctor) ..._doctorFieldsAfterNames(),
        _fieldSpacer(),
        _passwordRulesHint(),
        _fieldSpacer(),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(child: _passwordField()),
            _fieldRowSpacer(),
            Expanded(child: _confirmPasswordField()),
          ],
        ),
      ],
    );
  }

  Widget _buildForm({required bool pairedRows, required bool isWideWeb}) {
    final showWebLogo = kIsWeb && !isWideWeb;
    final title = widget.isDoctor ? 'Arztkonto erstellen' : 'Konto erstellen';
    final subtitle = widget.isDoctor
        ? 'Füllen Sie die Angaben zu Ihrer Praxis aus.'
        : 'Füllen Sie das Formular aus — dauert nur wenige Minuten.';

    return Padding(
      padding: EdgeInsets.fromLTRB(
        kIsWeb ? 32 : AppTheme.screenHorizontalPadding,
        kIsWeb ? 32 : 32,
        kIsWeb ? 32 : AppTheme.screenHorizontalPadding,
        24,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
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
            title,
            style: FigmaUi.rubik(
              fontSize: 26,
              fontWeight: FontWeight.w600,
              color: AppTheme.textColor,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            subtitle,
            style: FigmaUi.bodyLight(fontSize: 18, color: AppTheme.primaryBlue),
          ),
          const SizedBox(height: 32),
          _buildFields(pairedRows: pairedRows),
          const SizedBox(height: 32),
          Consumer<AuthProvider>(
            builder: (context, auth, _) => NeumorphicPillButton(
              label: 'Registrieren',
              loading: auth.isLoading,
              onPressed: auth.isLoading ? null : _handleSignup,
            ),
          ),
          const SizedBox(height: 20),
          Center(
            child: TextButton(
              onPressed: () => context.go(widget.isDoctor ? '/login/doctor' : '/login'),
              style: authLinkButtonStyle(foregroundColor: AppTheme.textColor),
              child: Text.rich(
                TextSpan(
                  text: 'Bereits ein Konto? ',
                  style: FigmaUi.rubik(
                    fontSize: 17,
                    fontWeight: FontWeight.w400,
                    color: AppTheme.textColor,
                  ),
                  children: [
                    TextSpan(
                      text: 'Anmelden',
                      style: FigmaUi.rubik(
                        fontSize: 17,
                        fontWeight: FontWeight.w600,
                        color: AppTheme.primaryBlue,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFormCard({required bool pairedRows, required bool isWideWeb}) {
    return Material(
      elevation: 0,
      color: AppTheme.background,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: AppTheme.navy.withValues(alpha: 0.08)),
      ),
      child: Form(
        key: _formKey,
        autovalidateMode: _autovalidate ? AutovalidateMode.onUserInteraction : AutovalidateMode.disabled,
        child: _buildForm(pairedRows: pairedRows, isWideWeb: isWideWeb),
      ),
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
            final pairedRows = constraints.maxWidth >= 480;
            final maxContentWidth = pairedRows ? 560.0 : 440.0;
            final formCard = _buildFormCard(pairedRows: pairedRows, isWideWeb: isWide);

            if (isWide) {
              return Row(
                children: [
                  Expanded(
                    child: AuthBrandPanel(
                      isDoctor: widget.isDoctor,
                      variant: AuthBrandPanelVariant.signup,
                    ),
                  ),
                  Expanded(
                    child: Center(
                      child: SingleChildScrollView(
                        padding: const EdgeInsets.all(48),
                        child: ConstrainedBox(
                          constraints: BoxConstraints(maxWidth: maxContentWidth),
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
                  constraints: BoxConstraints(maxWidth: maxContentWidth),
                  child: formCard,
                ),
              ),
            );
          },
        ),
      );
    }

    final screenWidth = MediaQuery.sizeOf(context).width;
    final pairedRows = screenWidth >= 480;

    return Scaffold(
      backgroundColor: AppTheme.background,
      body: SafeArea(
        top: false,
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(
            horizontal: AppTheme.screenHorizontalPadding,
            vertical: 16,
          ),
          child: Center(
            child: ConstrainedBox(
              constraints: BoxConstraints(maxWidth: pairedRows ? 560 : 440),
              child: Form(
                key: _formKey,
                autovalidateMode:
                    _autovalidate ? AutovalidateMode.onUserInteraction : AutovalidateMode.disabled,
                child: _buildForm(pairedRows: pairedRows, isWideWeb: false),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
