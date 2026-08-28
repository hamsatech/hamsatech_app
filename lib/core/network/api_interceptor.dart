import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

/// Dio interceptor that logs requests, responses, and errors in debug builds.
///
/// Error handling maps [DioExceptionType] variants to human-readable messages.
/// Hook Sentry / Crashlytics inside [onError] for production observability.
class ApiInterceptor extends Interceptor {
  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    if (kDebugMode) {
      debugPrint('[API →] ${options.method} ${options.uri}');
      debugPrint('   Accept-Profile  : ${options.headers['Accept-Profile']}');
      debugPrint('   Content-Profile : ${options.headers['Content-Profile']}');
      debugPrint('   Content-Type    : ${options.headers['Content-Type']}');
      if (options.queryParameters.isNotEmpty) {
        debugPrint('   params: ${options.queryParameters}');
      }
      if (options.data != null) {
        debugPrint('   body: ${options.data}');
      }
    }
    handler.next(options);
  }

  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) {
    if (kDebugMode) {
      debugPrint(
        '[API ←] ${response.statusCode} ${response.requestOptions.uri}',
      );
      debugPrint('   data: ${response.data}');
    }
    handler.next(response);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    if (kDebugMode) {
      debugPrint('[API ✕] ${_typeLabel(err.type)} ${err.requestOptions.uri}');
      if (err.response != null) {
        debugPrint('   status : ${err.response?.statusCode}');
        debugPrint('   body   : ${err.response?.data}');
      } else {
        debugPrint('   message: ${err.message}');
      }
    }
    handler.next(err);
  }

  String _typeLabel(DioExceptionType type) {
    switch (type) {
      case DioExceptionType.connectionTimeout:
        return 'CONNECTION_TIMEOUT';
      case DioExceptionType.sendTimeout:
        return 'SEND_TIMEOUT';
      case DioExceptionType.receiveTimeout:
        return 'RECEIVE_TIMEOUT';
      case DioExceptionType.connectionError:
        return 'CONNECTION_ERROR';
      case DioExceptionType.badResponse:
        return 'BAD_RESPONSE';
      case DioExceptionType.cancel:
        return 'CANCELLED';
      case DioExceptionType.badCertificate:
        return 'BAD_CERTIFICATE';
      case DioExceptionType.unknown:
        return 'UNKNOWN';
    }
  }
}
