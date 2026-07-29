import 'package:flutter_test/flutter_test.dart';
import 'package:hdx_mobile/models/doctor.dart';

void main() {
  group('Appointment.fromJson', () {
    test('parses appointment with join eligibility', () {
      final future = DateTime.now().toUtc().add(const Duration(days: 2));
      final appointment = Appointment.fromJson({
        'id': 'apt1',
        'doctorId': 'doc1',
        'doctorName': 'Dr. Test',
        'patientId': 'pat1',
        'patientName': 'Patient Test',
        'appointmentTime': future.toIso8601String(),
        'type': 'online',
        'status': 'confirmed',
        'durationMin': 30,
        'canJoin': true,
        'videoRoomUrl': 'https://example.daily.co/room',
      });

      expect(appointment.id, 'apt1');
      expect(appointment.isOnline, isTrue);
      expect(appointment.canJoin, isTrue);
      expect(appointment.isUpcoming, isTrue);
    });

    test('cancelled appointment is not upcoming', () {
      final future = DateTime.now().toUtc().add(const Duration(days: 2));
      final appointment = Appointment.fromJson({
        'id': 'apt2',
        'doctorId': 'doc1',
        'doctorName': 'Dr. Test',
        'appointmentTime': future.toIso8601String(),
        'type': 'online',
        'status': 'cancelled',
      });

      expect(appointment.isUpcoming, isFalse);
    });

    test('confirmed appointment in the past is not upcoming', () {
      final past = DateTime.now().toUtc().subtract(const Duration(days: 2));
      final appointment = Appointment.fromJson({
        'id': 'apt3',
        'doctorId': 'doc1',
        'doctorName': 'Dr. Test',
        'appointmentTime': past.toIso8601String(),
        'type': 'online',
        'status': 'confirmed',
        'durationMin': 30,
      });

      expect(appointment.isUpcoming, isFalse);
    });

    test('statusLabelDe maps API status to German', () {
      expect(
        Appointment.fromJson({
          'id': 'a',
          'doctorId': 'd',
          'doctorName': 'Dr.',
          'appointmentTime': DateTime.now().toUtc().toIso8601String(),
          'type': 'online',
          'status': 'confirmed',
        }).statusLabelDe,
        'Bestätigt',
      );
    });
  });
}
