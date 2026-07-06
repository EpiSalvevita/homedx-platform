import 'package:flutter/foundation.dart';
import '../services/auth_service.dart';

class AuthProvider with ChangeNotifier {
  final AuthService _authService;
  bool _isAuthenticated = false;
  bool _isLoading = false;
  String? _error;
  String? _userId;
  String? _userEmail;
  String? _userRole;
  String? _displayName;

  AuthProvider(this._authService);

  bool get isAuthenticated => _isAuthenticated;
  bool get isLoading => _isLoading;
  String? get error => _error;
  String? get userId => _userId;
  String? get userEmail => _userEmail;
  String? get userRole => _userRole;
  bool get isDoctor => _userRole == 'DOCTOR';

  /// Full name, populated lazily once any screen loads the user's profile
  /// (see [UserService.getUserData]). Falls back to the email prefix in the UI
  /// until then, so this is cache-only — never fetched here directly.
  String? get displayName => _displayName;

  void setDisplayName(String name) {
    final trimmed = name.trim();
    if (trimmed.isEmpty || trimmed == _displayName) return;
    _displayName = trimmed;
    notifyListeners();
  }
  bool get isEstablishingSession => _isEstablishingSession;

  bool _isEstablishingSession = false;

  Future<void> initialize() async {
    _setLoading(true);
    try {
      final isLoggedIn = await _authService.isLoggedIn();
      if (isLoggedIn) {
        await _authService.restoreSession();
        _userId = await _authService.getStoredUserId();
        _userEmail = await _authService.getStoredUserEmail();
        _userRole = await _authService.getStoredUserRole();
        _isAuthenticated = true;
      }
    } catch (e) {
      _setError('Failed to restore session: $e');
    } finally {
      _setLoading(false);
    }
  }

  Future<bool> login(String email, String password) async {
    _isEstablishingSession = true;
    _setLoading(true);
    _setError(null);

    try {
      final result = await _authService.login(email, password);

      if (result.success) {
        if (result.token != null) {
          await _authService.applySessionToken(result.token!);
        }
        _userId = await _authService.getStoredUserId();
        _userEmail = await _authService.getStoredUserEmail();
        _userRole = await _authService.getStoredUserRole();
        _isAuthenticated = true;
        notifyListeners();
        Future.microtask(() => _isEstablishingSession = false);
        return true;
      } else {
        _isEstablishingSession = false;
        _setError(result.error ?? 'Login failed');
        return false;
      }
    } catch (e) {
      _isEstablishingSession = false;
      _setError('Unexpected error: $e');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  Future<bool> register({
    required String email,
    required String password,
    required String firstName,
    required String lastName,
    bool registerAsDoctor = false,
    String? specialization,
    String? clinicAddress,
  }) async {
    _setLoading(true);
    _setError(null);
    
    try {
      final result = await _authService.register(
        email: email,
        password: password,
        firstName: firstName,
        lastName: lastName,
        registerAsDoctor: registerAsDoctor,
        specialization: specialization,
        clinicAddress: clinicAddress,
      );
      
      if (result.success) {
        _setLoading(false);
        return true;
      } else {
        _setError(result.error ?? 'Registration failed');
        return false;
      }
    } catch (e) {
      _setError('Unexpected error: $e');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  Future<void> logout() async {
    if (!_isAuthenticated) return;

    _isAuthenticated = false;
    _userId = null;
    _userEmail = null;
    _userRole = null;
    _displayName = null;
    notifyListeners();

    _setLoading(true);
    try {
      await _authService.logout();
    } catch (e) {
      _setError('Logout error: $e');
    } finally {
      _setLoading(false);
    }
  }

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  void _setError(String? value) {
    _error = value;
    notifyListeners();
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }
}

