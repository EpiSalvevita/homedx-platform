import '../models/questionnaire/questionnaire_models.dart';
import 'questionnaire_branching.dart';

/// Demo build switch: flutter build web --dart-define=HDX_QUESTIONNAIRE_DEMO=true
///
/// The demo build never writes questionnaire data to a server. Answers stay in
/// memory and the completion page reads them from there. Synthetic answers can
/// therefore not reach a real endpoint, even by mistake.
const bool kQuestionnaireDemoBuild = bool.fromEnvironment('HDX_QUESTIONNAIRE_DEMO');

/// Synthetic example answers for the review demo. Values are invented:
/// the first option of each list, the number 4 for scales, fixed sample text.
Map<String, dynamic> syntheticDemoAnswers(QuestionnaireModule module) {
  final items = module.items.toList();
  final answers = <String, dynamic>{};

  for (var pass = 0; pass < 6; pass++) {
    final visible = visibleItemIds(module, answers);
    for (final item in items) {
      if (!visible.contains(item.id) || answers.containsKey(item.id)) continue;
      final value = _syntheticValue(item, answers);
      if (value != null) answers[item.id] = value;
    }
  }
  return answers;
}

Object? _syntheticValue(QuestionnaireItem item, Map<String, dynamic> answers) {
  final c = item.responseContract;
  final restricted = item.optionSource?.intersection ?? const <String>[];
  final parent = item.optionSource == null
      ? const <Object?>[]
      : (answers[item.optionSource!.item] as List? ?? const []);
  final allowed = item.options
      .where((o) => !restricted.contains(o) || parent.contains(o))
      .toList();

  switch (c.kind) {
    case 'categorical_single':
      return item.options.isEmpty ? null : item.options.first;
    case 'categorical_multi':
      return allowed.isEmpty ? null : [allowed.first];
    case 'ranked_codes':
      final n = c.minimumSelected ?? 1;
      return item.options.take(n).toList();
    case 'matrix':
      final rating = c.ratings.isEmpty ? null : c.ratings.first;
      return rating == null
          ? null
          : {for (final o in item.options) o: rating};
    case 'integer':
      return 4.clamp(c.minimum ?? 0, c.maximum ?? 10);
    case 'string':
      return 'Erfundene Beispielangabe – keine reale Person oder Praxis.';
    default:
      return null;
  }
}
