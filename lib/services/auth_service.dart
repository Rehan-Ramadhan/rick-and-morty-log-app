import 'package:flutter/foundation.dart';

import '../constants/api_constant.dart';
import '../models/user_model.dart';
import 'api_service.dart';

class AuthResult {
  const AuthResult({this.user, this.token, this.message});

  final UserModel? user;
  final String? token;
  final String? message;
}

/// Authentication service integrating Laravel Sanctum endpoints.
class AuthService {
  AuthService({ApiService? apiService})
    : _api = apiService ?? ApiService.instance;

  final ApiService _api;

  Future<AuthResult> login({
    required String email,
    required String password,
  }) async {
    try {
      final response = await _api.backendDio.post(
        ApiConstant.login,
        data: {'email': email.trim(), 'password': password},
      );

      return await _handleAuthResponse(response.data);
    } catch (e, stackTrace) {
      debugPrint('========== LOGIN ERROR ==========');
      debugPrint('ERROR TYPE: ${e.runtimeType}');
      debugPrint('ERROR: $e');
      debugPrint('STACK TRACE: $stackTrace');
      debugPrint('=================================');

      throw _api.parseError(e);
    }
  }

  Future<AuthResult> register({
    required String name,
    required String email,
    required String password,
    required String passwordConfirmation,
  }) async {
    try {
      final response = await _api.backendDio.post(
        ApiConstant.register,
        data: {
          'name': name.trim(),
          'email': email.trim(),
          'password': password,
          'password_confirmation': passwordConfirmation,
        },
      );

      return await _handleAuthResponse(response.data);
    } catch (e) {
      throw _api.parseError(e);
    }
  }

  Future<UserModel> fetchCurrentUser() async {
    try {
      final response = await _api.backendDio.get(ApiConstant.user);
      final map = _api.unwrapObject(response.data, keys: const ['user']);

      return UserModel.fromJson(map);
    } catch (e) {
      throw _api.parseError(e);
    }
  }

  Future<void> logout() async {
    try {
      await _api.backendDio.post(ApiConstant.logout);
    } catch (e) {
      throw _api.parseError(e);
    } finally {
      await _api.clearToken();
    }
  }

  Future<AuthResult> _handleAuthResponse(dynamic raw) async {
    if (raw is! Map<String, dynamic>) {
      throw ApiException('Invalid authentication response.');
    }

    final payload = raw['data'] is Map<String, dynamic>
        ? raw['data'] as Map<String, dynamic>
        : raw;

    final token =
        (payload['token'] ??
                payload['access_token'] ??
                raw['token'] ??
                raw['access_token'])
            ?.toString();

    if (token != null && token.isNotEmpty) {
      await _api.saveToken(token);
    }

    UserModel? user;
    final rawUser = payload['user'] ?? raw['user'];

    if (rawUser is Map<String, dynamic>) {
      user = UserModel.fromJson(rawUser);
    } else if (token != null && token.isNotEmpty) {
      try {
        user = await fetchCurrentUser();
      } catch (_) {
        // User info can be fetched again when needed.
      }
    }

    return AuthResult(
      user: user,
      token: token,
      message: raw['message']?.toString(),
    );
  }
}
