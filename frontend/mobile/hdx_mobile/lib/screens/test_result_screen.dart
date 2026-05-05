import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../config/app_theme.dart';
import '../services/cube_service.dart';
import '../utils/test_specialization_mapping.dart';
import '../widgets/neumorphic.dart';

/// Full-screen display of a single Cube test result.
///
/// Shows a large result badge (positive/negative/inconclusive),
/// the test name, date/time, and detailed result rows.
///
/// When the result is positive and a [testTypeId] is available, the screen
/// also offers a CTA that deep-links into the doctor selection flow,
/// pre-filtered to the matching specialty (e.g. positive RheumaCheck ->
/// Rheumatologie).
class TestResultScreen extends StatelessWidget {
  final String testTypeName;
  final CubeTestResult result;
  final String? testTypeId;

  const TestResultScreen({
    super.key,
    required this.testTypeName,
    required this.result,
    this.testTypeId,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final overallResult = (result.result ?? '').toUpperCase();
    final isPositive = overallResult.contains('POS');
    final isNegative = overallResult.contains('NEG');

    final Color badgeColor;
    final IconData badgeIcon;
    final String badgeLabel;

    if (isPositive) {
      badgeColor = const Color(0xFFE53E3E);
      badgeIcon = Icons.warning_rounded;
      badgeLabel = 'Positiv';
    } else if (isNegative) {
      badgeColor = const Color(0xFF48BB78);
      badgeIcon = Icons.check_circle;
      badgeLabel = 'Negativ';
    } else {
      badgeColor = const Color(0xFFED8936);
      badgeIcon = Icons.help_outline;
      badgeLabel = 'Unbestimmt';
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Testergebnis'),
        automaticallyImplyLeading: false,
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(24),
          children: [
            // Result badge
            NeumorphicContainer(
              padding: const EdgeInsets.symmetric(vertical: 32, horizontal: 24),
              child: Column(
                children: [
                  Container(
                    width: 100,
                    height: 100,
                    decoration: BoxDecoration(
                      color: badgeColor.withValues(alpha: 0.12),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(badgeIcon, size: 56, color: badgeColor),
                  ),
                  const SizedBox(height: 20),
                  Text(
                    badgeLabel,
                    style: theme.textTheme.displayMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: badgeColor,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    testTypeName,
                    style: theme.textTheme.titleLarge?.copyWith(
                      color: AppTheme.textColorSecondary,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    _formatDate(DateTime.now()),
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: AppTheme.textColorSecondary,
                    ),
                  ),
                ],
              ),
            ),

            // Detail rows
            if (result.resultData != null && result.resultData!.isNotEmpty) ...[
              const SizedBox(height: 24),
              Text(
                'Detaillierte Ergebnisse',
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: AppTheme.textColor,
                ),
              ),
              const SizedBox(height: 12),
              ...result.resultData!.map((r) => _buildResultRow(theme, r)),
            ],

            const SizedBox(height: 32),

            if (isPositive) _buildBookSpecialistCta(context),

            // Actions
            NeumorphicButton(
              isPrimary: !isPositive,
              onPressed: () => Navigator.of(context).popUntil((r) => r.isFirst),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.home,
                    color: isPositive ? AppTheme.textColor : Colors.white,
                  ),
                  const SizedBox(width: 12),
                  Text(
                    'Zur Startseite',
                    style: TextStyle(
                      color: isPositive ? AppTheme.textColor : Colors.white,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildBookSpecialistCta(BuildContext context) {
    final specialization =
        TestSpecializationMapping.primarySpecialization(testTypeId);

    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: NeumorphicButton(
        key: const Key('book-specialist-cta'),
        isPrimary: true,
        onPressed: () {
          final query = <String, String>{};
          if (testTypeId != null && testTypeId!.isNotEmpty) {
            query['testTypeId'] = testTypeId!;
          }
          if (testTypeName.isNotEmpty) {
            query['testTypeName'] = testTypeName;
          }
          final uri = Uri(path: '/doctors', queryParameters: query);
          context.push(uri.toString());
        },
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.calendar_month, color: Colors.white),
                SizedBox(width: 12),
                Text(
                  'Termin mit Facharzt buchen',
                  style: TextStyle(color: Colors.white),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Text(
              'Empfohlen: $specialization',
              style: const TextStyle(
                color: Colors.white70,
                fontSize: 12,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildResultRow(ThemeData theme, CubeResultData data) {
    final validity = data.validity;
    final validityColor = validity == 1
        ? const Color(0xFF48BB78)
        : validity == 0
            ? const Color(0xFFED8936)
            : AppTheme.errorColor;
    final validityLabel = validity == 1
        ? 'Gültig'
        : validity == 0
            ? 'Unklar'
            : 'Ungültig';

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: NeumorphicContainer(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    data.name,
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: AppTheme.textColor,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      Text(
                        data.value,
                        style: theme.textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: AppTheme.primaryColor,
                        ),
                      ),
                      if (data.unit.isNotEmpty) ...[
                        const SizedBox(width: 4),
                        Text(
                          data.unit,
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: AppTheme.textColorSecondary,
                          ),
                        ),
                      ],
                    ],
                  ),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: validityColor.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                validityLabel,
                style: TextStyle(
                  color: validityColor,
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
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
