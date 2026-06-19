import 'package:flutter_test/flutter_test.dart';
import 'package:hdx_mobile/services/doctor_service.dart';

void main() {
  group('DoctorService.filterDoctorsForTestType', () {
    final doctors = DoctorService.mockDoctors();

    test('rheumacheck only returns the Rheumatologie specialist', () {
      final filtered =
          DoctorService.filterDoctorsForTestType(doctors, 'rheumacheck');
      expect(filtered, isNotEmpty);
      expect(
        filtered.every((d) => d.specialization == 'Rheumatologie'),
        isTrue,
      );
      expect(filtered.map((d) => d.id), contains('doc6'));
    });

    test('covid-rapid returns Pulmologie + Allgemeinmedizin doctors', () {
      final filtered =
          DoctorService.filterDoctorsForTestType(doctors, 'covid-rapid');
      final specs = filtered.map((d) => d.specialization).toSet();
      expect(specs, contains('Allgemeinmedizin'));
      expect(specs, isNot(contains('Rheumatologie')));
    });

    test('unknown test type falls back to a generalist match', () {
      final filtered =
          DoctorService.filterDoctorsForTestType(doctors, 'mystery-test');
      expect(filtered, isNotEmpty);
      expect(
        filtered.every((d) => d.specialization == 'Allgemeinmedizin'),
        isTrue,
      );
    });
  });
}
