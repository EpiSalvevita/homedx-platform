import '../models/questionnaire/questionnaire_models.dart';
import 'questionnaire_branching.dart';

List<String> validateQuestionnaireStep(
  QuestionnaireModule module,
  List<QuestionnaireField> fields,
  Map<String, dynamic> answers,
) {
  final errors = <String>[];
  for (final field in fields) {
    if (!isFieldVisible(module.moduleId, field, answers)) continue;
    if (!field.required) continue;
    final value = answers[field.id];
    if (value == null || value == '') {
      errors.add('Bitte beantworten Sie: ${field.label}');
      continue;
    }
    if (field.type == 'multi_choice' && value is List && value.isEmpty) {
      errors.add('Bitte beantworten Sie: ${field.label}');
    }
  }
  return errors;
}

List<String> validateQuestionnaireSubmit(
  QuestionnaireModule module,
  Map<String, dynamic> answers,
) {
  final errors = <String>[];
  final visible = listVisibleFields(module, answers);
  for (final field in visible) {
    if (!field.required) continue;
    final value = answers[field.id];
    if (value == null || value == '') {
      errors.add('Bitte beantworten Sie: ${field.label}');
      continue;
    }
    if (field.type == 'multi_choice' && value is List && value.isEmpty) {
      errors.add('Bitte beantworten Sie: ${field.label}');
    }
  }
  if (module.moduleId == 'A' && answers['A_consent_info_read'] != 'ja') {
    errors.add('Bitte bestätigen Sie den Hinweis zur Einwilligung.');
  }
  return errors;
}
