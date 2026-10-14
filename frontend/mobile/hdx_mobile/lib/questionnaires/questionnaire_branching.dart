import '../models/questionnaire/questionnaire_models.dart';

/// Client-side visibility for showing and hiding questions while answering.
///
/// The server engine (backend/src/utils/questionnaire-v04-engine.ts) stays
/// authoritative and re-evaluates everything on save and submit. These rules
/// mirror it so the screen never shows a question the server would not accept.
///
/// Rules:
/// - An unanswered parent never satisfies a rule, including `neq`.
/// - A hidden parent hides its children.
/// - A cycle is treated as hidden (the server rejects such catalogues).

bool isAnswered(Object? value) {
  if (value == null || value == '') return false;
  if (value is List) return value.isNotEmpty;
  if (value is Map) return value.isNotEmpty;
  return true;
}

Set<String> visibleItemIds(QuestionnaireModule module, Map<String, dynamic> answers) {
  final byId = {for (final item in module.items) item.id: item};
  final memo = <String, bool>{};
  final visiting = <String>{};

  bool isVisible(String id) {
    final cached = memo[id];
    if (cached != null) return cached;
    if (!visiting.add(id)) return false;
    final item = byId[id];
    final result = item != null && _ruleHolds(item.visibilityRule, answers, isVisible);
    visiting.remove(id);
    memo[id] = result;
    return result;
  }

  return {for (final id in byId.keys) if (isVisible(id)) id};
}

bool _ruleHolds(
  Map<String, dynamic>? rule,
  Map<String, dynamic> answers,
  bool Function(String id) isVisible,
) {
  if (rule == null) return true;
  if (rule.containsKey('any')) {
    return (rule['any'] as List).any((r) => _ruleHolds(_asMap(r), answers, isVisible));
  }
  if (rule.containsKey('all')) {
    return (rule['all'] as List).every((r) => _ruleHolds(_asMap(r), answers, isVisible));
  }
  if (rule.containsKey('feature')) return false;

  final itemId = rule['item'] as String?;
  if (itemId == null || !isVisible(itemId)) return false;
  final value = answers[itemId];
  if (!isAnswered(value)) return false;

  switch (rule['op']) {
    case 'answered':
      return true;
    case 'eq':
      return value == rule['value'];
    case 'neq':
      return value != rule['value'];
    case 'in':
      return value is String && (rule['values'] as List? ?? const []).contains(value);
    case 'contains':
      return value is List && value.contains(rule['value']);
    default:
      return false;
  }
}

Map<String, dynamic>? _asMap(Object? raw) =>
    raw == null ? null : Map<String, dynamic>.from(raw as Map);

/// Drops answers for items that are no longer visible. Mirrors the server's pruning.
Map<String, dynamic> pruneAnswers(QuestionnaireModule module, Map<String, dynamic> answers) {
  final visible = visibleItemIds(module, answers);
  return {
    for (final entry in answers.entries)
      if (visible.contains(entry.key)) entry.key: entry.value,
  };
}

class QuestionnaireStep {
  final QuestionnaireSection section;
  final List<QuestionnaireItem> items;
  final int index;
  final int total;

  const QuestionnaireStep({
    required this.section,
    required this.items,
    required this.index,
    required this.total,
  });
}

/// One step per section that has at least one visible, answerable question.
/// UI-only controls (for example review) are never rendered as questions.
List<QuestionnaireStep> buildQuestionnaireSteps(
  QuestionnaireModule module,
  Map<String, dynamic> answers,
) {
  final visible = visibleItemIds(module, answers);
  final sections = <QuestionnaireSection>[];
  final itemsBySection = <List<QuestionnaireItem>>[];

  for (final section in module.sections) {
    final items = section.items
        .where((i) => visible.contains(i.id) && !i.isUiControl)
        .toList();
    if (items.isEmpty) continue;
    sections.add(section);
    itemsBySection.add(items);
  }

  return [
    for (var i = 0; i < sections.length; i++)
      QuestionnaireStep(
        section: sections[i],
        items: itemsBySection[i],
        index: i + 1,
        total: sections.length,
      ),
  ];
}
