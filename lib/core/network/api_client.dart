import 'package:dio/dio.dart';
import '../error/api_exception.dart';
import 'api_constants.dart';
import 'api_interceptor.dart';

/// Centralised Dio client pre-configured for the Supabase REST API.
///
/// INJECT via GetIt:
/// ```dart
/// final client = getIt<ApiClient>();
/// final data   = await client.get('/athletes', queryParameters: {...});
/// ```
///
/// LEGACY (existing datasources):
/// ```dart
/// final dio = ApiClient.instance; // returns the same underlying Dio
/// ```
///
/// AUTH TOKEN:
/// ```dart
/// ApiClient.setAuthToken(jwtToken); // after login
/// ApiClient.clearAuthToken();       // after logout
/// ```
class ApiClient {
  factory ApiClient() => _singleton;

  ApiClient._() : _dio = _buildDio();

  static final ApiClient _singleton = ApiClient._();

  /// Raw [Dio] accessor kept for backward-compatibility with existing datasources.
  static Dio get instance => _singleton._dio;

  final Dio _dio;

  // ── Auth helpers ──────────────────────────────────────────────────────────

  /// Switch from anon key to a user JWT after a successful login.
  static void setAuthToken(String jwtToken) {
    _singleton._dio.options.headers['Authorization'] = 'Bearer $jwtToken';
  }

  /// Revert to the anon key after logout.
  static void clearAuthToken() {
    _singleton._dio.options.headers['Authorization'] =
        'Bearer ${ApiConstants.supabaseAnonKey}';
  }

  // ── HTTP methods ──────────────────────────────────────────────────────────

  Future<dynamic> get(
    String path, {
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) {
    return _request(
      () => _dio.get<dynamic>(
        path,
        queryParameters: queryParameters,
        options: options,
      ),
    );
  }

  Future<dynamic> post(
    String path, {
    Object? data,
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) {
    return _request(
      () => _dio.post<dynamic>(
        path,
        data: data,
        queryParameters: queryParameters,
        options: options,
      ),
    );
  }

  Future<dynamic> patch(
    String path, {
    Object? data,
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) {
    return _request(
      () => _dio.patch<dynamic>(
        path,
        data: data,
        queryParameters: queryParameters,
        options: options,
      ),
    );
  }

  Future<dynamic> delete(
    String path, {
    Object? data,
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) {
    return _request(
      () => _dio.delete<dynamic>(
        path,
        data: data,
        queryParameters: queryParameters,
        options: options,
      ),
    );
  }

  // ── Private helpers ────────────────────────────────────────────────────────

  Future<dynamic> _request(
    Future<Response<dynamic>> Function() call,
  ) async {
    try {
      final response = await call();
      return response.data;
    } on DioException catch (e) {
      throw _mapDioError(e);
    }
  }

  static Exception _mapDioError(DioException e) {
    switch (e.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
      case DioExceptionType.connectionError:
        return const NetworkException();
      case DioExceptionType.badResponse:
        final statusCode = e.response?.statusCode ?? 0;
        final body =
            e.response?.data?.toString() ?? e.message ?? 'Unknown error';
        return ApiException.fromStatusCode(statusCode, body);
      case DioExceptionType.cancel:
        return const ApiException('Request cancelled.');
      case DioExceptionType.badCertificate:
        return const ApiException('SSL certificate error.');
      case DioExceptionType.unknown:
        return ApiException(e.message ?? 'An unexpected error occurred.');
    }
  }

  static Dio _buildDio() {
    final dio = Dio(
      BaseOptions(
        baseUrl: ApiConstants.baseUrl,
        connectTimeout: ApiConstants.connectTimeout,
        receiveTimeout: ApiConstants.receiveTimeout,
        sendTimeout: ApiConstants.sendTimeout,
        headers: {
          'apikey': ApiConstants.supabaseAnonKey,
          'Authorization': 'Bearer ${ApiConstants.supabaseAnonKey}',
          'Accept': 'application/json',
          'Content-Type': 'application/json',
          // Route all REST calls to hamsatech schema, not public.
          'Accept-Profile': 'hamsatech',
          'Content-Profile': 'hamsatech',
        },
      ),
    );
    dio.interceptors.add(ApiInterceptor());
    return dio;
  }
}
