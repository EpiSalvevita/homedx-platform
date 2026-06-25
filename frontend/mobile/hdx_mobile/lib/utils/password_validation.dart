import 'package:flutter/material.dart';
import '../config/app_theme.dart';
import '../widgets/figma_ui.dart';

/// Registration password policy — must match [backend/src/auth/password-policy.ts].
class PasswordPolicy {
  static const int minLength = 8;

  static final RegExp _lowercase = RegExp(r'[a-z]');
  static final RegExp _uppercase = RegExp(r'[A-Z]');
  static final RegExp _digit = RegExp(r'\d');
  static final RegExp _special = RegExp(r'[^A-Za-z0-9]');

  static bool hasMinLength(String value) => value.length >= minLength;
  static bool hasLowercase(String value) => _lowercase.hasMatch(value);
  static bool hasUppercase(String value) => _uppercase.hasMatch(value);
  static bool hasDigit(String value) => _digit.hasMatch(value);
  static bool hasSpecial(String value) => _special.hasMatch(value);

  static bool isStrong(String value) =>
      hasMinLength(value) &&
      hasLowercase(value) &&
      hasUppercase(value) &&
      hasDigit(value) &&
      hasSpecial(value);

  static String? validate(String? value) {
    if (value == null || value.isEmpty) return 'Bitte Passwort eingeben';
    if (!hasMinLength(value)) return 'Mindestens 8 Zeichen';
    if (!hasLowercase(value)) return 'Mindestens ein Kleinbuchstabe';
    if (!hasUppercase(value)) return 'Mindestens ein Großbuchstabe';
    if (!hasDigit(value)) return 'Mindestens eine Zahl';
    if (!hasSpecial(value)) return 'Mindestens ein Sonderzeichen';
    return null;
  }

  static final List<({String label, bool Function(String) check})> rules = [
    (label: 'Mindestens 8 Zeichen', check: hasMinLength),
    (label: 'Mindestens ein Großbuchstabe (A–Z)', check: hasUppercase),
    (label: 'Mindestens ein Kleinbuchstabe (a–z)', check: hasLowercase),
    (label: 'Mindestens eine Zahl (0–9)', check: hasDigit),
    (label: 'Mindestens ein Sonderzeichen (z. B. !@#\$)', check: hasSpecial),
  ];
}

/// Shows registration password rules with live pass/fail indicators.
class PasswordRulesHint extends StatelessWidget {
  final String password;

  const PasswordRulesHint({super.key, required this.password});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Passwort-Anforderungen',
          style: FigmaUi.rubik(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: AppTheme.textColor,
          ),
        ),
        const SizedBox(height: 8),
        ...PasswordPolicy.rules.map((rule) {
          final met = password.isNotEmpty && rule.check(password);
          return Padding(
            padding: const EdgeInsets.only(bottom: 4),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(
                  met ? Icons.check_circle : Icons.circle_outlined,
                  size: 16,
                  color: met ? AppTheme.successColor : AppTheme.textColorSecondary,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    rule.label,
                    style: FigmaUi.rubik(
                      fontSize: 13,
                      fontWeight: FontWeight.w300,
                      color: met ? AppTheme.textColor : AppTheme.textColorSecondary,
                    ),
                  ),
                ),
              ],
            ),
          );
        }),
      ],
    );
  }
}
