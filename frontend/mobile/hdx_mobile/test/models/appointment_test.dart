import 'package:flutter_test/flutter_test.dart';
import 'package:hdx_mobile/models/doctor.dart';

void main() {
  group('Appointment.fromJson', () {
    test('parses appointment with join eligibility', () {
      final appointment = Appointment.fromJson({
        'id': 'apt1',
        'doctorId': 'doc1',
        'doctorName': 'Dr. Test',
        'patientId': 'pat1',
        'patientName': 'Patient Test',
        'appointmentTime': '2026-06-05T10:00:00.000Z',
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
      final appointment = Appointment.fromJson({
        'id': 'apt2',
        'doctorId': 'doc1',
        'doctorName': 'Dr. Test',
        'appointmentTime': '2026-06-05T10:00:00.000Z',
        'type': 'online',
        'status': 'cancelled',
      });

      expect(appointment.isUpcoming, isFalse);
    });

    test('statusLabelDe maps API status to German', () {
      expect(
        Appointment.fromJson({
          'id': 'a',
          'doctorId': 'd',
          'doctorName': 'Dr.',
          'appointmentTime': '2026-06-05T10:00:00.000Z',
          'type': 'online',
          'status': 'confirmed',
        }).statusLabelDe,
        'Bestätigt',
      );
    });
  });
}
