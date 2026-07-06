import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hdx_mobile/config/app_theme.dart';
import 'package:hdx_mobile/models/user_test_result.dart';
import 'package:hdx_mobile/widgets/test_result_badge.dart';

void main() {
  test('negative and pending use different badge colors', () {
    final negative = UserTestResult(id: '1', result: 'NEGATIVE');
    final pending = UserTestResult(id: '2');

    final negColors = TestResultBadge.colorsForKind(negative.resultKind);
    final pendingColors = TestResultBadge.colorsForKind(pending.resultKind);

    expect(negative.resultLabel, 'Negativ');
    expect(pending.resultLabel, 'Ausstehend');
    expect(negColors.$1, AppTheme.successColor);
    expect(pendingColors.$1, Colors.white);
    expect(negColors.$1, isNot(pendingColors.$1));
    expect(negColors.$2, isNot(pendingColors.$2));
    expect(negative.resultKind, TestResultKind.negative);
    expect(pending.resultKind, TestResultKind.pending);
  });

  // Previously untested (see docs/regulatory/gap-assessment.md §5): only
  // negative-vs-pending was asserted, leaving positive/invalid/inconclusive
  // badge rendering as unverified regression risk.
  test('positive result maps to the positive badge kind, color, icon, and label', () {
    final positive = UserTestResult(id: '1', result: 'POSITIVE');
    final colors = TestResultBadge.colorsForKind(positive.resultKind);

    expect(positive.resultKind, TestResultKind.positive);
    expect(positive.resultLabel, 'Positiv');
    expect(colors.$1, AppTheme.accentCoral.withValues(alpha: 0.55));
    expect(TestResultBadge.iconForKind(TestResultKind.positive), Icons.error_outline);
  });

  test('invalid result maps to the invalid badge kind, color, icon, and label', () {
    final invalid = UserTestResult(id: '1', result: 'INVALID');
    final colors = TestResultBadge.colorsForKind(invalid.resultKind);

    expect(invalid.resultKind, TestResultKind.invalid);
    expect(invalid.resultLabel, 'Ungültig');
    expect(colors.$1, AppTheme.navy.withValues(alpha: 0.08));
    expect(TestResultBadge.iconForKind(TestResultKind.invalid), Icons.block);
  });

  test('inconclusive result maps to the inconclusive badge kind, color, icon, and label', () {
    final inconclusive = UserTestResult(id: '1', result: 'INCONCLUSIVE');
    final colors = TestResultBadge.colorsForKind(inconclusive.resultKind);

    expect(inconclusive.resultKind, TestResultKind.inconclusive);
    expect(inconclusive.resultLabel, 'Unbestimmt');
    expect(colors.$1, const Color(0xFFE8E0F5));
    expect(TestResultBadge.iconForKind(TestResultKind.inconclusive), Icons.help_outline);
  });

  test(
    'positive and invalid/inconclusive/negative are visually distinguishable by background color',
    () {
      final positive = TestResultBadge.colorsForKind(TestResultKind.positive).$1;
      final invalid = TestResultBadge.colorsForKind(TestResultKind.invalid).$1;
      final inconclusive = TestResultBadge.colorsForKind(TestResultKind.inconclusive).$1;
      final negative = TestResultBadge.colorsForKind(TestResultKind.negative).$1;

      expect(positive, isNot(invalid));
      expect(positive, isNot(inconclusive));
      expect(positive, isNot(negative));
    },
  );

  // Documents the known usability finding from gap-assessment.md §5
  // (positive/error color family overlap) rather than silently leaving it
  // unverified. If this ever changes, update it deliberately rather than
  // letting a test failure be the first signal.
  test(
    'KNOWN GAP: positive badge and errorColor share the same base hue (accentCoral) — '
    'see docs/regulatory/gap-assessment.md §5, not fixed in this change',
    () {
      expect(AppTheme.errorColor, AppTheme.accentCoral);
    },
  );
}
