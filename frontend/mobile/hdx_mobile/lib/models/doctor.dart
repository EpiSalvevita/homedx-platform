class Doctor {
  final String id;
  final String name;
  final String specialization;
  final String? imageUrl;
  final double rating;
  final int reviewCount;
  final String? bio;
  final List<String> languages;
  final List<AvailabilitySlot> availableSlots;

  Doctor({
    required this.id,
    required this.name,
    required this.specialization,
    this.imageUrl,
    required this.rating,
    required this.reviewCount,
    this.bio,
    required this.languages,
    required this.availableSlots,
  });

  factory Doctor.fromJson(Map<String, dynamic> json) {
    return Doctor(
      id: json['id'] as String,
      name: json['name'] as String,
      specialization: json['specialization'] as String,
      imageUrl: json['imageUrl'] as String?,
      rating: (json['rating'] as num?)?.toDouble() ?? 0.0,
      reviewCount: json['reviewCount'] as int? ?? 0,
      bio: json['bio'] as String?,
      languages: (json['languages'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          [],
      availableSlots: (json['availableSlots'] as List<dynamic>?)
              ?.map((e) => AvailabilitySlot.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
    );
  }
}

class AvailabilitySlot {
  final String id;
  final DateTime dateTime;
  final bool isAvailable;
  final Duration duration;

  AvailabilitySlot({
    required this.id,
    required this.dateTime,
    required this.isAvailable,
    this.duration = const Duration(minutes: 30),
  });

  factory AvailabilitySlot.fromJson(Map<String, dynamic> json) {
    return AvailabilitySlot(
      id: json['id'] as String,
      dateTime: DateTime.parse(json['dateTime'] as String),
      isAvailable: json['isAvailable'] as bool? ?? true,
      duration: json['duration'] != null
          ? Duration(minutes: json['duration'] as int)
          : const Duration(minutes: 30),
    );
  }
}

class Appointment {
  final String id;
  final String doctorId;
  final String doctorName;
  final DateTime appointmentTime;
  final String type; // 'online' or 'in-person'
  final String? notes;
  final String status; // 'pending', 'confirmed', 'completed', 'cancelled'

  Appointment({
    required this.id,
    required this.doctorId,
    required this.doctorName,
    required this.appointmentTime,
    required this.type,
    this.notes,
    required this.status,
  });

  factory Appointment.fromJson(Map<String, dynamic> json) {
    return Appointment(
      id: json['id'] as String,
      doctorId: json['doctorId'] as String,
      doctorName: json['doctorName'] as String,
      appointmentTime: DateTime.parse(json['appointmentTime'] as String),
      type: json['type'] as String,
      notes: json['notes'] as String?,
      status: json['status'] as String,
    );
  }
}

