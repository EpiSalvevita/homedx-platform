class UserTestResult {
  final String id;
  final String? testTypeId;
  final String? result;
  final String? status;
  final DateTime? testDate;
  final List<Map<String, dynamic>> resultData;

  const UserTestResult({
    required this.id,
    this.testTypeId,
    this.result,
    this.status,
    this.testDate,
    this.resultData = const [],
  });

  factory UserTestResult.fromJson(Map<String, dynamic> json) {
    final ts = json['testDate'];
    DateTime? parsedDate;
    if (ts is int) {
      parsedDate = DateTime.fromMillisecondsSinceEpoch(ts);
    } else if (ts is String) {
      parsedDate = DateTime.tryParse(ts);
    }

    final rawResultData = json['resultData'];
    final parsedResultData = rawResultData is List
        ? rawResultData
            .whereType<Map>()
            .map((item) => Map<String, dynamic>.from(item))
            .toList()
        : const <Map<String, dynamic>>[];

    return UserTestResult(
      id: json['id']?.toString() ?? '',
      testTypeId: json['testTypeId']?.toString(),
      result: json['result']?.toString(),
      status: json['status']?.toString(),
      testDate: parsedDate,
      resultData: parsedResultData,
    );
  }

  String get displayTestName {
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
        if (testTypeId != null && testTypeId!.isNotEmpty) {
          return testTypeId!;
        }
        return 'Schnelltest';
    }
  }

  String get resultLabel {
    final canonical = _canonicalResult();
    if (canonical != null) {
      switch (canonical) {
        case 'POSITIVE':
          return 'Positiv';
        case 'NEGATIVE':
          return 'Negativ';
        case 'INCONCLUSIVE':
          return 'Unbestimmt';
        case 'INVALID':
          return 'Ungültig';
      }
    }
    return _isAwaitingResult ? 'Ausstehend' : 'Unbestimmt';
  }

  /// Result category for badge colors (distinct pending vs negative).
  TestResultKind get resultKind {
    final canonical = _canonicalResult();
    if (canonical != null) {
      switch (canonical) {
        case 'POSITIVE':
          return TestResultKind.positive;
        case 'NEGATIVE':
          return TestResultKind.negative;
        case 'INCONCLUSIVE':
          return TestResultKind.inconclusive;
        case 'INVALID':
          return TestResultKind.invalid;
      }
    }
    return _isAwaitingResult ? TestResultKind.pending : TestResultKind.inconclusive;
  }

  bool get isPositive => resultKind == TestResultKind.positive;

  bool get _isAwaitingResult {
    final s = status?.trim().toUpperCase();
    return s == null || s.isEmpty || s == 'PENDING' || s == 'IN_PROGRESS';
  }

  String? _canonicalResult() {
    final raw = result?.trim().toUpperCase();
    if (raw != null && raw.isNotEmpty) {
      if (raw == 'POS' || raw.startsWith('POS')) return 'POSITIVE';
      if (raw == 'NEG' || raw.startsWith('NEG')) return 'NEGATIVE';
      if (raw == 'INCONCLUSIVE') return 'INCONCLUSIVE';
      if (raw == 'INVALID') return 'INVALID';
      return raw;
    }

    for (final row in resultData) {
      final cls = row['class']?.toString().toUpperCase() ?? '';
      if (cls.contains('POS')) return 'POSITIVE';
      if (cls.contains('NEG')) return 'NEGATIVE';
      if (cls.contains('INCONCLUSIVE')) return 'INCONCLUSIVE';
      if (cls.contains('INVALID')) return 'INVALID';
    }

    return null;
  }
}

enum TestResultKind {
  positive,
  negative,
  inconclusive,
  invalid,
  pending,
}
