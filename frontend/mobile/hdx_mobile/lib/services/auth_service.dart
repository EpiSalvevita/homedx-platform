import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../utils/constants.dart';
import 'api_service.dart';

class AuthService {
  final ApiService _apiService;
  SharedPreferences? _prefs;
  static const _secureStorage = FlutterSecureStorage(
    aOptions: AndroidOptions(encryptedSharedPreferences: true),
  );

  AuthService(this._apiService);

  Future<void> _initPrefs() async {
    _prefs ??= await SharedPreferences.getInstance();
  }

  Future<String?> getStoredToken() async {
    if (kIsWeb) {
      return _apiService.authToken;
    }

    final secureToken = await _secureStorage.read(key: AppConstants.keyAuthToken);
    if (secureToken != null) {
      return secureToken;
    }

    await _initPrefs();
    final legacyToken = _prefs?.getString(AppConstants.keyAuthToken);
    if (legacyToken != null) {
      await _storeToken(legacyToken);
      return legacyToken;
    }
    return null;
  }

  Future<String?> getStoredUserId() async {
    final secure = await _secureStorage.read(key: AppConstants.keyUserId);
    if (secure != null) return secure;
    await _initPrefs();
    return _prefs?.getString(AppConstants.keyUserId);
  }

  Future<String?> getStoredUserEmail() async {
    final secure = await _secureStorage.read(key: AppConstants.keyUserEmail);
    if (secure != null) return secure;
    await _initPrefs();
    return _prefs?.getString(AppConstants.keyUserEmail);
  }

  Future<String?> getStoredUserRole() async {
    final secure = await _secureStorage.read(key: AppConstants.keyUserRole);
    if (secure != null) return secure;
    await _initPrefs();
    return _prefs?.getString(AppConstants.keyUserRole);
  }

  Future<void> _storeToken(String token) async {
    _apiService.setAuthToken(token);

    if (kIsWeb) {
      // Web: httpOnly cookie is the persistent session; token stays in memory only.
      return;
    }

    await _secureStorage.write(key: AppConstants.keyAuthToken, value: token);
    await _initPrefs();
    await _prefs?.remove(AppConstants.keyAuthToken);
  }

  Future<void> _storeUserData(
    String userId,
    String email, {
    String? role,
  }) async {
    await _secureStorage.write(key: AppConstants.keyUserId, value: userId);
    await _secureStorage.write(key: AppConstants.keyUserEmail, value: email);
    if (role != null) {
      await _secureStorage.write(key: AppConstants.keyUserRole, value: role);
    }

    await _initPrefs();
    await _prefs?.remove(AppConstants.keyUserId);
    await _prefs?.remove(AppConstants.keyUserEmail);
    await _prefs?.remove(AppConstants.keyUserRole);
  }

  Future<void> _clearStoredData() async {
    _apiService.setAuthToken(null);

    await _secureStorage.delete(key: AppConstants.keyAuthToken);
    await _secureStorage.delete(key: AppConstants.keyUserId);
    await _secureStorage.delete(key: AppConstants.keyUserEmail);
    await _secureStorage.delete(key: AppConstants.keyUserRole);

    await _initPrefs();
    await _prefs?.remove(AppConstants.keyAuthToken);
    await _prefs?.remove(AppConstants.keyUserId);
    await _prefs?.remove(AppConstants.keyUserEmail);
    await _prefs?.remove(AppConstants.keyUserRole);
  }

  Future<LoginResult> login(String email, String password) async {
    try {
      final response = await _apiService.post(
        '/login',
        body: {
          'user': email,
          'pw': password,
        },
        includeAuth: false,
      );

      if (response['success'] == true && response['token'] != null) {
        final token = response['token'] as String;
        await _storeToken(token);

        try {
          final userDataResponse = await _apiService.post('/get-user-data');
          if (userDataResponse['success'] == true && userDataResponse['userdata'] != null) {
            final userData = userDataResponse['userdata'] as Map<String, dynamic>;
            await _storeUserData(
              userData['id']?.toString() ?? '',
              userData['email']?.toString() ?? email,
              role: userData['role']?.toString(),
            );
          }
        } catch (_) {
          await _storeUserData('', email);
        }

        return LoginResult.success(token);
      } else {
        final error = response['error']?.toString() ?? 'Login failed';
        return LoginResult.failure(error);
      }
    } on UnauthorizedException catch (e) {
      return LoginResult.failure(e.message);
    } on ApiException catch (e) {
      return LoginResult.failure(e.message);
    } catch (e) {
      return LoginResult.failure('Unexpected error: $e');
    }
  }

  Future<RegisterResult> register({
    required String email,
    required String password,
    required String firstName,
    required String lastName,
  }) async {
    try {
      final response = await _apiService.post(
        '/register-account',
        body: {
          'email': email,
          'password': password,
          'firstname': firstName,
          'lastname': lastName,
        },
        includeAuth: false,
      );

      if (response['success'] == true) {
        return RegisterResult.success();
      } else {
        String error = 'Registration failed';
        if (response['error'] != null) {
          error = response['error'].toString();
        } else if (response['validation'] != null) {
          if (response['validation'] is List) {
            error = (response['validation'] as List).join(', ');
          } else {
            error = response['validation'].toString();
          }
        }
        return RegisterResult.failure(error);
      }
    } on UnauthorizedException catch (e) {
      return RegisterResult.failure(e.message);
    } on ApiException catch (e) {
      return RegisterResult.failure(e.message);
    } catch (e) {
      return RegisterResult.failure('Unexpected error: $e');
    }
  }

  Future<void> refreshUserProfileFromServer() async {
    final userDataResponse = await _apiService.post('/get-user-data');
    if (userDataResponse['success'] == true && userDataResponse['userdata'] != null) {
      final userData = userDataResponse['userdata'] as Map<String, dynamic>;
      await _storeUserData(
        userData['id']?.toString() ?? '',
        userData['email']?.toString() ?? '',
        role: userData['role']?.toString(),
      );
    }
  }

  Future<void> logout() async {
    try {
      await _apiService.post('/unset-authentication');
    } catch (_) {
      // Clear local state even if the server call fails.
    }
    await _clearStoredData();
  }

  Future<bool> isLoggedIn() async {
    if (kIsWeb) {
      try {
        final response = await _apiService.post('/init-authentication');
        return response['success'] == true;
      } catch (_) {
        return false;
      }
    }

    final token = await getStoredToken();
    if (token != null) {
      _apiService.setAuthToken(token);
      return true;
    }
    return false;
  }

  Future<void> restoreSession() async {
    if (kIsWeb) {
      final loggedIn = await isLoggedIn();
      if (!loggedIn) {
        _apiService.setAuthToken(null);
        return;
      }
      await refreshUserProfileFromServer();
      return;
    }

    final token = await getStoredToken();
    if (token != null) {
      _apiService.setAuthToken(token);
    }
  }
}

class LoginResult {
  final bool success;
  final String? token;
  final String? error;

  LoginResult.success(this.token)
      : success = true,
        error = null;

  LoginResult.failure(this.error)
      : success = false,
        token = null;
}

class RegisterResult {
  final bool success;
  final String? error;

  RegisterResult.success()
      : success = true,
        error = null;

  RegisterResult.failure(this.error)
      : success = false;
}
