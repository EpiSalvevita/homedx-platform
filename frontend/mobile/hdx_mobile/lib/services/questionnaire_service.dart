import '../core/api_service.dart';
import '../models/questionnaire/questionnaire_models.dart';

class QuestionnaireService {
  final ApiService _apiService;

  QuestionnaireService(this._apiService);

  Future<List<QuestionnaireModuleSummary>> listModules() async {
    final response = await _apiService.post('/get-questionnaire-modules');
    if (response['success'] == true && response['modules'] is List) {
      return (response['modules'] as List)
          .map((e) => QuestionnaireModuleSummary.fromJson(e as Map<String, dynamic>))
          .toList();
    }
    return [];
  }

  Future<QuestionnaireModule?> getDefinition(String moduleId) async {
    final response = await _apiService.post(
      '/get-questionnaire-definition',
      body: {'moduleId': moduleId},
    );
    if (response['success'] == true && response['definition'] is Map) {
      return QuestionnaireModule.fromJson(response['definition'] as Map<String, dynamic>);
    }
    return null;
  }

  Future<QuestionnaireSubmission?> saveDraft({
    required String moduleId,
    required Map<String, dynamic> answers,
    String? submissionId,
    String? linkedRapidTestId,
    String? consentStatus,
  }) async {
    final response = await _apiService.post(
      '/save-questionnaire-draft',
      body: {
        'moduleId': moduleId,
        'answers': answers,
        if (submissionId != null) 'submissionId': submissionId,
        if (linkedRapidTestId != null) 'linkedRapidTestId': linkedRapidTestId,
        if (consentStatus != null) 'consentStatus': consentStatus,
      },
    );
    if (response['success'] == true && response['submission'] is Map) {
      return QuestionnaireSubmission.fromJson(response['submission'] as Map<String, dynamic>);
    }
    return null;
  }

  Future<QuestionnaireSubmission?> submit({
    required String moduleId,
    required Map<String, dynamic> answers,
    String? submissionId,
    String? linkedRapidTestId,
    String? consentStatus,
  }) async {
    final response = await _apiService.post(
      '/submit-questionnaire',
      body: {
        'moduleId': moduleId,
        'answers': answers,
        if (submissionId != null) 'submissionId': submissionId,
        if (linkedRapidTestId != null) 'linkedRapidTestId': linkedRapidTestId,
        if (consentStatus != null) 'consentStatus': consentStatus,
      },
    );
    if (response['success'] == true && response['submission'] is Map) {
      return QuestionnaireSubmission.fromJson(response['submission'] as Map<String, dynamic>);
    }
    final error = response['error'] as String?;
    if (error != null && error.isNotEmpty) {
      throw Exception(error);
    }
    return null;
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
      return QuestionnaireSubmission.fromJson(response['submission'] as Map<String, dynamic>);
    }
    return null;
  }
}
