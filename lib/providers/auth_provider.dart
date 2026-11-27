import 'package:flutter/foundation.dart';
import '../models/user_model.dart';
import '../services/api_service.dart';
import '../services/auth_service.dart';

enum AuthStatus { unknown, authenticated, unauthenticated }

/// Outcome of validating the locally stored Sanctum token on app startup.
enum SessionCheckResult {
  authenticated,
  noToken,
  invalidToken,
  networkError,
}

/// Application-wide authentication state provider backed by Sanctum tokens.
class AuthProvider extends ChangeNotifier {
  AuthProvider({AuthService? authService, ApiService? apiService})
      : _authService = authService ?? AuthService(),
        _apiService = apiService ?? ApiService.instance {
    _apiService.onUnauthorized = handleSessionExpired;
  }

  final AuthService _authService;
  final ApiService _apiService;

  AuthStatus _status = AuthStatus.unknown;
  UserModel? _user;
  bool _isLoading = false;
  String? _errorMessage;

  AuthStatus get status => _status;
  UserModel? get user => _user;
  bool get isLoading => _isLoading;
  bool get isAuthenticated => _status == AuthStatus.authenticated;
  String? get errorMessage => _errorMessage;

  void clearError() {
    if (_errorMessage != null) {
      _errorMessage = null;
      notifyListeners();
    }
  }

  /// Checks SharedPreferences for a saved token and validates it against GET /user.
  Future<SessionCheckResult> verifySession() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final token = await _apiService.getToken();
      if (token == null || token.trim().isEmpty) {
        _user = null;
        _status = AuthStatus.unauthenticated;
        return SessionCheckResult.noToken;
      }

      final currentUser = await _authService.fetchCurrentUser();
      _user = currentUser;
      _status = AuthStatus.authenticated;
      return SessionCheckResult.authenticated;
    } on ApiException catch (e) {
      if (e.statusCode == 401 || e.statusCode == 403) {
        await _apiService.clearToken();
        _user = null;
        _status = AuthStatus.unauthenticated;
        _errorMessage =
            'Your session has expired or is invalid. Please sign in again.';
        return SessionCheckResult.invalidToken;
      }

      _user = null;
      _status = AuthStatus.unknown;
      _errorMessage = e.message;
      return SessionCheckResult.networkError;
    } catch (e) {
      _user = null;
      _status = AuthStatus.unknown;
      _errorMessage = e.toString();
      return SessionCheckResult.networkError;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Convenience boolean wrapper around [verifySession].
  Future<bool> checkAuthStatus() async {
    final result = await verifySession();
    return result == SessionCheckResult.authenticated;
  }

  Future<bool> login({
    required String email,
    required String password,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final result = await _authService.login(
        email: email,
        password: password,
      );
      if (result.token == null || result.token!.isEmpty) {
        _errorMessage = 'Authentication token was not returned by server.';
        _status = AuthStatus.unauthenticated;
        return false;
      }

      _user = result.user ?? await _authService.fetchCurrentUser();
      _status = AuthStatus.authenticated;
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      _status = AuthStatus.unauthenticated;
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<({bool success, bool hasToken, String? message})> register({
    required String name,
    required String email,
    required String password,
    required String passwordConfirmation,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final result = await _authService.register(
        name: name,
        email: email,
        password: password,
        passwordConfirmation: passwordConfirmation,
      );

      final hasToken = result.token != null && result.token!.isNotEmpty;
      if (hasToken) {
        _user = result.user ?? await _authService.fetchCurrentUser();
        _status = AuthStatus.authenticated;
      } else {
        _user = null;
        _status = AuthStatus.unauthenticated;
      }

      return (
        success: true,
        hasToken: hasToken,
        message: result.message,
      );
    } catch (e) {
      _errorMessage = e.toString();
      return (
        success: false,
        hasToken: false,
        message: _errorMessage,
      );
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> refreshUser() async {
    try {
      _user = await _authService.fetchCurrentUser();
      _status = AuthStatus.authenticated;
      notifyListeners();
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
    }
  }

  Future<bool> logout() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      await _authService.logout();
      _user = null;
      _status = AuthStatus.unauthenticated;
      return true;
    } catch (e) {
      // Token is cleared in finally inside AuthService.logout()
      _user = null;
      _status = AuthStatus.unauthenticated;
      _errorMessage = e.toString();
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void handleSessionExpired() {
    _user = null;
    _status = AuthStatus.unauthenticated;
    notifyListeners();
  }
}
