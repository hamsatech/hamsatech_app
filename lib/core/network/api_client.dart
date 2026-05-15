import 'package:dio/dio.dart';
import '../config/app_config.dart';

/// Singleton Dio client pre-configured for Supabase REST API.
///
/// HOW TO USE IN A DATASOURCE:
///   final response = await ApiClient.instance.get('/athletes', params: {...});
///
/// HOW TO PASS AUTH TOKEN (after login):
///   ApiClient.setAuthToken(supabaseJwtToken);
class ApiClient {
  ApiClient._();

  static final Dio _dio = _buildDio();

  static Dio get instance => _dio;

  static Dio _buildDio() {
    final dio = Dio(
      BaseOptions(
        baseUrl: AppConfig.restBaseUrl,
        connectTimeout: const Duration(seconds: 10),
        receiveTimeout: const Duration(seconds: 10),
        headers: {
          // Supabase requires both of these on every request
          'apikey': AppConfig.supabaseAnonKey,
          'Authorization': 'Bearer ${AppConfig.supabaseAnonKey}',
          'Content-Type': 'application/json',
        },
      ),
    );

    // Attach interceptor for logging and future auth token injection
    dio.interceptors.add(_SupabaseInterceptor());

    return dio;
  }

  /// Call this after the user logs in to switch from anon key to JWT.
  /// All subsequent requests will carry the user's session token.
  static void setAuthToken(String jwtToken) {
    _dio.options.headers['Authorization'] = 'Bearer $jwtToken';
  }

  /// Revert to anon key (e.g. after logout).
  static void clearAuthToken() {
    _dio.options.headers['Authorization'] =
        'Bearer ${AppConfig.supabaseAnonKey}';
  }
}

class _SupabaseInterceptor extends Interceptor {
  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    // Future place to inject a refreshed JWT from secure storage
    super.onRequest(options, handler);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    // Centralised error logging — add Sentry/Crashlytics here later
    super.onError(err, handler);
  }
}
