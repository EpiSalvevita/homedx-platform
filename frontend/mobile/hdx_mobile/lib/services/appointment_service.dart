import '../models/doctor.dart';
import 'api_service.dart';

class AppointmentService {
  final ApiService _apiService;

  AppointmentService(this._apiService);

  Future<List<Appointment>> listAppointments() async {
    final response = await _apiService.post('/list-appointments');
    if (response['success'] == true && response['appointments'] is List) {
      return (response['appointments'] as List)
          .map((e) => Appointment.fromJson(e as Map<String, dynamic>))
          .toList();
    }
    return [];
  }

  Future<Appointment?> getAppointment(String appointmentId) async {
    final response = await _apiService.post(
      '/get-appointment',
      body: {'appointmentId': appointmentId},
    );
    if (response['success'] == true && response['appointment'] != null) {
      return Appointment.fromJson(
        response['appointment'] as Map<String, dynamic>,
      );
    }
    return null;
  }

  Future<bool> cancelAppointment(String appointmentId, {String? message}) async {
    final response = await _apiService.post(
      '/cancel-appointment',
      body: {
        'appointmentId': appointmentId,
        if (message != null && message.trim().isNotEmpty) 'message': message.trim(),
      },
    );
    return response['success'] == true;
  }
}
