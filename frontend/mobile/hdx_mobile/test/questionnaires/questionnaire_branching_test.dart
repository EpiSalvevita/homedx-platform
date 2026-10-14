import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:hdx_mobile/models/questionnaire/questionnaire_models.dart';
import 'package:hdx_mobile/questionnaires/questionnaire_branching.dart';

/// Synthetic fixture only. No real clinical content.
QuestionnaireModule _module(List<Map<String, dynamic>> items, {List<Map<String, dynamic>>? sections}) {
  return QuestionnaireModule.fromJson({
    'moduleId': 'TEST',
    'catalogueId': 'TEST-Q',
    'title': 'Testbogen',
    'audience': 'Test',
    'sections': sections ??
        [
          {
            'id': 'S1',
            'title': 'Abschnitt 1',
            'items': items,
          },
        ],
  });
}

Map<String, dynamic> _single(String id, {Map<String, dynamic>? rule, bool required = false}) => {
      'id': id,
      'type': 'single',
      'required': required,
      'text': 'Frage $id',
      'options': ['Ja', 'Nein'],
      'responseContract': {'kind': 'categorical_single'},
      if (rule != null) 'visibilityRule': rule,
    };

void main() {
  group('visibility', () {
    test('an unanswered parent never satisfies neq', () {
      final m = _module([
        _single('P'),
        _single('K', rule: {'item': 'P', 'op': 'neq', 'value': 'Nein'}),
      ]);
      expect(visibleItemIds(m, {}), {'P'});
      expect(visibleItemIds(m, {'P': 'Ja'}), {'P', 'K'});
      expect(visibleItemIds(m, {'P': 'Nein'}), {'P'});
    });

    test('eq, in, contains, answered and any/all behave as on the server', () {
      final m = _module([
        _single('P'),
        {
          'id': 'M',
          'type': 'multi',
          'required': false,
          'text': 'Mehrfach',
          'options': ['a', 'b'],
          'responseContract': {'kind': 'categorical_multi'},
        },
        _single('EQ', rule: {'item': 'P', 'op': 'eq', 'value': 'Ja'}),
        _single('IN', rule: {'item': 'P', 'op': 'in', 'values': ['Ja']}),
        _single('CONT', rule: {'item': 'M', 'op': 'contains', 'value': 'a'}),
        _single('ANS', rule: {'item': 'M', 'op': 'answered'}),
        _single('ANY', rule: {
          'any': [
            {'item': 'P', 'op': 'eq', 'value': 'Nein'},
            {'item': 'M', 'op': 'contains', 'value': 'b'},
          ],
        }),
        _single('ALL', rule: {
          'all': [
            {'item': 'P', 'op': 'eq', 'value': 'Ja'},
            {'item': 'M', 'op': 'contains', 'value': 'a'},
          ],
        }),
      ]);
      expect(visibleItemIds(m, {'P': 'Ja', 'M': ['a']}), {'P', 'M', 'EQ', 'IN', 'CONT', 'ANS', 'ALL'});
      expect(visibleItemIds(m, {'P': 'Nein', 'M': ['b']}), {'P', 'M', 'ANS', 'ANY'});
    });

    test('a hidden parent hides its children', () {
      final m = _module([
        _single('P', rule: {'feature': 'never', 'op': 'shown'}),
        _single('K', rule: {'item': 'P', 'op': 'answered'}),
      ]);
      expect(visibleItemIds(m, {'P': 'Ja', 'K': 'Ja'}), isEmpty);
    });

    test('a cycle is treated as hidden instead of looping', () {
      final m = _module([
        _single('A1', rule: {'item': 'B1', 'op': 'answered'}),
        _single('B1', rule: {'item': 'A1', 'op': 'answered'}),
      ]);
      expect(visibleItemIds(m, {'A1': 'Ja', 'B1': 'Ja'}), isEmpty);
    });
  });

  group('pruning and steps', () {
    test('pruneAnswers drops answers to hidden items', () {
      final m = _module([
        _single('P'),
        _single('K', rule: {'item': 'P', 'op': 'eq', 'value': 'Ja'}),
      ]);
      expect(pruneAnswers(m, {'P': 'Nein', 'K': 'Ja'}), {'P': 'Nein'});
    });

    test('steps skip sections without visible questions and never include review controls', () {
      final m = _module([], sections: [
        {
          'id': 'S1',
          'title': 'Nur mit Ja',
          'items': [_single('K', rule: {'item': 'P', 'op': 'eq', 'value': 'Ja'})],
        },
        {
          'id': 'S2',
          'title': 'Immer',
          'items': [
            _single('P'),
            {
              'id': 'RV',
              'type': 'review',
              'required': true,
              'text': 'Absenden',
              'options': ['Absenden'],
              'responseContract': {'kind': 'ui_control_not_research_response'},
            },
          ],
        },
      ]);
      final steps = buildQuestionnaireSteps(m, {});
      expect(steps.map((s) => s.section.id), ['S2']);
      expect(steps.single.items.map((i) => i.id), ['P']);
      expect(steps.single.index, 1);
      expect(steps.single.total, 1);
    });
  });

  test('the real V04 catalogue parses and yields a first step for an empty answer set', () {
    final file = File('../../../backend/data/questionnaires/rheumacheck_questionnaires_v04.public.json');
    final pkg = jsonDecode(file.readAsStringSync()) as Map<String, dynamic>;
    final questionnaires = (pkg['questionnaires'] as List).cast<Map<String, dynamic>>();
    expect(questionnaires, hasLength(4));

    var itemCount = 0;
    for (final q in questionnaires) {
      final module = QuestionnaireModule.fromJson({
        'moduleId': q['id'],
        'catalogueId': q['id'],
        'title': q['title'],
        'audience': q['audience'],
        'sections': q['sections'],
      });
      itemCount += module.items.length;
      expect(buildQuestionnaireSteps(module, {}), isNotEmpty, reason: q['id'] as String);
    }
    expect(itemCount, 171);
  });
}
