import '../models/doctor.dart';
import '../utils/test_specialization_mapping.dart';

class DoctorService {
  DoctorService();

  /// Get list of available doctors.
  ///
  /// When [testTypeId] is provided, the list is pre-filtered to specialists
  /// that match the test (e.g. `rheumacheck` -> Rheumatologie). When no
  /// matching specialist exists, the full list is returned so the user can
  /// still book a generalist.
  Future<List<Doctor>> getAvailableDoctors({String? testTypeId}) async {
    try {
      await Future.delayed(const Duration(milliseconds: 500)); // Simulate API call
      final all = _getMockDoctors();
      if (testTypeId == null || testTypeId.trim().isEmpty) {
        return all;
      }
      final filtered = filterDoctorsForTestType(all, testTypeId);
      return filtered.isEmpty ? all : filtered;
    } catch (e) {
      return _getMockDoctors();
    }
  }

  /// Convenience wrapper used by the post-positive-result flow.
  Future<List<Doctor>> getDoctorsForTestType(String testTypeId) =>
      getAvailableDoctors(testTypeId: testTypeId);

  /// Pure filter so we can unit-test the matching logic without async/IO.
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

  /// Get available time slots for a specific doctor
  Future<List<AvailabilitySlot>> getAvailableSlots(String doctorId) async {
    try {
      await Future.delayed(const Duration(milliseconds: 300));

      final now = DateTime.now();
      final slots = <AvailabilitySlot>[];

      for (int day = 0; day < 7; day++) {
        final date = now.add(Duration(days: day));

        if (date.weekday == 6 || date.weekday == 7) continue;

        for (int hour = 9; hour < 17; hour++) {
          final slotDateTime = DateTime(
            date.year,
            date.month,
            date.day,
            hour,
            0,
          );

          if (slotDateTime.isAfter(now)) {
            slots.add(AvailabilitySlot(
              id: '${doctorId}_${slotDateTime.millisecondsSinceEpoch}',
              dateTime: slotDateTime,
              isAvailable: true,
            ));
          }
        }
      }

      return slots;
    } catch (e) {
      return [];
    }
  }

  /// Book an appointment.
  ///
  /// [testTypeId] is optional context describing the test that triggered the
  /// booking (e.g. a positive RheumaCheck). When wired to the backend, this
  /// will be forwarded so the appointment can be linked to the originating
  /// rapid test.
  Future<bool> bookAppointment({
    required String doctorId,
    required DateTime appointmentTime,
    required String type,
    String? notes,
    String? testTypeId,
  }) async {
    try {
      await Future.delayed(const Duration(seconds: 1));

      // Future API call:
      // final response = await _apiService.post(
      //   '/book-appointment',
      //   body: {
      //     'doctorId': doctorId,
      //     'appointmentTime': appointmentTime.toIso8601String(),
      //     'type': type,
      //     'notes': notes,
      //     'testTypeId': testTypeId,
      //   },
      //   includeAuth: true,
      // );
      // return response['success'] == true;

      return true;
    } catch (e) {
      return false;
    }
  }

  /// Mock doctors. The list mixes generalists with specialists so the
  /// test-type filter has something to bind to. Exposed as a static factory
  /// so widget/unit tests can build the same dataset without instantiating
  /// the service.
  static List<Doctor> mockDoctors() => [
        Doctor(
          id: 'doc1',
          name: 'Dr. Sarah Müller',
          specialization: 'Allgemeinmedizin',
          rating: 4.8,
          reviewCount: 127,
          bio: 'Erfahrene Allgemeinmedizinerin mit über 10 Jahren Erfahrung',
          languages: ['Deutsch', 'Englisch'],
          availableSlots: [],
        ),
        Doctor(
          id: 'doc2',
          name: 'Dr. Michael Schmidt',
          specialization: 'Innere Medizin',
          rating: 4.9,
          reviewCount: 203,
          bio: 'Spezialist für Innere Medizin und Präventivmedizin',
          languages: ['Deutsch', 'Englisch', 'Französisch'],
          availableSlots: [],
        ),
        Doctor(
          id: 'doc3',
          name: 'Dr. Anna Weber',
          specialization: 'Kardiologie',
          rating: 4.7,
          reviewCount: 89,
          bio: 'Kardiologin mit Fokus auf präventive Herzgesundheit',
          languages: ['Deutsch', 'Englisch'],
          availableSlots: [],
        ),
        Doctor(
          id: 'doc4',
          name: 'Dr. Thomas Fischer',
          specialization: 'Dermatologie',
          rating: 4.6,
          reviewCount: 156,
          bio: 'Dermatologe mit Expertise in Hautkrebsvorsorge',
          languages: ['Deutsch', 'Englisch', 'Spanisch'],
          availableSlots: [],
        ),
        Doctor(
          id: 'doc5',
          name: 'Dr. Lisa Hoffmann',
          specialization: 'Psychiatrie',
          rating: 4.9,
          reviewCount: 94,
          bio: 'Psychiaterin mit Schwerpunkt auf Online-Beratung',
          languages: ['Deutsch', 'Englisch'],
          availableSlots: [],
        ),
        Doctor(
          id: 'doc6',
          name: 'Dr. Klaus Becker',
          specialization: 'Rheumatologie',
          rating: 4.8,
          reviewCount: 112,
          bio: 'Rheumatologe mit Schwerpunkt auf entzündlichen Gelenkerkrankungen',
          languages: ['Deutsch', 'Englisch'],
          availableSlots: [],
        ),
        Doctor(
          id: 'doc7',
          name: 'Dr. Julia Schwarz',
          specialization: 'Pulmologie',
          rating: 4.7,
          reviewCount: 78,
          bio: 'Pulmologin mit Erfahrung in Atemwegserkrankungen und Post-COVID',
          languages: ['Deutsch', 'Englisch'],
          availableSlots: [],
        ),
        Doctor(
          id: 'doc8',
          name: 'Dr. Markus Lange',
          specialization: 'Endokrinologie',
          rating: 4.7,
          reviewCount: 64,
          bio: 'Endokrinologe mit Fokus auf Hormon- und Vitaminhaushalt',
          languages: ['Deutsch', 'Englisch'],
          availableSlots: [],
        ),
      ];

  List<Doctor> _getMockDoctors() => mockDoctors();
}
