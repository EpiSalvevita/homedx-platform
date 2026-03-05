import 'package:shared_preferences/shared_preferences.dart';
import '../utils/constants.dart';
import 'api_service.dart';

class AuthService {
  final ApiService _apiService;
  SharedPreferences? _prefs;

  AuthService(this._apiService);

  Future<void> _initPrefs() async {
    _prefs ??= await SharedPreferences.getInstance();
  }

  Future<String?> getStoredToken() async {
    await _initPrefs();
    return _prefs?.getString(AppConstants.keyAuthToken);
  }

  Future<String?> getStoredUserId() async {
    await _initPrefs();
    return _prefs?.getString(AppConstants.keyUserId);
  }

  Future<String?> getStoredUserEmail() async {
    await _initPrefs();
    return _prefs?.getString(AppConstants.keyUserEmail);
  }

  Future<void> _storeToken(String token) async {
    await _initPrefs();
    await _prefs?.setString(AppConstants.keyAuthToken, token);
    _apiService.setAuthToken(token);
  }

  Future<void> _storeUserData(String userId, String email) async {
    await _initPrefs();
    await _prefs?.setString(AppConstants.keyUserId, userId);
    await _prefs?.setString(AppConstants.keyUserEmail, email);
  }

  Future<void> _clearStoredData() async {
    await _initPrefs();
    await _prefs?.remove(AppConstants.keyAuthToken);
    await _prefs?.remove(AppConstants.keyUserId);
    await _prefs?.remove(AppConstants.keyUserEmail);
    _apiService.setAuthToken(null);
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
        
        // Try to get user data to store user info
        try {
          _apiService.setAuthToken(token);
          final userDataResponse = await _apiService.post('/get-user-data');
          if (userDataResponse['success'] == true && userDataResponse['userdata'] != null) {
            final userData = userDataResponse['userdata'] as Map<String, dynamic>;
            await _storeUserData(
              userData['id']?.toString() ?? '',
              userData['email']?.toString() ?? email,
            );
          }
        } catch (_) {
          // If we can't get user data, just store email
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

  Future<void> logout() async {
    await _clearStoredData();
  }

  Future<bool> isLoggedIn() async {
    final token = await getStoredToken();
    if (token != null) {
      _apiService.setAuthToken(token);
      return true;
    }
    return false;
  }

  Future<void> restoreSession() async {
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

