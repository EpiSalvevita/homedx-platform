import 'package:flutter_test/flutter_test.dart';
import 'package:hdx_mobile/models/questionnaire/questionnaire_models.dart';
import 'package:hdx_mobile/questionnaires/questionnaire_branching.dart';

QuestionnaireModule _moduleA() {
  return QuestionnaireModule(
    moduleId: 'A',
    title: 'Test A',
    targetGroup: 'patient',
    sections: [
      QuestionnaireSection(
        sectionId: 'A1',
        title: 'S1',
        fields: [
          QuestionnaireField(
            id: 'A_joint_pain',
            type: 'single_choice',
            required: true,
            label: 'Joint pain?',
            options: ['ja', 'nein'],
          ),
          QuestionnaireField(
            id: 'A_symptom_duration',
            type: 'single_choice',
            required: false,
            label: 'Since when?',
            options: ['unter 2 Wochen'],
            showIf: QuestionnaireShowIf(field: 'A_joint_pain', equals: 'ja'),
          ),
          QuestionnaireField(
            id: 'A_affected_joints',
            type: 'multi_choice',
            required: false,
            label: 'Joints',
            options: ['Knie'],
          ),
          QuestionnaireField(
            id: 'A_morning_stiffness_duration',
            type: 'single_choice',
            required: false,
            label: 'Duration',
            options: ['unter 15 Minuten'],
            showIf: QuestionnaireShowIf(field: 'A_morning_stiffness', equals: 'ja'),
          ),
        ],
      ),
    ],
  );
}

void main() {
  test('hides A detail fields when joint pain is nein', () {
    final module = _moduleA();
    final visible = listVisibleFields(module, {'A_joint_pain': 'nein'});
    expect(visible.map((f) => f.id), ['A_joint_pain']);
    expect(visible.any((f) => f.id == 'A_symptom_duration'), isFalse);
  });

  test('shows symptom duration only when joint pain is ja', () {
    final module = _moduleA();
    final hidden = listVisibleFields(module, {});
    expect(hidden.any((f) => f.id == 'A_symptom_duration'), isFalse);

    final visible = listVisibleFields(module, {'A_joint_pain': 'ja'});
    expect(visible.any((f) => f.id == 'A_symptom_duration'), isTrue);
  });

  test('show_if reveals morning stiffness duration', () {
    final module = _moduleA();
    final hidden = listVisibleFields(module, {'A_morning_stiffness': 'nein'});
    expect(hidden.any((f) => f.id == 'A_morning_stiffness_duration'), isFalse);

    final visible = listVisibleFields(module, {'A_morning_stiffness': 'ja'});
    expect(visible.any((f) => f.id == 'A_morning_stiffness_duration'), isTrue);
  });

  test('buildQuestionnaireSteps splits fields into steps', () {
    final module = _moduleA();
    final steps = buildQuestionnaireSteps(
      module,
      {'A_joint_pain': 'ja'},
      fieldsPerStep: 1,
    );
    expect(steps.length, greaterThan(1));
    expect(steps.first.index, 1);
    expect(steps.first.total, steps.length);
  });
}
