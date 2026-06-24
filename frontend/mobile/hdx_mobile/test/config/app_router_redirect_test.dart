import 'package:flutter_test/flutter_test.dart';

/// Mirrors [AppRouter] patient guard — `/doctors` must not match `/doctor/`.
bool patientBlockedFromDoctorPortal(String location) {
  return location.startsWith('/doctor/');
}

void main() {
  test('/doctors is allowed for patients (not a doctor-portal path)', () {
    expect(patientBlockedFromDoctorPortal('/doctors'), isFalse);
    expect(patientBlockedFromDoctorPortal('/doctors/doc1/appointment'), isFalse);
  });

  test('/doctor/* paths are blocked for patients', () {
    expect(patientBlockedFromDoctorPortal('/doctor/dashboard'), isTrue);
    expect(patientBlockedFromDoctorPortal('/doctor/appointments'), isTrue);
  });
}
