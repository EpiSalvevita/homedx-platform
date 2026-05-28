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
    switch (result?.toUpperCase()) {
      case 'POSITIVE':
        return 'Positiv';
      case 'NEGATIVE':
        return 'Negativ';
      case 'INCONCLUSIVE':
        return 'Unbestimmt';
      case 'INVALID':
        return 'Ungültig';
      default:
        return 'Ausstehend';
    }
  }

  bool get isPositive => result?.toUpperCase() == 'POSITIVE';
}
