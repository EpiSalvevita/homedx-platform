import 'package:hdx_mobile/core/api_service.dart';
import 'package:hdx_mobile/services/doctor_service.dart';

class MockApiService extends ApiService {
  MockApiService() : super(baseUrl: 'http://mock');

  @override
  Future<Map<String, dynamic>> post(
    String endpoint, {
    Map<String, String>? headers,
    Map<String, dynamic>? body,
    bool includeAuth = true,
  }) async {
    if (endpoint == '/get-doctors') {
      return {
        'success': true,
        'doctors': DoctorService.mockDoctors()
            .map((d) => {
                  'id': d.id,
                  'name': d.name,
                  'specialization': d.specialization,
                  'rating': d.rating,
                  'reviewCount': d.reviewCount,
                  'bio': d.bio,
                  'languages': d.languages,
                })
            .toList(),
      };
    }
    return {'success': false};
  }
}
