import '../models/legal_page.dart';
import '../core/api_service.dart';

class LegalPageService {
  final ApiService _api;

  LegalPageService(this._api);

  /// [type] must match a backend `LegalPageType` value, e.g.
  /// `TERMS_CONDITIONS`, `PRIVACY_POLICY`, `IMPRESSUM`, `COOKIE_POLICY`.
  Future<LegalPage> getLegalPage(String type, {String language = 'de'}) async {
    final response = await _api.post(
      'get-legal-page',
      body: {'type': type, 'language': language},
    );
    if (response['success'] != true || response['legalPage'] == null) {
      throw Exception(response['error']?.toString() ?? 'Failed to load legal page');
    }
    return LegalPage.fromJson(
      Map<String, dynamic>.from(response['legalPage'] as Map),
    );
  }
}
