import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hdx_mobile/l10n/app_localizations.dart';
import 'package:hdx_mobile/models/questionnaire/questionnaire_models.dart';
import 'package:hdx_mobile/questionnaires/questionnaire_field_widgets.dart';

/// Synthetic fixtures only.
QuestionnaireItem _item(Map<String, dynamic> json) => QuestionnaireItem.fromJson(json);

Widget _host(Widget child) => MaterialApp(
      locale: const Locale('de'),
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      home: Scaffold(body: SingleChildScrollView(child: child)),
    );

void main() {
  testWidgets('scale_0_10 starts unanswered and records an integer, never a default 0', (tester) async {
    Object? captured;
    await tester.pumpWidget(_host(QuestionnaireFieldWidget(
      item: _item({
        'id': 'SC',
        'type': 'scale_0_10',
        'required': true,
        'text': 'Skala',
        'options': ['0 – keine', '10 – stärkste'],
        'responseContract': {'kind': 'integer', 'minimum': 0, 'maximum': 10},
      }),
      value: null,
      onChanged: (_, v) => captured = v,
    )));

    expect(find.text('0 – keine'), findsOneWidget);
    expect(tester.widgetList<ChoiceChip>(find.byType(ChoiceChip)).where((c) => c.selected), isEmpty);

    await tester.tap(find.text('4'));
    await tester.pump();
    expect(captured, 4);
    expect(captured, isA<int>());
  });

  testWidgets('exclusive options clear the others and are cleared by any other option', (tester) async {
    List<String>? captured;
    final item = _item({
      'id': 'M',
      'type': 'multi',
      'required': false,
      'text': 'Mehrfach',
      'options': ['keine', 'Schmerzmittel', 'Kortison'],
      'exclusiveOptions': ['keine'],
      'responseContract': {'kind': 'categorical_multi'},
    });

    await tester.pumpWidget(_host(QuestionnaireFieldWidget(
      item: item,
      value: ['Schmerzmittel', 'Kortison'],
      onChanged: (_, v) => captured = List<String>.from(v as List),
    )));
    await tester.tap(find.text('keine'));
    await tester.pump();
    expect(captured, ['keine']);

    await tester.pumpWidget(_host(QuestionnaireFieldWidget(
      item: item,
      value: ['keine'],
      onChanged: (_, v) => captured = List<String>.from(v as List),
    )));
    await tester.tap(find.text('Kortison'));
    await tester.pump();
    expect(captured, ['Kortison']);
  });

  testWidgets('rank stops at the maximum', (tester) async {
    List<String>? captured;
    await tester.pumpWidget(_host(QuestionnaireFieldWidget(
      item: _item({
        'id': 'R',
        'type': 'rank_top3',
        'required': true,
        'text': 'Rang',
        'options': ['a', 'b', 'c', 'd'],
        'responseContract': {'kind': 'ranked_codes', 'minimumSelected': 1, 'maximumSelected': 3},
      }),
      value: ['a', 'b', 'c'],
      onChanged: (_, v) => captured = List<String>.from(v as List),
    )));

    await tester.tap(find.text('d'));
    await tester.pump();
    expect(captured, isNull);
  });

  testWidgets('matrix stores one rating per row', (tester) async {
    Map<String, dynamic>? captured;
    await tester.pumpWidget(_host(QuestionnaireFieldWidget(
      item: _item({
        'id': 'MX',
        'type': 'matrix_presence',
        'required': true,
        'text': 'Matrix',
        'options': ['Zeile 1', 'Zeile 2'],
        'responseContract': {'kind': 'matrix', 'ratings': ['regelhaft', 'selten']},
      }),
      value: {'Zeile 1': 'regelhaft'},
      onChanged: (_, v) => captured = Map<String, dynamic>.from(v as Map),
    )));

    expect(find.text('regelhaft'), findsNWidgets(2));
    await tester.tap(find.text('selten').last);
    await tester.pump();
    expect(captured, {'Zeile 1': 'regelhaft', 'Zeile 2': 'selten'});
  });
}
