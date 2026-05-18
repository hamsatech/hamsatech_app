import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import '../constants/api_constants.dart';

/// Lightweight Dio client for direct Supabase REST calls.
///
/// PATH RULE: never start a path with '/' here.
/// baseUrl already ends with '/'. Dio concatenates them as a plain string:
///   baseUrl + path → 'https://.../rest/v1/' + 'sessions' = '.../rest/v1/sessions' ✓
///   baseUrl + path → 'https://.../rest/v1/' + '/sessions' = '.../rest/v1//sessions' ✗ (404)
class ApiService {
  ApiService._() : _dio = _buildDio();

  static final ApiService instance = ApiService._();

  final Dio _dio;

  static Dio _buildDio() {
    final dio = Dio(
      BaseOptions(
        baseUrl: ApiConstants.baseUrl,
        connectTimeout: const Duration(seconds: 10),
        receiveTimeout: const Duration(seconds: 10),
        headers: {
          'apikey': ApiConstants.anonKey,
          'Authorization': 'Bearer ${ApiConstants.anonKey}',
          'Content-Type': 'application/json',
        },
      ),
    );
    dio.interceptors.add(_DebugInterceptor());
    return dio;
  }

  /// GET rest/v1/athletes
  Future<Response<dynamic>> getAthletes() => _dio.get('athletes');

  /// POST rest/v1/sessions
  ///
  /// Supabase returns the inserted row when `Prefer: return=representation`
  /// is set. The response body is a JSON array with one element.
  Future<Response<dynamic>> createSession({
    required String athleteId,
    required String sessionType,
    required String startTime,
  }) {
    return _dio.post(
      'sessions',
      data: {
        'athlete_id': athleteId,
        'session_type': sessionType,
        'start_time': startTime,
      },
      options: Options(
        headers: {'Prefer': 'return=representation'},
      ),
    );
  }
}

// ── Debug interceptor ─────────────────────────────────────────────────────────

class _DebugInterceptor extends Interceptor {
  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    if (kDebugMode) {
      debugPrint('╔══════════════════════════════════════════╗');
      debugPrint('║  [API REQUEST]                           ║');
      debugPrint('╠══════════════════════════════════════════╣');
      debugPrint('║  ${options.method} ${options.uri}');
      debugPrint('║  Headers:');
      options.headers.forEach(
        (k, v) => debugPrint('║    $k: $v'),
      );
      if (options.data != null) {
        debugPrint('║  Body: ${options.data}');
      }
      debugPrint('╚══════════════════════════════════════════╝');
    }
    handler.next(options);
  }

  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) {
    if (kDebugMode) {
      debugPrint('╔══════════════════════════════════════════╗');
      debugPrint('║  [API RESPONSE] ${response.statusCode}               ║');
      debugPrint('╠══════════════════════════════════════════╣');
      debugPrint('║  URL: ${response.requestOptions.uri}');
      debugPrint('║  Data: ${response.data}');
      debugPrint('╚══════════════════════════════════════════╝');
    }
    handler.next(response);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    if (kDebugMode) {
      debugPrint('╔══════════════════════════════════════════╗');
      debugPrint('║  [API ERROR] ${err.type.name}');
      debugPrint('╠══════════════════════════════════════════╣');
      debugPrint('║  URL    : ${err.requestOptions.uri}');
      debugPrint('║  Status : ${err.response?.statusCode}');
      debugPrint('║  Body   : ${err.response?.data}');
      debugPrint('║  Message: ${err.message}');
      debugPrint('╚══════════════════════════════════════════╝');
    }
    handler.next(err);
  }
}
