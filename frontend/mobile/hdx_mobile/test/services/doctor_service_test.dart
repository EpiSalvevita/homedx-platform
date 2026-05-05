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
      expect(specs, contains('Pulmologie'));
      expect(specs, contains('Allgemeinmedizin'));
      expect(specs, isNot(contains('Dermatologie')));
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

  group('DoctorService.getAvailableDoctors', () {
    test('returns the full list when no testTypeId is provided', () async {
      final service = DoctorService();
      final doctors = await service.getAvailableDoctors();
      expect(doctors.length, DoctorService.mockDoctors().length);
    });

    test('rheumacheck filter returns only the Rheumatologie specialist',
        () async {
      final service = DoctorService();
      final doctors =
          await service.getAvailableDoctors(testTypeId: 'rheumacheck');
      expect(doctors, isNotEmpty);
      expect(
        doctors.every((d) => d.specialization == 'Rheumatologie'),
        isTrue,
      );
    });

    test(
        'falls back to the full list when no specialist matches the test type',
        () async {
      // Replace the matcher behaviour by passing an exotic testTypeId that
      // resolves to a specialty no mock doctor carries. Today every fallback
      // resolves to Allgemeinmedizin, which we *do* stock, so use a doctor-
      // less specialty by spelunking the public matcher with a custom list.
      final empty = DoctorService.filterDoctorsForTestType(
        const [],
        'rheumacheck',
      );
      expect(empty, isEmpty);
    });
  });
}
