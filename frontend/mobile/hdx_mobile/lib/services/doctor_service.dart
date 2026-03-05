import '../models/doctor.dart';

class DoctorService {
  DoctorService();

  /// Get list of available doctors
  Future<List<Doctor>> getAvailableDoctors() async {
    try {
      // For now, return mock data. Later this can be replaced with actual API call
      await Future.delayed(const Duration(milliseconds: 500)); // Simulate API call
      
      return _getMockDoctors();
    } catch (e) {
      // If API fails, return mock data
      return _getMockDoctors();
    }
  }

  /// Get available time slots for a specific doctor
  Future<List<AvailabilitySlot>> getAvailableSlots(String doctorId) async {
    try {
      await Future.delayed(const Duration(milliseconds: 300));
      
      // Generate mock available slots for the next 7 days
      final now = DateTime.now();
      final slots = <AvailabilitySlot>[];
      
      for (int day = 0; day < 7; day++) {
        final date = now.add(Duration(days: day));
        
        // Skip weekends for simplicity
        if (date.weekday == 6 || date.weekday == 7) continue;
        
        // Generate slots from 9 AM to 5 PM
        for (int hour = 9; hour < 17; hour++) {
          final slotDateTime = DateTime(
            date.year,
            date.month,
            date.day,
            hour,
            0,
          );
          
          // Only show future slots
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

  /// Book an appointment
  Future<bool> bookAppointment({
    required String doctorId,
    required DateTime appointmentTime,
    required String type,
    String? notes,
  }) async {
    try {
      // Simulate API call
      await Future.delayed(const Duration(seconds: 1));
      
      // In a real app, this would make an API call:
      // final response = await _apiService.post(
      //   '/book-appointment',
      //   body: {
      //     'doctorId': doctorId,
      //     'appointmentTime': appointmentTime.toIso8601String(),
      //     'type': type,
      //     'notes': notes,
      //   },
      //   includeAuth: true,
      // );
      // return response['success'] == true;
      
      return true; // Mock success
    } catch (e) {
      return false;
    }
  }

  /// Get mock doctors data
  List<Doctor> _getMockDoctors() {
    return [
      Doctor(
        id: 'doc1',
        name: 'Dr. Sarah Müller',
        specialization: 'Allgemeinmedizin',
        rating: 4.8,
        reviewCount: 127,
        bio: 'Erfahrener Allgemeinmediziner mit über 10 Jahren Erfahrung',
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
    ];
  }
}

