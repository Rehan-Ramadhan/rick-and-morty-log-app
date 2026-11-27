import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../constants/api_constant.dart';

/// Structured exception for Laravel backend and public API failures.
class ApiException implements Exception {
  ApiException(this.message, {this.statusCode});

  final String message;
  final int? statusCode;

  @override
  String toString() => message;
}

/// Centralized HTTP client managing Laravel Sanctum Bearer tokens and Dio instances.
class ApiService {
  ApiService._internal() {
    backendDio = Dio(
      BaseOptions(
        baseUrl: ApiConstant.baseUrl,
        connectTimeout: const Duration(seconds: 15),
        receiveTimeout: const Duration(seconds: 15),
        headers: const {
          'Accept': 'application/json',
          'Content-Type': 'application/json',
        },
      ),
    );

    backendDio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          final token = await getToken();
          if (token != null && token.isNotEmpty) {
            options.headers['Authorization'] = 'Bearer $token';
          }
          handler.next(options);
        },
        onError: (error, handler) async {
          if (error.response?.statusCode == 401) {
            final path = error.requestOptions.path;
            final isAuthEndpoint =
                path.endsWith(ApiConstant.login) ||
                path.endsWith(ApiConstant.register);
            if (!isAuthEndpoint) {
              await clearToken();
              onUnauthorized?.call();
            }
          }
          handler.next(error);
        },
      ),
    );

    publicDio = Dio(
      BaseOptions(
        connectTimeout: const Duration(seconds: 15),
        receiveTimeout: const Duration(seconds: 15),
        headers: const {
          'Accept': 'application/json',
        },
      ),
    );
  }

  static final ApiService instance = ApiService._internal();
  static const String _tokenKey = 'sanctum_auth_token';

  late final Dio backendDio;
  late final Dio publicDio;

  String? _cachedToken;
  void Function()? onUnauthorized;

  Future<String?> getToken() async {
    if (_cachedToken != null && _cachedToken!.isNotEmpty) {
      return _cachedToken;
    }
    final prefs = await SharedPreferences.getInstance();
    _cachedToken = prefs.getString(_tokenKey);
    return _cachedToken;
  }

  Future<void> saveToken(String token) async {
    _cachedToken = token;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_tokenKey, token);
  }

  Future<void> clearToken() async {
    _cachedToken = null;
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_tokenKey);
  }

  /// Extracts a human-readable error message from a DioException.
  ApiException parseError(Object error) {
    if (error is ApiException) return error;

    if (error is DioException) {
      final statusCode = error.response?.statusCode;
      final data = error.response?.data;

      if (data is Map<String, dynamic>) {
        final errors = data['errors'];
        if (errors is Map<String, dynamic> && errors.isNotEmpty) {
          final firstFieldErrors = errors.values.first;
          if (firstFieldErrors is List && firstFieldErrors.isNotEmpty) {
            return ApiException(
              firstFieldErrors.first.toString(),
              statusCode: statusCode,
            );
          }
        }
        if (data['message'] != null && data['message'].toString().isNotEmpty) {
          return ApiException(
            data['message'].toString(),
            statusCode: statusCode,
          );
        }
        if (data['error'] != null && data['error'].toString().isNotEmpty) {
          return ApiException(
            data['error'].toString(),
            statusCode: statusCode,
          );
        }
      }

      switch (error.type) {
        case DioExceptionType.connectionTimeout:
        case DioExceptionType.receiveTimeout:
        case DioExceptionType.sendTimeout:
          return ApiException(
            'Portal connection timed out. Please check your server.',
            statusCode: statusCode,
          );
        case DioExceptionType.connectionError:
          return ApiException(
            'Unable to reach server. Make sure backend & internet are active.',
            statusCode: statusCode,
          );
        default:
          return ApiException(
            error.message ?? 'Unexpected network anomaly occurred.',
            statusCode: statusCode,
          );
      }
    }

    return ApiException(error.toString());
  }

  /// Unwraps either direct object `{...}` or `{data: {...}}` / `{key: {...}}`.
  Map<String, dynamic> unwrapObject(dynamic raw, {List<String> keys = const []}) {
    if (raw is Map<String, dynamic>) {
      for (final key in keys) {
        final nested = raw[key];
        if (nested is Map<String, dynamic>) return nested;
      }
      final data = raw['data'];
      if (data is Map<String, dynamic>) return data;
      return raw;
    }
    throw ApiException('Invalid response format from server.');
  }

  /// Unwraps either direct list `[...]` or `{data: [...]}` / `{key: [...]}`.
  List<dynamic> unwrapList(dynamic raw, {List<String> keys = const []}) {
    if (raw is List) return raw;
    if (raw is Map<String, dynamic>) {
      for (final key in keys) {
        final nested = raw[key];
        if (nested is List) return nested;
      }
      final data = raw['data'];
      if (data is List) return data;
    }
    throw ApiException('Invalid list response format from server.');
  }
}
