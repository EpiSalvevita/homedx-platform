import 'package:flutter/material.dart';
import '../models/test_type.dart';
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

  /// Add a new test (create test instance)
  Future<bool> addTest(String testTypeId) async {
    try {
      final response = await _apiService.post(
        '/add-test',
        body: {'testTypeId': testTypeId},
        includeAuth: true,
      );

      return response['success'] == true;
    } on ApiException {
      rethrow;
    } catch (e) {
      throw ApiException('Failed to add test: $e', 0);
    }
  }
}

