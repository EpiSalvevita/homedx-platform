import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../config/app_theme.dart';
import '../models/user_test_result.dart';
import '../services/cube_service.dart';
import '../utils/test_specialization_mapping.dart';
import '../widgets/figma_ui.dart';
import '../widgets/test_result_badge.dart';
import '../widgets/web/adaptive_screen.dart';

/// Full-screen display of a single Cube test result.
class TestResultScreen extends StatelessWidget {
  final String testTypeName;
  final CubeTestResult result;
  final String? testTypeId;
  final DateTime? testDate;

  const TestResultScreen({
    super.key,
    required this.testTypeName,
    required this.result,
    this.testTypeId,
    this.testDate,
  });

  TestResultKind get _resultKind {
    final overall = (result.result ?? '').toUpperCase();
    if (overall.contains('POS')) return TestResultKind.positive;
    if (overall.contains('NEG')) return TestResultKind.negative;
    if (overall.contains('INCONCLUSIVE')) return TestResultKind.inconclusive;
    if (overall.contains('INVALID')) return TestResultKind.invalid;
    return TestResultKind.inconclusive;
  }

  String get _resultLabel {
    switch (_resultKind) {
      case TestResultKind.positive:
        return 'Positiv';
      case TestResultKind.negative:
        return 'Negativ';
      case TestResultKind.inconclusive:
        return 'Unbestimmt';
      case TestResultKind.invalid:
        return 'Ungültig';
      case TestResultKind.pending:
        return 'Ausstehend';
    }
  }

  @override
  Widget build(BuildContext context) {
    final kind = _resultKind;
    final isPositive = kind == TestResultKind.positive;
    final (badgeBg, badgeFg) = TestResultBadge.colorsForKind(kind);
    final badgeIcon = TestResultBadge.iconForKind(kind);
    final badgeIconColor = TestResultBadge.iconColorForKind(kind);
    final when = testDate ?? DateTime.now();

    return AdaptiveScreen(
      title: 'Testergebnis',
      onBack: () => context.canPop() ? context.pop() : context.go('/results'),
      body: SingleChildScrollView(
        padding: EdgeInsets.fromLTRB(
          kIsWeb ? 32 : AppTheme.screenHorizontalPadding,
          8,
          kIsWeb ? 32 : AppTheme.screenHorizontalPadding,
          24,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            NeumorphicRaisedCard(
              height: null,
              padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 28),
              child: Column(
                children: [
                  Container(
                    width: 72,
                    height: 72,
                    decoration: BoxDecoration(
                      color: badgeBg,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(badgeIcon, size: 36, color: badgeIconColor),
                  ),
                  const SizedBox(height: 16),
                  Container(
                    padding: AppTheme.resultBadgePadding,
                    decoration: BoxDecoration(
                      color: badgeBg,
                      borderRadius: BorderRadius.circular(AppTheme.resultBadgeRadius),
                      border: kind == TestResultKind.pending
                          ? Border.all(color: AppTheme.primaryBlue, width: 1.5)
                          : null,
                    ),
                    child: Text(
                      _resultLabel,
                      style: FigmaUi.rubik(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: badgeFg,
                      ),
                    ),
                  ),
                  const SizedBox(height: 14),
                  Text(
                    testTypeName,
                    textAlign: TextAlign.center,
                    style: FigmaUi.rubik(
                      fontSize: 20,
                      fontWeight: FontWeight.w500,
                      color: AppTheme.textColor,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    _formatDate(when),
                    textAlign: TextAlign.center,
                    style: FigmaUi.bodyLight(
                      fontSize: 14,
                      color: AppTheme.textColorSecondary,
                    ),
                  ),
                ],
              ),
            ),
            if (result.resultData != null && result.resultData!.isNotEmpty) ...[
              const SizedBox(height: 28),
              const FigmaSectionTitle('Detaillierte Ergebnisse'),
              const SizedBox(height: 12),
              ...result.resultData!.map(_buildResultRow),
            ],
            const SizedBox(height: 28),
            if (isPositive) ...[
              _buildBookSpecialistCta(context),
              Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Text(
                  'Empfohlen: ${TestSpecializationMapping.primarySpecialization(testTypeId)}',
                  textAlign: TextAlign.center,
                  style: FigmaUi.bodyLight(fontSize: 13),
                ),
              ),
            ],
            if (result.testId != null && result.testId!.isNotEmpty) ...[
              NeumorphicPillButton(
                label: 'Usability-Fragebogen (Bogen C)',
                leadingIcon: Icons.quiz_outlined,
                backgroundColor: AppTheme.surface,
                foregroundColor: AppTheme.textColor,
                onPressed: () {
                  final returnPath = Uri.encodeComponent('/results');
                  context.push(
                    '/questionnaires/C?rapidTestId=${result.testId}&return=$returnPath',
                  );
                },
              ),
              const SizedBox(height: 12),
            ],
            NeumorphicPillButton(
              label: 'Zurück zu Ergebnissen',
              leadingIcon: Icons.arrow_back,
              backgroundColor: isPositive ? AppTheme.surface : AppTheme.primaryBlue,
              foregroundColor: isPositive ? AppTheme.textColor : Colors.white,
              onPressed: () => context.canPop() ? context.pop() : context.go('/results'),
            ),
            const SizedBox(height: 12),
            NeumorphicPillButton(
              label: 'Zur Startseite',
              leadingIcon: Icons.home_outlined,
              backgroundColor: AppTheme.accentMint,
              foregroundColor: AppTheme.onMint,
              onPressed: () => context.go('/home'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBookSpecialistCta(BuildContext context) {
    return NeumorphicPillButton(
      key: const Key('book-specialist-cta'),
      label: 'Termin mit Facharzt buchen',
      leadingIcon: Icons.calendar_today_outlined,
      backgroundColor: AppTheme.primaryBlue,
      foregroundColor: Colors.white,
      onPressed: () {
        final query = <String, String>{};
        if (testTypeId != null && testTypeId!.isNotEmpty) {
          query['testTypeId'] = testTypeId!;
        }
        if (testTypeName.isNotEmpty) {
          query['testTypeName'] = testTypeName;
        }
        context.push(Uri(path: '/doctors', queryParameters: query).toString());
      },
    );
  }

  Widget _buildResultRow(CubeResultData data) {
    final validityColor = switch (data.validity) {
      0 => AppTheme.successColor,
      1 || 2 => AppTheme.accentBlue,
      3 || 4 => AppTheme.accentCoral,
      _ => AppTheme.textColorSecondary,
    };

    return Padding(
      padding: const EdgeInsets.only(bottom: AppTheme.testResultCardSpacing),
      child: NeumorphicRaisedCard(
        height: null,
        padding: const EdgeInsets.all(20),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    data.name,
                    style: FigmaUi.rubik(
                      fontSize: 15,
                      fontWeight: FontWeight.w500,
                      color: AppTheme.textColor,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.baseline,
                    textBaseline: TextBaseline.alphabetic,
                    children: [
                      Text(
                        data.value,
                        style: FigmaUi.rubik(
                          fontSize: 22,
                          fontWeight: FontWeight.w600,
                          color: AppTheme.primaryBlue,
                        ),
                      ),
                      if (data.unit.isNotEmpty) ...[
                        const SizedBox(width: 6),
                        Text(
                          data.unit,
                          style: FigmaUi.bodyLight(fontSize: 14),
                        ),
                      ],
                    ],
                  ),
                ],
              ),
            ),
            Container(
              padding: AppTheme.resultBadgePadding,
              decoration: BoxDecoration(
                color: validityColor.withValues(alpha: 0.18),
                borderRadius: BorderRadius.circular(AppTheme.resultBadgeRadius),
              ),
              child: Text(
                data.validityLabel,
                style: FigmaUi.rubik(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color: validityColor,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatDate(DateTime dt) {
    return '${dt.day.toString().padLeft(2, '0')}.'
        '${dt.month.toString().padLeft(2, '0')}.'
        '${dt.year}  '
        '${dt.hour.toString().padLeft(2, '0')}:'
        '${dt.minute.toString().padLeft(2, '0')}';
  }
}
