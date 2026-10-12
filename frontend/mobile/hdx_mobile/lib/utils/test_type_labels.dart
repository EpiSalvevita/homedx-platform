import '../l10n/app_localizations.dart';

/// Human-readable label for a rapid-test type id.
///
/// Shared between the results list ([UserTestResult.displayTestName]) and
/// appointment screens, which only carry the raw `testTypeId` from the
/// backend and need the same friendly name.
String testTypeDisplayName(String? testTypeId, AppLocalizations l10n) {
  switch (testTypeId?.toLowerCase()) {
    case 'rheumacheck':
      return 'RheumaCheck';
    case 'crp':
      return l10n.testTypeCrp;
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
      return l10n.testTypeGenericName;
  }
}
