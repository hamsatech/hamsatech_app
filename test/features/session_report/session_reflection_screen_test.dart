import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hamsatech/core/services/session_memory.dart';
import 'package:hamsatech/core/services/storage_service.dart';
import 'package:hamsatech/features/session_report/presentation/screens/session_reflection_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// SessionReflectionScreen — reached at the end of the non-Polar scoring
/// path — previously had no bloc, repository, or API call at all: mood and
/// all five text fields were silently discarded on dispose. This locks down
/// the identity-resolution rule the fix now enforces before it will ever
/// call POST .../reflection: a missing session or athlete_id must raise,
/// not silently report success (matching LiveTrainingRepositoryImpl's
/// saveReflection on the Polar path, which already worked this way).
void main() {
  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    await StorageService.init();
    SessionMemory.sessionId = null;
  });

  tearDown(() {
    SessionMemory.sessionId = null;
  });

  test('throws when there is no session_id in memory or storage', () {
    expect(
      resolveReflectionIdentity,
      throwsA(isA<StateError>()),
    );
  });

  test(
    'throws when a session_id is known but no athlete_id has been resolved '
    '(e.g. onboarding incomplete) — must not silently succeed',
    () {
      SessionMemory.sessionId = 'session-123';
      // No athlete_id seeded in StorageService/SharedPreferences.

      expect(
        resolveReflectionIdentity,
        throwsA(isA<StateError>()),
      );
    },
  );

  test(
    'resolves both ids from SessionMemory/StorageService when available',
    () async {
      SessionMemory.sessionId = 'session-123';
      await StorageService.saveAthleteId('ASA001');

      final identity = resolveReflectionIdentity();

      expect(identity.sessionId, 'session-123');
      expect(identity.athleteId, 'ASA001');
    },
  );

  test(
    'falls back to the persisted StorageService session_id when '
    'SessionMemory has been cleared (e.g. app restart)',
    () async {
      await StorageService.saveSessionId('persisted-session-id');
      await StorageService.saveAthleteId('ASA001');
      // SessionMemory.sessionId intentionally left null by setUp().

      final identity = resolveReflectionIdentity();

      expect(identity.sessionId, 'persisted-session-id');
    },
  );

  group('classifyReflectionSaveError', () {
    DioException httpError(int statusCode) {
      final requestOptions = RequestOptions(path: '/reflection');
      return DioException(
        requestOptions: requestOptions,
        type: DioExceptionType.badResponse,
        response:
            Response(requestOptions: requestOptions, statusCode: statusCode),
      );
    }

    test(
        'a missing session/athlete_id (StateError) classifies as missingSessionId',
        () {
      expect(
        classifyReflectionSaveError(StateError('no session')),
        ReflectionSaveErrorKind.missingSessionId,
      );
    });

    test('HTTP 401 classifies as unauthorized', () {
      expect(classifyReflectionSaveError(httpError(401)),
          ReflectionSaveErrorKind.unauthorized);
    });

    test('HTTP 403 classifies as forbidden', () {
      expect(classifyReflectionSaveError(httpError(403)),
          ReflectionSaveErrorKind.forbidden);
    });

    test('HTTP 404 classifies as notFound', () {
      expect(classifyReflectionSaveError(httpError(404)),
          ReflectionSaveErrorKind.notFound);
    });

    test('HTTP 422 classifies as validation', () {
      expect(classifyReflectionSaveError(httpError(422)),
          ReflectionSaveErrorKind.validation);
    });

    test('HTTP 500 (and other 5xx) classifies as serverError', () {
      expect(classifyReflectionSaveError(httpError(500)),
          ReflectionSaveErrorKind.serverError);
      expect(classifyReflectionSaveError(httpError(503)),
          ReflectionSaveErrorKind.serverError);
    });

    test('connect/send/receive timeouts all classify as timeout', () {
      final requestOptions = RequestOptions(path: '/reflection');
      for (final type in [
        DioExceptionType.connectionTimeout,
        DioExceptionType.sendTimeout,
        DioExceptionType.receiveTimeout,
      ]) {
        final error = DioException(requestOptions: requestOptions, type: type);
        expect(classifyReflectionSaveError(error),
            ReflectionSaveErrorKind.timeout);
      }
    });

    test(
        'a dropped connection (connectionError) classifies as network, not timeout',
        () {
      final error = DioException(
        requestOptions: RequestOptions(path: '/reflection'),
        type: DioExceptionType.connectionError,
      );
      expect(
          classifyReflectionSaveError(error), ReflectionSaveErrorKind.network);
    });

    test('a completely unexpected exception classifies as unknown, not network',
        () {
      expect(classifyReflectionSaveError(Exception('boom')),
          ReflectionSaveErrorKind.unknown);
    });
  });

  group('reflectionSaveErrorMessage', () {
    test(
        'every kind has its own message — none of them fall back to the old '
        'generic "check your connection" wording for a non-network cause', () {
      final messages = {
        for (final kind in ReflectionSaveErrorKind.values)
          kind: reflectionSaveErrorMessage(kind),
      };

      // All nine messages must be distinct — this is the actual bug fix:
      // previously every kind collapsed to the same string.
      expect(messages.values.toSet().length,
          ReflectionSaveErrorKind.values.length);

      // Only the genuine connectivity failure should mention "connection".
      for (final kind in ReflectionSaveErrorKind.values) {
        if (kind == ReflectionSaveErrorKind.network) continue;
        expect(
          messages[kind]!.toLowerCase().contains('check your connection'),
          isFalse,
          reason: '$kind should not use the generic connection-check message',
        );
      }
    });

    test('the timeout message offers a retry, not a claim that data was lost',
        () {
      final message =
          reflectionSaveErrorMessage(ReflectionSaveErrorKind.timeout);
      expect(message.toLowerCase(), contains('retry'));
      expect(message.toLowerCase(), isNot(contains('lost')));
    });
  });
}
