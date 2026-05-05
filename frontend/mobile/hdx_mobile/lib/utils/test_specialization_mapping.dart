/// Maps a HomeDX rapid-test type to the medical specializations that should
/// follow up on a positive result.
///
/// The mapping is intentionally permissive: each test type lists one preferred
/// specialty plus broader fallbacks so the user always sees at least one
/// relevant doctor in the post-positive booking flow.
class TestSpecializationMapping {
  /// Specialties to suggest for a given test type id.
  ///
  /// The first entry is the most specific match and used for the UI label;
  /// subsequent entries are accepted fallbacks.
  static const Map<String, List<String>> _byTestTypeId = {
    'rheumacheck': ['Rheumatologie'],
    'vitamind': ['Endokrinologie', 'Allgemeinmedizin'],
    'covid-rapid': ['Pulmologie', 'Allgemeinmedizin'],
    'antigen': ['Allgemeinmedizin'],
    'pcr': ['Pulmologie', 'Innere Medizin'],
  };

  static const List<String> _defaultSpecializations = ['Allgemeinmedizin'];

  /// Returns the ordered list of specializations for [testTypeId].
  ///
  /// Falls back to ['Allgemeinmedizin'] when the id is unknown / null /
  /// empty so users can still reach a generalist.
  static List<String> specializationsForTestType(String? testTypeId) {
    if (testTypeId == null || testTypeId.trim().isEmpty) {
      return _defaultSpecializations;
    }
    final key = testTypeId.trim().toLowerCase();
    return _byTestTypeId[key] ?? _defaultSpecializations;
  }

  /// Primary specialization label for the UI banner ("Rheumatologie", ...).
  static String primarySpecialization(String? testTypeId) =>
      specializationsForTestType(testTypeId).first;

  /// True when [doctorSpecialization] matches any of the specialties suggested
  /// for [testTypeId]. Comparison is case-insensitive and substring-based, so
  /// "Rheumatologie / Innere" still matches "Rheumatologie".
  static bool matches({
    required String? testTypeId,
    required String doctorSpecialization,
  }) {
    final specs = specializationsForTestType(testTypeId);
    final candidate = doctorSpecialization.toLowerCase();
    return specs.any((s) => candidate.contains(s.toLowerCase()));
  }
}
