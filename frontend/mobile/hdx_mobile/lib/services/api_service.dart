import 'dart:async';
import 'dart:convert';
import 'dart:developer' as developer;
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'http_client_factory.dart';
import '../utils/constants.dart';

class ApiService {
  final String baseUrl;
  final Map<String, String> defaultHeaders;
  final http.Client _client;
  String? _authToken;
  VoidCallback? onUnauthorized;
  bool _suppressUnauthorizedCallback = false;

  ApiService({
    String? baseUrl,
    Map<String, String>? headers,
    String? authToken,
  })  : baseUrl = baseUrl ?? AppConstants.apiBaseUrl,
        _authToken = authToken,
        defaultHeaders = headers ?? {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        _client = createPlatformHttpClient();

  void dispose() {
    _client.close();
  }

  void setAuthToken(String? token) {
    _authToken = token;
  }

  /// Prevents [onUnauthorized] during login profile fetch or server logout calls.
  void setSuppressUnauthorizedCallback(bool suppress) {
    _suppressUnauthorizedCallback = suppress;
  }

  String? get authToken => _authToken;

  Map<String, String> _buildHeaders({Map<String, String>? additionalHeaders, bool includeAuth = true}) {
    final headers = Map<String, String>.from(defaultHeaders);
    
    if (includeAuth && _authToken != null && _authToken!.isNotEmpty) {
      // Support both Authorization Bearer and x-auth-token header
      headers['Authorization'] = 'Bearer $_authToken';
      headers['x-auth-token'] = _authToken!;
    }
    
    if (additionalHeaders != null) {
      headers.addAll(additionalHeaders);
    }
    
    return headers;
  }

  String _apiEndpoint(String endpoint) {
    if (endpoint.startsWith('/')) return endpoint;
    return '/$endpoint';
  }

  Uri _apiUri(String endpoint) {
    return Uri.parse('$baseUrl${AppConstants.apiPath}${_apiEndpoint(endpoint)}');
  }

  Future<Map<String, dynamic>> get(
    String endpoint, {
    Map<String, String>? headers,
    Map<String, dynamic>? queryParameters,
    bool includeAuth = true,
  }) async {
    try {
      final uri = _apiUri(endpoint).replace(
        queryParameters: queryParameters?.map(
          (key, value) => MapEntry(key, value.toString()),
        ),
      );

      final response = await _client
          .get(
            uri,
            headers: _buildHeaders(additionalHeaders: headers, includeAuth: includeAuth),
          )
          .timeout(AppConstants.apiTimeout);

      return _handleResponse(response);
    } on TimeoutException {
      throw ApiException(
        'Connection timeout: Unable to reach the server at $baseUrl. '
        'Please check if the backend is running and accessible. '
        'If using WSL2, ensure port forwarding is set up from Windows to WSL2.',
        0,
      );
    } on http.ClientException catch (e) {
      throw ApiException('Network error: ${e.message}. Check your connection and server URL: $baseUrl', 0);
    } on FormatException catch (e) {
      throw ApiException('Invalid response format: ${e.message}', 0);
    } catch (e) {
      throw ApiException('Unexpected error: $e', 0);
    }
  }

  Future<Map<String, dynamic>> post(
    String endpoint, {
    Map<String, String>? headers,
    Map<String, dynamic>? body,
    bool includeAuth = true,
  }) async {
    try {
      final uri = _apiUri(endpoint);

      final response = await _client
          .post(
            uri,
            headers: _buildHeaders(additionalHeaders: headers, includeAuth: includeAuth),
            body: body != null ? jsonEncode(body) : null,
          )
          .timeout(AppConstants.apiTimeout);

      return _handleResponse(response);
    } on TimeoutException {
      throw ApiException(
        'Connection timeout: Unable to reach the server at $baseUrl. '
        'Please check if the backend is running and accessible. '
        'If using WSL2, ensure port forwarding is set up from Windows to WSL2.',
        0,
      );
    } on http.ClientException catch (e) {
      throw ApiException('Network error: ${e.message}. Check your connection and server URL: $baseUrl', 0);
    } on FormatException catch (e) {
      throw ApiException('Invalid response format: ${e.message}', 0);
    } catch (e) {
      throw ApiException('Unexpected error: $e', 0);
    }
  }

  Future<Map<String, dynamic>> uploadFile(
    String endpoint, {
    required Uint8List bytes,
    required String filename,
    String fieldName = 'media',
    Map<String, String>? additionalFields,
    bool includeAuth = true,
  }) async {
    try {
      final uri = _apiUri(endpoint);
      final request = http.MultipartRequest('POST', uri);
      
      // Add headers
      final headers = _buildHeaders(includeAuth: includeAuth);
      request.headers.addAll(headers);
      
      // Remove Content-Type from headers for multipart request
      request.headers.remove('Content-Type');
      
      // Add file
      final fileExtension = filename.split('.').last;
      final contentType = _getContentType(fileExtension);
      request.files.add(
        http.MultipartFile.fromBytes(
          fieldName,
          bytes,
          filename: filename,
          contentType: contentType,
        ),
      );
      
      // Add additional fields
      if (additionalFields != null) {
        request.fields.addAll(additionalFields);
      }
      
      final streamedResponse = await request.send().timeout(AppConstants.apiTimeout);
      final response = await http.Response.fromStream(streamedResponse);
      
      return _handleResponse(response);
    } on TimeoutException {
      throw ApiException(
        'Connection timeout: Unable to reach the server at $baseUrl. '
        'Please check if the backend is running and accessible. '
        'If using WSL2, ensure port forwarding is set up from Windows to WSL2.',
        0,
      );
    } on http.ClientException catch (e) {
      throw ApiException('Network error: ${e.message}. Check your connection and server URL: $baseUrl', 0);
    } on FormatException catch (e) {
      throw ApiException('Invalid response format: ${e.message}', 0);
    } catch (e) {
      throw ApiException('Unexpected error: $e', 0);
    }
  }

  MediaType _getContentType(String extension) {
    switch (extension.toLowerCase()) {
      case 'jpg':
      case 'jpeg':
        return MediaType('image', 'jpeg');
      case 'png':
        return MediaType('image', 'png');
      case 'mp4':
        return MediaType('video', 'mp4');
      case 'mov':
        return MediaType('video', 'quicktime');
      default:
        return MediaType('application', 'octet-stream');
    }
  }

  /// Submit Cube device data/results to the backend.
  Future<Map<String, dynamic>> submitCubeData({
    required String testTypeId,
    String? rapidTestId,
    List<int>? rawData,
    String? deviceSerial,
    int? measurementTimestamp,
    String? result,
    List<Map<String, dynamic>>? resultData,
  }) async {
    final authPresent = _authToken != null && _authToken!.isNotEmpty;
    if (!kReleaseMode) {
      developer.log(
        'POST submit-cube-data testTypeId=$testTypeId hasAuth=$authPresent',
        name: 'HDX_CUBE_API',
      );
    }
    if (!kReleaseMode && AppConstants.cubeVerboseLogging && resultData != null && resultData.isNotEmpty) {
      final n = resultData.length;
      for (var i = 0; i < n && i < 16; i++) {
        developer.log(
          'submit-cube-data row[$i]=$resultData[i]',
          name: 'HDX_CUBE_API',
        );
      }
      if (n > 16) {
        developer.log(
          'submit-cube-data … ${n - 16} more row(s) omitted',
          name: 'HDX_CUBE_API',
        );
      }
    }
    try {
      final map = await post(
        '/submit-cube-data',
        body: {
          'testTypeId': testTypeId,
          if (rapidTestId != null) 'rapidTestId': rapidTestId,
          if (rawData != null) 'rawData': rawData,
          if (deviceSerial != null) 'deviceSerial': deviceSerial,
          if (measurementTimestamp != null) 'measurementTimestamp': measurementTimestamp,
          if (result != null) 'result': result,
          if (resultData != null) 'resultData': resultData,
        },
        includeAuth: true,
      );
      if (!kReleaseMode) {
        developer.log('submit-cube-data OK', name: 'HDX_CUBE_API');
      }
      return map;
    } catch (e, st) {
      if (!kReleaseMode) {
        developer.log(
          'submit-cube-data FAILED: $e',
          name: 'HDX_CUBE_API',
          error: e,
          stackTrace: st,
          level: 1000,
        );
      }
      rethrow;
    }
  }

  Map<String, dynamic> _handleResponse(http.Response response) {
    // Handle authentication errors
    if (response.statusCode == 401 || response.statusCode == 403) {
      if (!_suppressUnauthorizedCallback) {
        onUnauthorized?.call();
      }
      throw UnauthorizedException('Authentication required or token expired');
    }

    if (response.statusCode >= 200 && response.statusCode < 300) {
      if (response.body.isEmpty) {
        return {'success': true};
      }
      
      try {
        return jsonDecode(response.body) as Map<String, dynamic>;
      } catch (e) {
        throw ApiException('Invalid JSON response: $e', response.statusCode);
      }
    } else {
      String errorMessage = 'API error: ${response.statusCode}';
      try {
        final errorBody = jsonDecode(response.body) as Map<String, dynamic>;
        errorMessage = errorBody['error']?.toString() ?? 
                      errorBody['message']?.toString() ?? 
                      errorMessage;
      } catch (_) {
        errorMessage = response.body.isNotEmpty 
            ? response.body 
            : errorMessage;
      }
      throw ApiException(errorMessage, response.statusCode);
    }
  }
}

class ApiException implements Exception {
  final String message;
  final int statusCode;

  ApiException(this.message, this.statusCode);

  @override
  String toString() => message;
}

class UnauthorizedException extends ApiException {
  UnauthorizedException(String message) : super(message, 401);
}

