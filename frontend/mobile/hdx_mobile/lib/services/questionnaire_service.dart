import '../core/api_service.dart';
import '../models/questionnaire/questionnaire_models.dart';

/// Failure reported by the questionnaire API. `code` is one of the server's codes
/// (CONSENT_REQUIRED, REVISION_CONFLICT, NOT_ASSIGNED) or `validation` when the
/// server rejected answers. `validation` holds item ids and codes, never answer values.
class QuestionnaireApiException implements Exception {
  final String code;
  final List<String> validation;

  const QuestionnaireApiException(this.code, [this.validation = const []]);

  @override
  String toString() => 'QuestionnaireApiException($code)';
}

class QuestionnaireService {
  final ApiService _apiService;

  QuestionnaireService(this._apiService);

  Future<List<QuestionnaireModuleSummary>> listModules() async {
    final response = await _apiService.post('/get-questionnaire-modules');
    if (response['success'] == true && response['modules'] is List) {
      return (response['modules'] as List)
          .map((e) => QuestionnaireModuleSummary.fromJson(Map<String, dynamic>.from(e as Map)))
          .toList();
    }
    return [];
  }

  Future<QuestionnaireModule> getDefinition(String moduleId) async {
    final response = await _apiService.post(
      '/get-questionnaire-definition',
      body: {'moduleId': moduleId},
    );
    _throwIfFailed(response);
    final definition = response['definition'];
    if (definition is! Map) {
      throw const QuestionnaireApiException('NOT_FOUND');
    }
    return QuestionnaireModule.fromJson(Map<String, dynamic>.from(definition));
  }

  Future<QuestionnaireSubmission> saveDraft({
    required String moduleId,
    required Map<String, dynamic> answers,
    String? submissionId,
    String? expectedUpdatedAt,
    String? linkedRapidTestId,
    String? consentStatus,
  }) async {
    final response = await _apiService.post(
      '/save-questionnaire-draft',
      body: {
        'moduleId': moduleId,
        'answers': answers,
        if (submissionId != null) 'submissionId': submissionId,
        if (expectedUpdatedAt != null) 'expectedUpdatedAt': expectedUpdatedAt,
        if (linkedRapidTestId != null) 'linkedRapidTestId': linkedRapidTestId,
        if (consentStatus != null) 'consentStatus': consentStatus,
      },
    );
    return _submissionFrom(response);
  }

  Future<QuestionnaireSubmission> submit({
    required String moduleId,
    required Map<String, dynamic> answers,
    String? submissionId,
    String? expectedUpdatedAt,
    String? linkedRapidTestId,
    String? consentStatus,
  }) async {
    final response = await _apiService.post(
      '/submit-questionnaire',
      body: {
        'moduleId': moduleId,
        'answers': answers,
        if (submissionId != null) 'submissionId': submissionId,
        if (expectedUpdatedAt != null) 'expectedUpdatedAt': expectedUpdatedAt,
        if (linkedRapidTestId != null) 'linkedRapidTestId': linkedRapidTestId,
        if (consentStatus != null) 'consentStatus': consentStatus,
      },
    );
    return _submissionFrom(response);
  }

  Future<QuestionnaireSubmission?> getSubmission({
    String? submissionId,
    String? moduleId,
    String? linkedRapidTestId,
  }) async {
    final response = await _apiService.post(
      '/get-questionnaire-submission',
      body: {
        if (submissionId != null) 'submissionId': submissionId,
        if (moduleId != null) 'moduleId': moduleId,
        if (linkedRapidTestId != null) 'linkedRapidTestId': linkedRapidTestId,
      },
    );
    if (response['success'] == true && response['submission'] is Map) {
      return QuestionnaireSubmission.fromJson(
        Map<String, dynamic>.from(response['submission'] as Map),
      );
    }
    return null;
  }

  QuestionnaireSubmission _submissionFrom(Map<String, dynamic> response) {
    _throwIfFailed(response);
    final submission = response['submission'];
    if (submission is! Map) {
      throw const QuestionnaireApiException('NO_SUBMISSION');
    }
    return QuestionnaireSubmission.fromJson(Map<String, dynamic>.from(submission));
  }

  void _throwIfFailed(Map<String, dynamic> response) {
    if (response['success'] == true) return;
    final validation = (response['validation'] as List?)?.map<String>((e) => e.toString()).toList() ?? const <String>[];
    final error = response['error'] as String? ?? 'REQUEST_FAILED';
    // A validation rejection arrives as error "Invalid request" with a validation list.
    if (validation.isNotEmpty) {
      throw QuestionnaireApiException('VALIDATION', validation);
    }
    throw QuestionnaireApiException(error);
  }
}
