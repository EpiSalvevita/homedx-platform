import '../models/questionnaire/questionnaire_models.dart';

/// Human-readable answer text for the overview and the completion page.
/// Shows what was chosen; never computes a score or a summary value.
String formatAnswer(QuestionnaireItem item, Object? value) {
  if (value == null) return '';
  switch (item.type) {
    case 'rank_top3':
    case 'rank_top5':
      final list = value is List ? value : const [];
      return [for (var i = 0; i < list.length; i++) '${i + 1}. ${list[i]}'].join(', ');
    case 'matrix_presence':
    case 'matrix_importance':
      if (value is! Map) return '';
      return item.options
          .where((row) => value[row] != null)
          .map((row) => '$row: ${value[row]}')
          .join('\n');
    default:
      if (value is List) return value.map((e) => e.toString()).join(', ');
      return value.toString();
  }
}
