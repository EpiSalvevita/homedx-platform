import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import '../utils/constants.dart';

class ApiService {
  final String baseUrl;
  final Map<String, String> defaultHeaders;
  String? _authToken;

  ApiService({
    String? baseUrl,
    Map<String, String>? headers,
    String? authToken,
  })  : baseUrl = baseUrl ?? AppConstants.apiBaseUrl,
        _authToken = authToken,
        defaultHeaders = headers ?? {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        };

  void setAuthToken(String? token) {
    _authToken = token;
  }

  String? get authToken => _authToken;

  Map<String, String> _buildHeaders({Map<String, String>? additionalHeaders, bool includeAuth = true}) {
    final headers = Map<String, String>.from(defaultHeaders);
    
    if (includeAuth && _authToken != null) {
      // Support both Authorization Bearer and x-auth-token header
      headers['Authorization'] = 'Bearer $_authToken';
      headers['x-auth-token'] = _authToken!;
    }
    
    if (additionalHeaders != null) {
      headers.addAll(additionalHeaders);
    }
    
    return headers;
  }

  Future<Map<String, dynamic>> get(
    String endpoint, {
    Map<String, String>? headers,
    Map<String, dynamic>? queryParameters,
    bool includeAuth = true,
  }) async {
    try {
      final uri = Uri.parse('$baseUrl${AppConstants.apiPath}$endpoint').replace(
        queryParameters: queryParameters?.map(
          (key, value) => MapEntry(key, value.toString()),
        ),
      );

      final response = await http
          .get(
            uri,
            headers: _buildHeaders(additionalHeaders: headers, includeAuth: includeAuth),
          )
          .timeout(AppConstants.apiTimeout);

      return _handleResponse(response);
    } on TimeoutException catch (e) {
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
      final uri = Uri.parse('$baseUrl${AppConstants.apiPath}$endpoint');

      final response = await http
          .post(
            uri,
            headers: _buildHeaders(additionalHeaders: headers, includeAuth: includeAuth),
            body: body != null ? jsonEncode(body) : null,
          )
          .timeout(AppConstants.apiTimeout);

      return _handleResponse(response);
    } on TimeoutException catch (e) {
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
    String endpoint,
    File file, {
    String fieldName = 'media',
    Map<String, String>? additionalFields,
    bool includeAuth = true,
  }) async {
    try {
      final uri = Uri.parse('$baseUrl${AppConstants.apiPath}$endpoint');
      final request = http.MultipartRequest('POST', uri);
      
      // Add headers
      final headers = _buildHeaders(includeAuth: includeAuth);
      request.headers.addAll(headers);
      
      // Remove Content-Type from headers for multipart request
      request.headers.remove('Content-Type');
      
      // Add file
      final fileExtension = file.path.split('.').last;
      final contentType = _getContentType(fileExtension);
      request.files.add(
        await http.MultipartFile.fromPath(
          fieldName,
          file.path,
          filename: file.path.split('/').last,
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
    } on TimeoutException catch (e) {
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

  Map<String, dynamic> _handleResponse(http.Response response) {
    // Handle authentication errors
    if (response.statusCode == 401 || response.statusCode == 403) {
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

