import '../l10n/app_localizations.dart';
import '../models/questionnaire/questionnaire_models.dart';
import 'questionnaire_branching.dart';

/// Client-side checks for early feedback. The server validates again on save and
/// submit and is the only authority. Messages name the question, never the value.

List<String> validateQuestionnaireStep(
  AppLocalizations l10n,
  List<QuestionnaireItem> items,
  Map<String, dynamic> answers,
) {
  final errors = <String>[];
  for (final item in items) {
    if (!item.required) continue;
    if (!_isComplete(item, answers[item.id])) {
      errors.add(l10n.questAnswerRequired(item.text));
    }
  }
  return errors;
}

List<String> validateQuestionnaireSubmit(
  AppLocalizations l10n,
  QuestionnaireModule module,
  Map<String, dynamic> answers,
) {
  final visible = visibleItemIds(module, answers);
  final items = module.items
      .where((i) => visible.contains(i.id) && !i.isUiControl)
      .toList();
  return validateQuestionnaireStep(l10n, items, answers);
}

bool _isComplete(QuestionnaireItem item, Object? value) {
  if (!isAnswered(value)) return false;
  switch (item.responseContract.kind) {
    case 'matrix':
      final row = value as Map;
      return item.options.every((o) => row[o] != null);
    case 'ranked_codes':
      final min = item.responseContract.minimumSelected ?? 1;
      return value is List && value.length >= min;
    default:
      return true;
  }
}
