class QuestionnaireShowIf {
  final String field;
  final String equals;

  const QuestionnaireShowIf({required this.field, required this.equals});

  factory QuestionnaireShowIf.fromJson(Map<String, dynamic> json) {
    return QuestionnaireShowIf(
      field: json['field'] as String,
      equals: json['equals'] as String,
    );
  }
}

class QuestionnaireField {
  final String id;
  final String type;
  final bool required;
  final String label;
  final List<String> options;
  final QuestionnaireShowIf? showIf;

  const QuestionnaireField({
    required this.id,
    required this.type,
    required this.required,
    required this.label,
    this.options = const [],
    this.showIf,
  });

  factory QuestionnaireField.fromJson(Map<String, dynamic> json) {
    return QuestionnaireField(
      id: json['id'] as String,
      type: json['type'] as String,
      required: json['required'] as bool? ?? false,
      label: json['label'] as String,
      options: (json['options'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          [],
      showIf: json['show_if'] != null
          ? QuestionnaireShowIf.fromJson(json['show_if'] as Map<String, dynamic>)
          : null,
    );
  }
}

class QuestionnaireSection {
  final String sectionId;
  final String title;
  final List<QuestionnaireField> fields;

  const QuestionnaireSection({
    required this.sectionId,
    required this.title,
    required this.fields,
  });

  factory QuestionnaireSection.fromJson(Map<String, dynamic> json) {
    return QuestionnaireSection(
      sectionId: json['section_id'] as String,
      title: json['title'] as String,
      fields: (json['fields'] as List<dynamic>)
          .map((e) => QuestionnaireField.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }
}

class QuestionnaireModule {
  final String moduleId;
  final String title;
  final String targetGroup;
  final String? timing;
  final String? purpose;
  final List<QuestionnaireSection> sections;

  const QuestionnaireModule({
    required this.moduleId,
    required this.title,
    required this.targetGroup,
    this.timing,
    this.purpose,
    required this.sections,
  });

  factory QuestionnaireModule.fromJson(Map<String, dynamic> json) {
    return QuestionnaireModule(
      moduleId: json['module_id'] as String,
      title: json['title'] as String,
      targetGroup: json['target_group'] as String,
      timing: json['timing'] as String?,
      purpose: json['purpose'] as String?,
      sections: (json['sections'] as List<dynamic>)
          .map((e) => QuestionnaireSection.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }
}

class QuestionnairePackage {
  final String project;
  final String packageVersion;
  final String language;
  final List<QuestionnaireModule> modules;

  const QuestionnairePackage({
    required this.project,
    required this.packageVersion,
    required this.language,
    required this.modules,
  });

  factory QuestionnairePackage.fromJson(Map<String, dynamic> json) {
    return QuestionnairePackage(
      project: json['project'] as String,
      packageVersion: json['package_version'] as String,
      language: json['language'] as String,
      modules: (json['modules'] as List<dynamic>)
          .map((e) => QuestionnaireModule.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }
}

class QuestionnaireModuleSummary {
  final String moduleId;
  final String title;
  final String targetGroup;
  final String? timing;
  final String? purpose;
  final String moduleVersion;
  final bool hasDraft;
  final bool hasSubmitted;
  final String? submissionId;

  const QuestionnaireModuleSummary({
    required this.moduleId,
    required this.title,
    required this.targetGroup,
    this.timing,
    this.purpose,
    required this.moduleVersion,
    required this.hasDraft,
    required this.hasSubmitted,
    this.submissionId,
  });

  factory QuestionnaireModuleSummary.fromJson(Map<String, dynamic> json) {
    return QuestionnaireModuleSummary(
      moduleId: json['moduleId'] as String,
      title: json['title'] as String,
      targetGroup: json['targetGroup'] as String,
      timing: json['timing'] as String?,
      purpose: json['purpose'] as String?,
      moduleVersion: json['moduleVersion'] as String,
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
    );
  }

  bool get isSubmitted => status == 'submitted';
  bool get isDraft => status == 'draft';
}

class QuestionnaireStep {
  final String sectionTitle;
  final List<QuestionnaireField> fields;
  final int index;
  final int total;

  const QuestionnaireStep({
    required this.sectionTitle,
    required this.fields,
    required this.index,
    required this.total,
  });
}
