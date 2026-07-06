/// Human-readable German label for a rapid-test type id.
///
/// Shared between the results list ([UserTestResult.displayTestName]) and
/// appointment screens, which only carry the raw `testTypeId` from the
/// backend and need the same friendly name.
String testTypeDisplayName(String? testTypeId) {
  switch (testTypeId?.toLowerCase()) {
    case 'rheumacheck':
      return 'RheumaCheck';
    case 'crp':
      return 'CRP (C-reaktives Protein)';
    case 'vitamind':
      return 'Vitamin D';
    case 'covid-rapid':
      return 'COVID-19 Rapid Test';
    case 'antigen':
      return 'Antigen Test';
    case 'pcr':
      return 'PCR Test';
    default:
      if (testTypeId != null && testTypeId.isNotEmpty) {
        return testTypeId;
      }
      return 'Schnelltest';
  }
}
