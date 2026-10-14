/// RheumaCheck V04 catalogue models. The server is the source of truth for
/// content, visibility and validation; these types only describe what the app
/// receives and renders.
library;

class QuestionnaireItem {
  final String id;
  final String type;
  final bool required;
  final String text;
  final String? help;
  final List<String> options;
  final List<String> exclusiveOptions;
  final Map<String, dynamic>? visibilityRule;
  final QuestionnaireOptionSource? optionSource;
  final QuestionnaireResponseContract responseContract;

  const QuestionnaireItem({
    required this.id,
    required this.type,
    required this.required,
    required this.text,
    this.help,
    this.options = const [],
    this.exclusiveOptions = const [],
    this.visibilityRule,
    this.optionSource,
    required this.responseContract,
  });

  factory QuestionnaireItem.fromJson(Map<String, dynamic> json) {
    return QuestionnaireItem(
      id: json['id'] as String,
      type: json['type'] as String,
      required: json['required'] as bool? ?? false,
      text: json['text'] as String,
      help: json['help'] as String?,
      options: _stringList(json['options']),
      exclusiveOptions: _stringList(json['exclusiveOptions']),
      visibilityRule: json['visibilityRule'] == null
          ? null
          : Map<String, dynamic>.from(json['visibilityRule'] as Map),
      optionSource: json['optionSource'] == null
          ? null
          : QuestionnaireOptionSource.fromJson(
              Map<String, dynamic>.from(json['optionSource'] as Map),
            ),
      responseContract: QuestionnaireResponseContract.fromJson(
        Map<String, dynamic>.from(json['responseContract'] as Map? ?? const {}),
      ),
    );
  }

  bool get isUiControl => responseContract.kind == 'ui_control_not_research_response';
}

class QuestionnaireOptionSource {
  final String item;
  final List<String> intersection;

  const QuestionnaireOptionSource({required this.item, this.intersection = const []});

  factory QuestionnaireOptionSource.fromJson(Map<String, dynamic> json) {
    return QuestionnaireOptionSource(
      item: json['item'] as String,
      intersection: _stringList(json['intersection']),
    );
  }
}

class QuestionnaireResponseContract {
  final String kind;
  final int? minimum;
  final int? maximum;
  final int? maximumLength;
  final int? minimumSelected;
  final int? maximumSelected;
  final List<String> ratings;

  const QuestionnaireResponseContract({
    required this.kind,
    this.minimum,
    this.maximum,
    this.maximumLength,
    this.minimumSelected,
    this.maximumSelected,
    this.ratings = const [],
  });

  factory QuestionnaireResponseContract.fromJson(Map<String, dynamic> json) {
    return QuestionnaireResponseContract(
      kind: json['kind'] as String? ?? '',
      minimum: json['minimum'] as int?,
      maximum: json['maximum'] as int?,
      maximumLength: json['maximumLength'] as int?,
      minimumSelected: json['minimumSelected'] as int?,
      maximumSelected: json['maximumSelected'] as int?,
      ratings: _stringList(json['ratings']),
    );
  }
}

class QuestionnaireSection {
  final String id;
  final String title;
  final String? intro;
  final List<QuestionnaireItem> items;

  const QuestionnaireSection({
    required this.id,
    required this.title,
    this.intro,
    required this.items,
  });

  factory QuestionnaireSection.fromJson(Map<String, dynamic> json) {
    return QuestionnaireSection(
      id: json['id'] as String,
      title: json['title'] as String,
      intro: json['intro'] as String?,
      items: (json['items'] as List<dynamic>)
          .map((e) => QuestionnaireItem.fromJson(Map<String, dynamic>.from(e as Map)))
          .toList(),
    );
  }
}

class QuestionnaireModule {
  /// API key: A, B, C, CFU or D.
  final String moduleId;
  /// Catalogue id, for example RC-A.
  final String catalogueId;
  final String title;
  final String audience;
  final String? estimatedTime;
  final List<QuestionnaireSection> sections;

  const QuestionnaireModule({
    required this.moduleId,
    required this.catalogueId,
    required this.title,
    required this.audience,
    this.estimatedTime,
    required this.sections,
  });

  factory QuestionnaireModule.fromJson(Map<String, dynamic> json) {
    return QuestionnaireModule(
      moduleId: json['moduleId'] as String,
      catalogueId: json['catalogueId'] as String? ?? '',
      title: json['title'] as String,
      audience: json['audience'] as String? ?? '',
      estimatedTime: json['estimatedTime'] as String?,
      sections: (json['sections'] as List<dynamic>)
          .map((e) => QuestionnaireSection.fromJson(Map<String, dynamic>.from(e as Map)))
          .toList(),
    );
  }

  Iterable<QuestionnaireItem> get items => sections.expand((s) => s.items);
}

class QuestionnaireModuleSummary {
  final String moduleId;
  final String catalogueId;
  final String title;
  final String targetGroup;
  final String? timing;
  final String moduleVersion;
  /// not_assigned | available | in_progress | completed
  final String status;
  final bool hasDraft;
  final bool hasSubmitted;
  final String? submissionId;

  const QuestionnaireModuleSummary({
    required this.moduleId,
    required this.catalogueId,
    required this.title,
    required this.targetGroup,
    this.timing,
    required this.moduleVersion,
    required this.status,
    required this.hasDraft,
    required this.hasSubmitted,
    this.submissionId,
  });

  bool get isAssignable => status != 'not_assigned';

  factory QuestionnaireModuleSummary.fromJson(Map<String, dynamic> json) {
    return QuestionnaireModuleSummary(
      moduleId: json['moduleId'] as String,
      catalogueId: json['catalogueId'] as String? ?? '',
      title: json['title'] as String,
      targetGroup: json['targetGroup'] as String? ?? '',
      timing: json['timing'] as String?,
      moduleVersion: json['moduleVersion'] as String,
      status: json['status'] as String? ?? 'available',
      hasDraft: json['hasDraft'] as bool? ?? false,
      hasSubmitted: json['hasSubmitted'] as bool? ?? false,
      submissionId: json['submissionId'] as String?,
    );
  }
}

class QuestionnaireSubmission {
  final String id;
  final String moduleId;
  final String moduleVersion;
  final String respondentType;
  final String status;
  final String consentStatus;
  final String language;
  final Map<String, dynamic> answers;
  final String? linkedRapidTestId;
  final DateTime? submittedAt;
  final DateTime createdAt;
  final DateTime updatedAt;
  /// Concurrency token. Send it back as expectedUpdatedAt when saving again.
  final String revision;

  const QuestionnaireSubmission({
    required this.id,
    required this.moduleId,
    required this.moduleVersion,
    required this.respondentType,
    required this.status,
    required this.consentStatus,
    required this.language,
    required this.answers,
    this.linkedRapidTestId,
    this.submittedAt,
    required this.createdAt,
    required this.updatedAt,
    required this.revision,
  });

  factory QuestionnaireSubmission.fromJson(Map<String, dynamic> json) {
    return QuestionnaireSubmission(
      id: json['id'] as String,
      moduleId: json['moduleId'] as String,
      moduleVersion: json['moduleVersion'] as String,
      respondentType: json['respondentType'] as String,
      status: (json['status'] as String? ?? 'draft').toLowerCase(),
      consentStatus: (json['consentStatus'] as String? ?? 'not_applicable').toLowerCase(),
      language: json['language'] as String? ?? 'de-DE',
      answers: Map<String, dynamic>.from(json['answers'] as Map? ?? {}),
      linkedRapidTestId: json['linkedRapidTestId'] as String?,
      submittedAt: json['submittedAt'] != null
          ? DateTime.parse(json['submittedAt'] as String).toLocal()
          : null,
      createdAt: DateTime.parse(json['createdAt'] as String).toLocal(),
      updatedAt: DateTime.parse(json['updatedAt'] as String).toLocal(),
      revision: json['revision'] as String? ?? json['updatedAt'] as String,
    );
  }

  bool get isSubmitted => status == 'submitted';
  bool get isDraft => status == 'draft';
}

List<String> _stringList(Object? raw) {
  if (raw is! List) return const [];
  return raw.map<String>((e) => e.toString()).toList();
}
