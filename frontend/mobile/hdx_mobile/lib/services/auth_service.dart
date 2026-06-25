import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../utils/constants.dart';
import '../utils/registration_errors.dart';
import '../utils/login_errors.dart';
import 'api_service.dart';

class AuthService {
  final ApiService _apiService;
  SharedPreferences? _prefs;
  static const _secureStorage = FlutterSecureStorage(
    aOptions: AndroidOptions(encryptedSharedPreferences: true),
  );

  // Web session metadata lives in memory only (cookie persists the session;
  // nothing sensitive is written to localStorage).
  String? _webUserId;
  String? _webUserEmail;
  String? _webUserRole;

  AuthService(this._apiService);

  /// Removes any legacy web auth data previously written to localStorage.
  Future<void> clearLegacyWebAuthStorage() async {
    if (!kIsWeb) return;
    await _initPrefs();
    await _prefs?.remove(AppConstants.keyAuthToken);
    await _prefs?.remove(AppConstants.keyUserId);
    await _prefs?.remove(AppConstants.keyUserEmail);
    await _prefs?.remove(AppConstants.keyUserRole);
  }

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
    if (kIsWeb) {
      return _webUserId;
    }

    final secure = await _secureStorage.read(key: AppConstants.keyUserId);
    if (secure != null) return secure;
    await _initPrefs();
    return _prefs?.getString(AppConstants.keyUserId);
  }

  Future<String?> getStoredUserEmail() async {
    if (kIsWeb) {
      return _webUserEmail;
    }

    final secure = await _secureStorage.read(key: AppConstants.keyUserEmail);
    if (secure != null) return secure;
    await _initPrefs();
    return _prefs?.getString(AppConstants.keyUserEmail);
  }

  Future<String?> getStoredUserRole() async {
    if (kIsWeb) {
      return _webUserRole;
    }

    final secure = await _secureStorage.read(key: AppConstants.keyUserRole);
    if (secure != null) return secure;
    await _initPrefs();
    return _prefs?.getString(AppConstants.keyUserRole);
  }

  Future<void> _storeToken(String token) async {
    _apiService.setAuthToken(token);

    if (kIsWeb) {
      // Web: httpOnly cookie persists the session; JWT stays in memory only (not localStorage).
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
    if (kIsWeb) {
      _webUserId = userId;
      _webUserEmail = email;
      if (role != null) {
        _webUserRole = role;
      }
      return;
    }

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

    if (kIsWeb) {
      _webUserId = null;
      _webUserEmail = null;
      _webUserRole = null;
      return;
    }

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
          'lang': 'de',
        },
        includeAuth: false,
      );

      if (response['success'] == true && response['token'] != null) {
        final token = response['token'] as String;
        await _storeToken(token);

        _apiService.setSuppressUnauthorizedCallback(true);
        try {
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
            // Keep the session even if profile fetch fails (e.g. inactive account).
            await _storeToken(token);
            await _storeUserData('', email);
          }
        } finally {
          _apiService.setSuppressUnauthorizedCallback(false);
        }

        return LoginResult.success(token);
      } else {
        final error = localizeLoginError(response['error']?.toString() ?? 'Anmeldung fehlgeschlagen');
        return LoginResult.failure(error);
      }
    } on UnauthorizedException catch (e) {
      return LoginResult.failure(localizeLoginError(e.message));
    } on ApiException catch (e) {
      return LoginResult.failure(localizeLoginError(e.message));
    } catch (e) {
      return LoginResult.failure('Unexpected error: $e');
    }
  }

  Future<RegisterResult> register({
    required String email,
    required String password,
    required String firstName,
    required String lastName,
    bool registerAsDoctor = false,
    String? specialization,
    String? clinicAddress,
  }) async {
    try {
      final body = <String, dynamic>{
        'email': email,
        'password': password,
        'firstname': firstName,
        'lastname': lastName,
        'lang': 'de',
      };
      if (registerAsDoctor) {
        body['role'] = 'DOCTOR';
        if (specialization != null) body['specialization'] = specialization;
        if (clinicAddress != null) body['clinic_address'] = clinicAddress;
      }

      final response = await _apiService.post(
        '/register-account',
        body: body,
        includeAuth: false,
      );

      if (response['success'] == true) {
        return RegisterResult.success();
      } else {
        String error = 'Registrierung fehlgeschlagen';
        if (response['error'] != null) {
          error = localizeRegistrationError(response['error'].toString());
        } else if (response['validation'] != null) {
          if (response['validation'] is List) {
            error = (response['validation'] as List).map((e) => localizeRegistrationError(e.toString())).join(', ');
          } else {
            error = localizeRegistrationError(response['validation'].toString());
          }
        }
        return RegisterResult.failure(error);
      }
    } on UnauthorizedException catch (e) {
      return RegisterResult.failure(localizeRegistrationError(e.message));
    } on ApiException catch (e) {
      return RegisterResult.failure(localizeRegistrationError(e.message));
    } catch (e) {
      return RegisterResult.failure('Unexpected error: $e');
    }
  }

  /// Re-applies the JWT after login (guards against races that clear in-memory auth).
  Future<void> applySessionToken(String token) async {
    await _storeToken(token);
  }

  Future<void> refreshUserProfileFromServer() async {
    _apiService.setSuppressUnauthorizedCallback(true);
    try {
      final userDataResponse = await _apiService.post('/get-user-data');
      if (userDataResponse['success'] == true && userDataResponse['userdata'] != null) {
        final userData = userDataResponse['userdata'] as Map<String, dynamic>;
        await _storeUserData(
          userData['id']?.toString() ?? '',
          userData['email']?.toString() ?? '',
          role: userData['role']?.toString(),
        );
      }
    } catch (_) {
      // Profile refresh is optional; keep the session.
    } finally {
      _apiService.setSuppressUnauthorizedCallback(false);
    }
  }

  Future<void> logout() async {
    _apiService.setSuppressUnauthorizedCallback(true);
    try {
      try {
        await _apiService.post('/unset-authentication');
      } catch (_) {
        // Clear local state even if the server call fails.
      }
      await _clearStoredData();
    } finally {
      _apiService.setSuppressUnauthorizedCallback(false);
    }
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

  Future<PasswordResetRequestResult> requestPasswordReset(String email) async {
    try {
      final response = await _apiService.post(
        '/request-password-reset',
        body: {
          'email': email.trim(),
          'lang': 'de',
        },
        includeAuth: false,
      );

      if (response['success'] == true) {
        return PasswordResetRequestResult.success(
          response['message']?.toString() ??
              'Falls ein Konto mit dieser E-Mail existiert, erhalten Sie in Kürze eine E-Mail mit einem Link zum Zurücksetzen Ihres Passworts.',
        );
      }

      return PasswordResetRequestResult.failure(
        localizeLoginError(response['error']?.toString() ?? 'Anfrage fehlgeschlagen'),
      );
    } on ApiException catch (e) {
      return PasswordResetRequestResult.failure(localizeLoginError(e.message));
    } catch (e) {
      return PasswordResetRequestResult.failure('Unexpected error: $e');
    }
  }

  Future<PasswordResetResult> resetPassword({
    required String token,
    required String password,
  }) async {
    try {
      final response = await _apiService.post(
        '/reset-password',
        body: {
          'token': token,
          'password': password,
          'lang': 'de',
        },
        includeAuth: false,
      );

      if (response['success'] == true) {
        return PasswordResetResult.success(
          response['message']?.toString() ??
              'Ihr Passwort wurde erfolgreich geändert. Sie können sich jetzt anmelden.',
        );
      }

      String error = 'Passwort zurücksetzen fehlgeschlagen';
      if (response['error'] != null) {
        error = localizeLoginError(response['error'].toString());
      } else if (response['validation'] != null) {
        if (response['validation'] is List) {
          error = (response['validation'] as List).map((e) => e.toString()).join(', ');
        } else {
          error = response['validation'].toString();
        }
      }
      return PasswordResetResult.failure(error);
    } on ApiException catch (e) {
      return PasswordResetResult.failure(localizeLoginError(e.message));
    } catch (e) {
      return PasswordResetResult.failure('Unexpected error: $e');
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

class PasswordResetRequestResult {
  final bool success;
  final String? message;
  final String? error;

  PasswordResetRequestResult.success(this.message)
      : success = true,
        error = null;

  PasswordResetRequestResult.failure(this.error)
      : success = false,
        message = null;
}

class PasswordResetResult {
  final bool success;
  final String? message;
  final String? error;

  PasswordResetResult.success(this.message)
      : success = true,
        error = null;

  PasswordResetResult.failure(this.error)
      : success = false,
        message = null;
}
