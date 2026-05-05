import 'package:flutter_test/flutter_test.dart';
import 'package:hdx_mobile/utils/test_specialization_mapping.dart';

void main() {
  group('TestSpecializationMapping.specializationsForTestType', () {
    test('rheumacheck maps to Rheumatologie', () {
      expect(
        TestSpecializationMapping.specializationsForTestType('rheumacheck'),
        ['Rheumatologie'],
      );
    });

    test('vitamind maps to Endokrinologie + Allgemeinmedizin fallback', () {
      expect(
        TestSpecializationMapping.specializationsForTestType('vitamind'),
        ['Endokrinologie', 'Allgemeinmedizin'],
      );
    });

    test('covid-rapid maps to Pulmologie + Allgemeinmedizin fallback', () {
      expect(
        TestSpecializationMapping.specializationsForTestType('covid-rapid'),
        ['Pulmologie', 'Allgemeinmedizin'],
      );
    });

    test('comparison is case-insensitive on the test type id', () {
      expect(
        TestSpecializationMapping.specializationsForTestType('RheumaCheck'),
        ['Rheumatologie'],
      );
    });

    test('unknown / null / empty test types fall back to Allgemeinmedizin', () {
      expect(
        TestSpecializationMapping.specializationsForTestType('unknown-id'),
        ['Allgemeinmedizin'],
      );
      expect(
        TestSpecializationMapping.specializationsForTestType(null),
        ['Allgemeinmedizin'],
      );
      expect(
        TestSpecializationMapping.specializationsForTestType('   '),
        ['Allgemeinmedizin'],
      );
    });
  });

  group('TestSpecializationMapping.primarySpecialization', () {
    test('returns the first (most specific) match', () {
      expect(
        TestSpecializationMapping.primarySpecialization('rheumacheck'),
        'Rheumatologie',
      );
      expect(
        TestSpecializationMapping.primarySpecialization('vitamind'),
        'Endokrinologie',
      );
    });
  });

  group('TestSpecializationMapping.matches', () {
    test('positive RheumaCheck matches a Rheumatologie doctor', () {
      expect(
        TestSpecializationMapping.matches(
          testTypeId: 'rheumacheck',
          doctorSpecialization: 'Rheumatologie',
        ),
        isTrue,
      );
    });

    test('positive RheumaCheck does not match a Dermatologie doctor', () {
      expect(
        TestSpecializationMapping.matches(
          testTypeId: 'rheumacheck',
          doctorSpecialization: 'Dermatologie',
        ),
        isFalse,
      );
    });

    test('matching is substring-based (handles combined specializations)', () {
      expect(
        TestSpecializationMapping.matches(
          testTypeId: 'rheumacheck',
          doctorSpecialization: 'Rheumatologie / Innere Medizin',
        ),
        isTrue,
      );
    });

    test('vitamind matches both Endokrinologie and Allgemeinmedizin', () {
      expect(
        TestSpecializationMapping.matches(
          testTypeId: 'vitamind',
          doctorSpecialization: 'Endokrinologie',
        ),
        isTrue,
      );
      expect(
        TestSpecializationMapping.matches(
          testTypeId: 'vitamind',
          doctorSpecialization: 'Allgemeinmedizin',
        ),
        isTrue,
      );
    });
  });
}
