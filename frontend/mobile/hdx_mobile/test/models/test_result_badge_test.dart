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
}
