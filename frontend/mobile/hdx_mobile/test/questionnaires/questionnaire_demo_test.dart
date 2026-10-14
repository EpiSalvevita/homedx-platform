import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:hdx_mobile/models/questionnaire/questionnaire_models.dart';
import 'package:hdx_mobile/questionnaires/questionnaire_answer_format.dart';
import 'package:hdx_mobile/questionnaires/questionnaire_branching.dart';
import 'package:hdx_mobile/questionnaires/questionnaire_demo.dart';

QuestionnaireItem _item(Map<String, dynamic> json) => QuestionnaireItem.fromJson(json);

void main() {
  final file = File('../../../backend/data/questionnaires/rheumacheck_questionnaires_v04.public.json');
  final pkg = jsonDecode(file.readAsStringSync()) as Map<String, dynamic>;
  final modules = [
    for (final q in (pkg['questionnaires'] as List).cast<Map<String, dynamic>>())
      QuestionnaireModule.fromJson({
        'moduleId': q['id'],
        'catalogueId': q['id'],
        'title': q['title'],
        'audience': q['audience'],
        'sections': q['sections'],
      }),
  ];

  test('synthetic demo answers complete every visible required question', () {
    for (final module in modules) {
      final answers = syntheticDemoAnswers(module);
      final visible = visibleItemIds(module, answers);
      for (final item in module.items) {
        if (!visible.contains(item.id) || !item.required || item.isUiControl) continue;
        expect(isAnswered(answers[item.id]), isTrue, reason: '${module.catalogueId} ${item.id}');
      }
    }
  });

  test('synthetic demo answers never store a value for a hidden question', () {
    for (final module in modules) {
      final answers = syntheticDemoAnswers(module);
      expect(pruneAnswers(module, answers), answers, reason: module.catalogueId);
    }
  });

  test('synthetic scale value is the example 4, inside the contract range', () {
    final module = modules.firstWhere((m) => m.catalogueId == 'RC-A');
    final answers = syntheticDemoAnswers(module);
    expect(answers['A28'], 4);
  });

  group('formatAnswer', () {
    test('ranks are numbered in order', () {
      final item = _item({
        'id': 'R',
        'type': 'rank_top3',
        'required': true,
        'text': 'Rang',
        'options': ['a', 'b', 'c'],
        'responseContract': {'kind': 'ranked_codes'},
      });
      expect(formatAnswer(item, ['b', 'a']), '1. b, 2. a');
    });

    test('matrix shows one line per answered row', () {
      final item = _item({
        'id': 'MX',
        'type': 'matrix_presence',
        'required': true,
        'text': 'Matrix',
        'options': ['Zeile 1', 'Zeile 2'],
        'responseContract': {'kind': 'matrix', 'ratings': ['regelhaft']},
      });
      expect(formatAnswer(item, {'Zeile 2': 'regelhaft'}), 'Zeile 2: regelhaft');
    });

    test('a scale shows the number, and an unanswered value is empty', () {
      final item = _item({
        'id': 'SC',
        'type': 'scale_0_10',
        'required': true,
        'text': 'Skala',
        'options': ['0', '10'],
        'responseContract': {'kind': 'integer', 'minimum': 0, 'maximum': 10},
      });
      expect(formatAnswer(item, 0), '0');
      expect(formatAnswer(item, null), '');
    });
  });
}
