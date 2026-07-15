import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hdx_mobile/models/questionnaire/questionnaire_models.dart';
import 'package:hdx_mobile/questionnaires/questionnaire_field_widgets.dart';

void main() {
  testWidgets('single_choice renders options and updates value', (tester) async {
    String? captured;

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: QuestionnaireFieldWidget(
            field: QuestionnaireField(
              id: 'test_choice',
              type: 'single_choice',
              required: true,
              label: 'Wahlfrage',
              options: ['ja', 'nein'],
            ),
            value: null,
            onChanged: (_, v) => captured = v as String?,
          ),
        ),
      ),
    );

    expect(find.text('Wahlfrage'), findsOneWidget);
    expect(find.text('ja'), findsOneWidget);
    expect(find.text('nein'), findsOneWidget);

    await tester.tap(find.text('ja'));
    await tester.pumpAndSettle();

    expect(captured, 'ja');
  });

  testWidgets('likert_5 renders scale and updates value', (tester) async {
    int? captured;

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: QuestionnaireFieldWidget(
            field: QuestionnaireField(
              id: 'test_likert',
              type: 'likert_5',
              required: true,
              label: 'Likert',
              options: const [],
            ),
            value: null,
            onChanged: (_, v) => captured = v as int?,
          ),
        ),
      ),
    );

    expect(find.text('Likert'), findsOneWidget);
    expect(find.text('3'), findsOneWidget);

    await tester.tap(find.text('3'));
    await tester.pumpAndSettle();

    expect(captured, 3);
  });
}
