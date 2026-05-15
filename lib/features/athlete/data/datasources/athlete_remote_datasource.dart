import 'package:dio/dio.dart';

import '../../../../core/error/api_exception.dart';
import '../../../../core/network/api_client.dart';
import '../models/athlete_model.dart';

/// Handles all raw HTTP calls for the Athlete module.
///
/// THIS IS THE ONLY FILE THAT KNOWS ABOUT DIO / HTTP.
/// The repository calls this and maps results to domain entities.
///
/// PATTERN FOR OTHER MODULES:
///   1. Create a `<feature>_remote_datasource.dart` like this one.
///   2. Each method does ONE API call and returns a model (or list of models).
///   3. Throw [ApiException] / [NetworkException] — never raw DioException.
class AthleteRemoteDatasource {
  final Dio _dio = ApiClient.instance;

  /// `GET /rest/v1/athletes?athlete_id=eq.<id>&select=*,athlete_details(*),athlete_family(*)`
  ///
  /// Supabase REST always returns a JSON array even for a single row.
  /// We take [first] and throw [ApiException] if not found.
  Future<AthleteModel> getAthleteProfile(String athleteId) async {
    try {
      final response = await _dio.get(
        '/athletes',
        queryParameters: {
          'athlete_id': 'eq.$athleteId',
          'select': '*,athlete_details(*),athlete_family(*)',
        },
      );

      final list = response.data as List<dynamic>;
      if (list.isEmpty) {
        throw ApiException('Athlete not found: $athleteId', statusCode: 404);
      }

      return AthleteModel.fromJson(list.first as Map<String, dynamic>);
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  /// POST /rest/v1/athletes
  ///
  /// Supabase returns the created row when `Prefer: return=representation`
  /// header is sent. We read it back so the BLoC gets the persisted record.
  Future<AthleteModel> createAthlete(Map<String, dynamic> body) async {
    try {
      final response = await _dio.post(
        '/athletes',
        data: body,
        options: Options(
          // Tell Supabase to return the created row in the response body
          headers: {'Prefer': 'return=representation'},
        ),
      );

      final list = response.data as List<dynamic>;
      return AthleteModel.fromJson(list.first as Map<String, dynamic>);
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  /// Maps DioException → our own exception types so callers never depend on Dio.
  Exception _handleDioError(DioException e) {
    if (e.type == DioExceptionType.connectionError ||
        e.type == DioExceptionType.connectionTimeout) {
      return const NetworkException();
    }

    final statusCode = e.response?.statusCode ?? 0;
    final body = e.response?.data?.toString() ?? e.message ?? 'Unknown error';
    return ApiException.fromStatusCode(statusCode, body);
  }
}
