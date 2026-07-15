import '../models/doctor.dart';
import '../utils/test_specialization_mapping.dart';
import 'api_service.dart';

class DoctorService {
  final ApiService _apiService;

  DoctorService(this._apiService);

  Future<List<Doctor>> getAvailableDoctors({String? testTypeId}) async {
    try {
      final response = await _apiService.post(
        '/get-doctors',
        body: {
          if (testTypeId != null && testTypeId.trim().isNotEmpty)
            'testTypeId': testTypeId,
        },
      );

      if (response['success'] == true && response['doctors'] is List) {
        final doctors = (response['doctors'] as List)
            .map((e) => Doctor.fromJson(e as Map<String, dynamic>))
            .toList();
        if (testTypeId == null || testTypeId.trim().isEmpty) {
          return doctors;
        }
        final filtered = filterDoctorsForTestType(doctors, testTypeId);
        return filtered.isEmpty ? doctors : filtered;
      }
      return [];
    } catch (e) {
      throw Exception('Ärzte konnten nicht geladen werden: $e');
    }
  }

  Future<List<Doctor>> getDoctorsForTestType(String testTypeId) =>
      getAvailableDoctors(testTypeId: testTypeId);

  static List<Doctor> filterDoctorsForTestType(
    List<Doctor> doctors,
    String testTypeId,
  ) {
    return doctors
        .where((d) => TestSpecializationMapping.matches(
              testTypeId: testTypeId,
              doctorSpecialization: d.specialization,
            ))
        .toList();
  }

  Future<List<AvailabilitySlot>> getAvailableSlots(String doctorId) async {
    try {
      final response = await _apiService.post(
        '/get-doctor-slots',
        body: {'doctorId': doctorId},
      );

      if (response['success'] == true && response['slots'] is List) {
        return (response['slots'] as List)
            .map((e) => AvailabilitySlot.fromJson(e as Map<String, dynamic>))
            .toList();
      }
      return [];
    } catch (_) {
      return [];
    }
  }

  Future<BookAppointmentResult> bookAppointment({
    required String doctorId,
    required DateTime appointmentTime,
    required String type,
    String? notes,
    String? testTypeId,
  }) async {
    try {
      final response = await _apiService.post(
        '/book-appointment',
        body: {
          'doctorId': doctorId,
          'appointmentTime': appointmentTime.toUtc().toIso8601String(),
          'type': type,
          if (notes != null && notes.isNotEmpty) 'notes': notes,
          if (testTypeId != null && testTypeId.isNotEmpty) 'testTypeId': testTypeId,
        },
      );

      if (response['success'] == true) {
        return BookAppointmentResult.success(
          response['appointmentId']?.toString(),
        );
      }
      return BookAppointmentResult.failure(
        response['error']?.toString() ?? 'Booking failed',
      );
    } catch (e) {
      return BookAppointmentResult.failure(e.toString());
    }
  }

  Future<List<DoctorAvailabilityRule>> getDoctorAvailability() async {
    final response = await _apiService.post('/get-doctor-availability');
    if (response['success'] == true && response['availability'] is List) {
      return (response['availability'] as List)
          .map((e) => DoctorAvailabilityRule.fromJson(e as Map<String, dynamic>))
          .toList();
    }
    return [];
  }

  Future<bool> setDoctorAvailability(List<DoctorAvailabilityRule> rules) async {
    final response = await _apiService.post(
      '/set-doctor-availability',
      body: {
        'availability': rules.map((r) => r.toJson()).toList(),
      },
    );
    return response['success'] == true;
  }

  /// Mock doctors for unit tests.
  static List<Doctor> mockDoctors() => [
        Doctor(
          id: 'doc1',
          name: 'Dr. Sarah Müller',
          specialization: 'Allgemeinmedizin',
          rating: 4.8,
          reviewCount: 127,
          bio: 'Erfahrene Allgemeinmedizinerin mit über 10 Jahren Erfahrung',
          languages: ['Deutsch', 'Englisch', 'Türkisch'],
          availableSlots: [],
        ),
        Doctor(
          id: 'doc6',
          name: 'Dr. Klaus Becker',
          specialization: 'Rheumatologie',
          rating: 4.8,
          reviewCount: 112,
          bio: 'Rheumatologe mit Schwerpunkt auf entzündlichen Gelenkerkrankungen',
          languages: ['Deutsch'],
          availableSlots: [],
        ),
      ];
}
