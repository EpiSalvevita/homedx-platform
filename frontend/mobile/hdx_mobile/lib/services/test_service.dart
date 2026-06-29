import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import '../models/test_type.dart';
import '../models/user_test_result.dart';
import 'api_service.dart' show ApiService, ApiException;

class TestService {
  final ApiService _apiService;

  TestService(this._apiService);

  /// Get list of available test types from backend
  Future<List<TestType>> getTestTypes() async {
    try {
      final response = await _apiService.post(
        '/get-test-type-list',
        body: {},
        includeAuth: false,
      );

      if (response['success'] == true && response['testTypes'] != null) {
        final testTypesList = response['testTypes'] as List;
        return testTypesList
            .map((item) => TestType.fromJson(item as Map<String, dynamic>))
            .toList();
      } else {
        // Return default test types if backend doesn't return any
        return _getDefaultTestTypes();
      }
    } catch (e) {
      // If API call fails, return default test types
      return _getDefaultTestTypes();
    }
  }

  /// Get default test types (fallback)
  List<TestType> _getDefaultTestTypes() {
    return [
      TestType(
        id: 'rheumacheck',
        name: 'RheumaCheck',
        description: 'Rheumatoid arthritis screening test',
        icon: 'healing',
        color: Colors.red,
      ),
      TestType(
        id: 'crp',
        name: 'CRP (C-reaktives Protein)',
        description: 'Schnelltest für C-reaktives Protein (Entzündungsmarker)',
        icon: 'monitor_heart',
        color: Colors.pink,
      ),
      TestType(
        id: 'vitamind',
        name: 'Vitamin D',
        description: 'Vitamin D deficiency screening test',
        icon: 'wb_sunny',
        color: Colors.orange,
      ),
      TestType(
        id: 'covid-rapid',
        name: 'COVID-19 Rapid Test',
        description: 'Rapid antigen test for COVID-19',
        icon: 'coronavirus',
        color: Colors.blue,
      ),
      TestType(
        id: 'antigen',
        name: 'Antigen Test',
        description: 'General antigen test',
        icon: 'science',
        color: Colors.green,
      ),
      TestType(
        id: 'pcr',
        name: 'PCR Test',
        description: 'Polymerase Chain Reaction test',
        icon: 'biotech',
        color: Colors.purple,
      ),
    ];
  }

  /// Fetch the logged-in user's completed rapid tests (newest first).
  Future<List<UserTestResult>> getUserTestResults() async {
    try {
      final response = await _apiService.post(
        '/get-last-test',
        body: {},
        includeAuth: true,
      );

      if (response['success'] != true) {
        throw ApiException(
          response['error']?.toString() ?? 'Failed to load test results',
          0,
        );
      }

      final raw = response['lastTests'];
      if (raw is! List) {
        return kIsWeb ? mockUserTestResults() : const [];
      }

      final results = raw
          .whereType<Map>()
          .map((item) => UserTestResult.fromJson(Map<String, dynamic>.from(item)))
          .toList();

      if (results.isEmpty && kIsWeb) return mockUserTestResults();
      return results;
    } on ApiException {
      if (kIsWeb) return mockUserTestResults();
      rethrow;
    }
  }

  /// Sample results for web UI development and empty API responses.
  static List<UserTestResult> mockUserTestResults() {
    final now = DateTime.now();
    return [
      UserTestResult(
        id: 'mock-rheuma-1',
        testTypeId: 'rheumacheck',
        result: 'NEGATIVE',
        status: 'COMPLETED',
        testDate: now.subtract(const Duration(days: 2, hours: 4)),
        resultData: [
          {'class': 'NEGATIVE', 'label': 'RheumaCheck', 'value': 'Negativ'},
        ],
      ),
      UserTestResult(
        id: 'mock-crp-1',
        testTypeId: 'crp',
        result: 'POSITIVE',
        status: 'COMPLETED',
        testDate: now.subtract(const Duration(days: 5, hours: 2)),
        resultData: [
          {'class': 'POSITIVE', 'label': 'CRP', 'value': '12 mg/L'},
        ],
      ),
      UserTestResult(
        id: 'mock-covid-1',
        testTypeId: 'covid-rapid',
        result: 'NEGATIVE',
        status: 'COMPLETED',
        testDate: now.subtract(const Duration(days: 12)),
      ),
      UserTestResult(
        id: 'mock-vitd-1',
        testTypeId: 'vitamind',
        status: 'PENDING',
        testDate: now.subtract(const Duration(hours: 3)),
      ),
      UserTestResult(
        id: 'mock-antigen-1',
        testTypeId: 'antigen',
        result: 'INCONCLUSIVE',
        status: 'COMPLETED',
        testDate: now.subtract(const Duration(days: 20)),
      ),
    ];
  }

  /// Add a new test (create test instance). Returns rapid test id when successful.
  Future<String?> addTest(String testTypeId) async {
    try {
      final response = await _apiService.post(
        '/add-test',
        body: {'testTypeId': testTypeId},
        includeAuth: true,
      );

      if (response['success'] == true) {
        return response['rapidTestId'] as String?;
      }
      return null;
    } on ApiException {
      rethrow;
    } catch (e) {
      throw ApiException('Failed to add test: $e', 0);
    }
  }

  Future<String> uploadTestPhoto(String rapidTestId, Uint8List bytes, String filename) async {
    final response = await _apiService.uploadFile(
      'add-rapid-test-photo',
      bytes: bytes,
      filename: filename,
      additionalFields: {'rapidTestId': rapidTestId},
    );
    if (response['success'] != true) {
      throw ApiException(response['error']?.toString() ?? 'Photo upload failed', 0);
    }
    return response['objectName'] as String? ?? '';
  }

  Future<String> uploadTestVideo(String rapidTestId, Uint8List bytes, String filename) async {
    final response = await _apiService.uploadFile(
      'add-rapid-test-video',
      bytes: bytes,
      filename: filename,
      additionalFields: {'rapidTestId': rapidTestId},
    );
    if (response['success'] != true) {
      throw ApiException(response['error']?.toString() ?? 'Video upload failed', 0);
    }
    return response['objectName'] as String? ?? '';
  }

  Future<String> uploadIdPhoto(
    String rapidTestId,
    Uint8List bytes,
    String filename, {
    required String type,
  }) async {
    final response = await _apiService.uploadFile(
      'add-identification-photo',
      bytes: bytes,
      filename: filename,
      additionalFields: {'rapidTestId': rapidTestId, 'type': type},
    );
    if (response['success'] != true) {
      throw ApiException(response['error']?.toString() ?? 'ID upload failed', 0);
    }
    return response['objectName'] as String? ?? '';
  }

  Future<void> finalizeSubmission(String rapidTestId, {required bool agreementGiven}) async {
    final response = await _apiService.post(
      'finalize-test-submission',
      body: {'rapidTestId': rapidTestId, 'agreementGiven': agreementGiven},
      includeAuth: true,
    );
    if (response['success'] != true) {
      throw ApiException(
        response['error']?.toString() ?? 'Finalize failed',
        0,
      );
    }
  }
}

