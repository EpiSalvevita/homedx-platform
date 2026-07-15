import '../models/questionnaire/questionnaire_models.dart';

bool matchesShowIf(QuestionnaireShowIf? showIf, Map<String, dynamic> answers) {
  if (showIf == null) return true;
  final value = answers[showIf.field];
  if (value is List) {
    return value.contains(showIf.equals);
  }
  return (value ?? '').toString() == showIf.equals;
}

bool passesSupplementalRules(
  String moduleId,
  String fieldId,
  Map<String, dynamic> answers,
) {
  if (moduleId == 'A') {
    final jointPain = (answers['A_joint_pain'] ?? '').toString();
    if (jointPain == 'nein') {
      const hidden = {
        'A_symptom_duration',
        'A_morning_stiffness',
        'A_morning_stiffness_duration',
        'A_affected_joints',
        'A_joint_swelling',
        'A_symmetrical',
        'A_pain_nrs',
        'A_function_limit',
        'A_known_lab_values',
        'A_prior_physician_contact',
      };
      if (hidden.contains(fieldId)) return false;
    }
  }

  if (moduleId == 'C') {
    final usedApp = (answers['C_used_app'] ?? '').toString();
    if (usedApp == 'nein') {
      const appOnly = {
        'C_instructions_clear',
        'C_steps_easy',
        'C_visual_readability',
      };
      if (appOnly.contains(fieldId)) return false;
    }
    final testPerformed = (answers['C_test_performed'] ?? '').toString();
    if (testPerformed == 'nein' || testPerformed == 'weiß nicht') {
      const testOnly = {
        'C_instructions_clear',
        'C_steps_easy',
        'C_visual_readability',
        'C_result_shown',
        'C_result_understood',
      };
      if (testOnly.contains(fieldId)) return false;
    }
    final resultShown = (answers['C_result_shown'] ?? '').toString();
    if (resultShown == 'nein' || resultShown == 'weiß nicht') {
      if (fieldId == 'C_result_understood') return false;
    }
  }

  return true;
}

bool isFieldVisible(
  String moduleId,
  QuestionnaireField field,
  Map<String, dynamic> answers,
) {
  if (!matchesShowIf(field.showIf, answers)) return false;
  return passesSupplementalRules(moduleId, field.id, answers);
}

List<QuestionnaireField> listVisibleFields(
  QuestionnaireModule module,
  Map<String, dynamic> answers,
) {
  final visible = <QuestionnaireField>[];
  for (final section in module.sections) {
    for (final field in section.fields) {
      if (isFieldVisible(module.moduleId, field, answers)) {
        visible.add(field);
      }
    }
  }
  return visible;
}

List<QuestionnaireStep> buildQuestionnaireSteps(
  QuestionnaireModule module,
  Map<String, dynamic> answers, {
  int fieldsPerStep = 2,
}) {
  final steps = <QuestionnaireStep>[];
  for (final section in module.sections) {
    final visible = section.fields
        .where((f) => isFieldVisible(module.moduleId, f, answers))
        .toList();
    if (visible.isEmpty) continue;

    for (var i = 0; i < visible.length; i += fieldsPerStep) {
      final chunk = visible.sublist(
        i,
        i + fieldsPerStep > visible.length ? visible.length : i + fieldsPerStep,
      );
      steps.add(QuestionnaireStep(
        sectionTitle: section.title,
        fields: chunk,
        index: 0,
        total: 0,
      ));
    }
  }

  final total = steps.length;
  return [
    for (var i = 0; i < steps.length; i++)
      QuestionnaireStep(
        sectionTitle: steps[i].sectionTitle,
        fields: steps[i].fields,
        index: i + 1,
        total: total,
      ),
  ];
}
