/// Thrown when a Supabase REST call returns a non-2xx status or network error.
///
/// USAGE IN REPOSITORY IMPL:
///   on (DioException catch e) → wrap with ApiException.fromDio(e)
///   catch it in the BLoC → emit ErrorState(e.message)
class ApiException implements Exception {
  const ApiException(this.message, {this.statusCode});

  final String message;
  final int? statusCode;

  @override
  String toString() => 'ApiException($statusCode): $message';

  /// Common Supabase error codes worth catching explicitly:
  ///   400 → bad request / malformed query
  ///   401 → missing or invalid API key
  ///   403 → RLS policy denied the operation
  ///   404 → resource not found (empty result is usually [] not 404)
  ///   409 → unique constraint violation
  ///   500 → Supabase internal error
  static ApiException fromStatusCode(int statusCode, String body) {
    switch (statusCode) {
      case 401:
        return const ApiException('Unauthorized – check your API key.', statusCode: 401);
      case 403:
        return const ApiException('Forbidden – RLS policy denied this operation.', statusCode: 403);
      case 409:
        return const ApiException('Conflict – a record with this ID already exists.', statusCode: 409);
      default:
        return ApiException('Request failed ($statusCode): $body', statusCode: statusCode);
    }
  }
}

/// Thrown when the device has no internet connection.
class NetworkException implements Exception {
  const NetworkException();

  @override
  String toString() => 'NetworkException: No internet connection.';
}
