class Certificate {
  final String id;
  final String certificateNumber;
  final String type;
  final String status;
  final String rapidTestId;
  final String? testTypeId;
  final String? testResult;
  final DateTime issuedAt;
  final DateTime validFrom;
  final DateTime validUntil;
  final String? pdfUrl;
  final String? language;

  Certificate({
    required this.id,
    required this.certificateNumber,
    required this.type,
    required this.status,
    required this.rapidTestId,
    this.testTypeId,
    this.testResult,
    required this.issuedAt,
    required this.validFrom,
    required this.validUntil,
    this.pdfUrl,
    this.language,
  });

  factory Certificate.fromJson(Map<String, dynamic> json) {
    return Certificate(
      id: json['id'] as String,
      certificateNumber: json['certificateNumber'] as String,
      type: json['type'] as String,
      status: json['status'] as String,
      rapidTestId: json['rapidTestId'] as String,
      testTypeId: json['testTypeId'] as String?,
      testResult: json['testResult'] as String?,
      issuedAt: DateTime.parse(json['issuedAt'] as String),
      validFrom: DateTime.parse(json['validFrom'] as String),
      validUntil: DateTime.parse(json['validUntil'] as String),
      pdfUrl: json['pdfUrl'] as String?,
      language: json['language'] as String?,
    );
  }
}
