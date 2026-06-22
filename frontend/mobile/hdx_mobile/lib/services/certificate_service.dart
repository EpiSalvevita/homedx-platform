import '../models/certificate.dart';
import 'api_service.dart';

class CertificateService {
  final ApiService _api;

  CertificateService(this._api);

  Future<List<Certificate>> listCertificates() async {
    final response = await _api.post('list-certificates', body: {});
    if (response['success'] != true) {
      throw Exception(response['error']?.toString() ?? 'Failed to load certificates');
    }
    final raw = response['certificates'];
    if (raw is! List) return [];
    return raw
        .whereType<Map>()
        .map((m) => Certificate.fromJson(Map<String, dynamic>.from(m)))
        .toList();
  }

  Future<Certificate> getCertificate(String certificateId) async {
    final response = await _api.post(
      'get-certificate',
      body: {'certificateId': certificateId},
    );
    if (response['success'] != true || response['certificate'] == null) {
      throw Exception(response['error']?.toString() ?? 'Failed to load certificate');
    }
    return Certificate.fromJson(
      Map<String, dynamic>.from(response['certificate'] as Map),
    );
  }

  Future<List<int>> downloadPdfBytes(String certificateId) async {
    final response = await _api.post(
      'get-certificate-pdf',
      body: {'certificateId': certificateId},
    );
    if (response['success'] != true || response['pdfBase64'] == null) {
      throw Exception(response['error']?.toString() ?? 'Failed to download PDF');
    }
    return Uri.dataFromString(
      response['pdfBase64'] as String,
      mimeType: 'application/pdf',
      encoding: null,
    ).data?.contentAsBytes() ?? [];
  }
}
