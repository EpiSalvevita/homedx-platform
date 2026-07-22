import '../models/doctor.dart';
import '../core/api_service.dart';

class VideoCallService {
  final ApiService _apiService;

  VideoCallService(this._apiService);

  Future<VideoCallToken?> getCallToken(String appointmentId) async {
    final response = await _apiService.post(
      '/get-video-call-token',
      body: {'appointmentId': appointmentId},
    );

    if (response['success'] == true &&
        response['joinUrl'] != null &&
        response['token'] != null) {
      return VideoCallToken.fromJson(response);
    }
    return null;
  }
}
