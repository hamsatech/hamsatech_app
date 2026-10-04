import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hamsatech/features/live_training/data/services/hr_telemetry_service.dart';
import 'package:hamsatech/features/polar/data/services/polar_ble_service.dart';
import 'package:hamsatech/features/polar/domain/models/hr_reading.dart';

HrReading _reading({required int bpm, List<int> rr = const []}) => HrReading(
      bpm: bpm,
      rrIntervals: rr,
      sensorContact: true,
      timestamp: DateTime.now(),
    );

Response<dynamic> _fakeSuccessResponse() => Response(
      requestOptions: RequestOptions(path: 'api/v2/heart-rate/samples'),
      statusCode: 200,
    );

DioException _fakeStatusError(int statusCode) => DioException(
      requestOptions: RequestOptions(path: 'api/v2/heart-rate/samples'),
      response: Response(
        requestOptions: RequestOptions(path: 'api/v2/heart-rate/samples'),
        statusCode: statusCode,
      ),
      type: DioExceptionType.badResponse,
    );

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('flushNow() is a no-op when nothing is pending', () async {
    final service = HrTelemetryService(PolarBleService());
    addTearDown(service.dispose);

    expect(service.pendingCount, 0);

    // Must return promptly without attempting any network call — there is
    // nothing buffered, so this must not throw or hang.
    await service.flushNow();

    expect(service.pendingCount, 0);
    expect(service.bufferLength, 0);
  });

  group('sanitizeRrInterval (SESSION-1 — validate before buffering)', () {
    test('a valid rr_interval is kept unchanged', () {
      final reading = _reading(bpm: 72, rr: [800]);
      final result = HrTelemetryService.sanitizeRrInterval(reading);
      expect(result.rrIntervals, [800]);
      expect(result.bpm, 72);
    });

    test('an rr_interval below the valid range (< 200ms) is dropped, bpm kept', () {
      final reading = _reading(bpm: 72, rr: [50]);
      final result = HrTelemetryService.sanitizeRrInterval(reading);
      expect(result.rrIntervals, isEmpty,
          reason: 'the invalid RR value must never reach the buffer');
      expect(result.bpm, 72, reason: 'a bad RR must not discard a good bpm');
    });

    test('an rr_interval above the valid range (> 3000ms) is dropped, bpm kept', () {
      final reading = _reading(bpm: 65, rr: [5000]);
      final result = HrTelemetryService.sanitizeRrInterval(reading);
      expect(result.rrIntervals, isEmpty);
      expect(result.bpm, 65);
    });

    test('never fabricates or clamps a value — an invalid RR becomes absent, '
        'not a corrected number', () {
      final reading = _reading(bpm: 72, rr: [1]);
      final result = HrTelemetryService.sanitizeRrInterval(reading);
      expect(result.rrIntervals, isEmpty);
      expect(result.rrIntervals, isNot(contains(200)));
      expect(result.rrIntervals, isNot(contains(3000)));
    });

    test('a reading with no rr data at all passes through unchanged', () {
      final reading = _reading(bpm: 80);
      final result = HrTelemetryService.sanitizeRrInterval(reading);
      expect(result.rrIntervals, isEmpty);
      expect(result.bpm, 80);
    });
  });

  group('poison-batch recovery (SESSION-1 — never block the stream forever)', () {
    test(
        'a permanently-rejected batch (HTTP 422) is dropped, freeing the '
        'stream to accept new valid samples instead of resending it forever',
        () async {
      var uploadCalls = 0;
      final service = HrTelemetryService(
        PolarBleService(),
        flushBatchSize: 1,
        uploadFn: (payload) async {
          uploadCalls++;
          throw _fakeStatusError(422);
        },
      );
      addTearDown(service.dispose);
      service.setActiveSessionId('session-1');

      service.debugInjectReading(_reading(bpm: 72));
      // flushBatchSize: 1 triggers _flush() synchronously inside
      // debugInjectReading -> _onHrReading, but the upload itself is
      // unawaited (fire-and-forget) — give it a turn to actually run.
      await Future<void>.delayed(Duration.zero);

      expect(uploadCalls, 1);
      expect(service.pendingCount, 0,
          reason: 'a 422 means this exact batch will never be accepted — '
              'it must be dropped, not retried forever');
      expect(service.bufferLength, 0, reason: 'the dropped batch must also be trimmed');

      // A new, valid sample arriving afterward must upload normally — the
      // earlier permanent rejection must not have wedged the stream.
      service.debugInjectReading(_reading(bpm: 75));
      await Future<void>.delayed(Duration.zero);

      expect(uploadCalls, 2,
          reason: 'the next sample must trigger its own, independent upload');
    });

    test(
        'a transient failure (network/5xx) is NOT dropped — it stays '
        'pending for the next retry, unlike a permanent 4xx rejection',
        () async {
      var uploadCalls = 0;
      final service = HrTelemetryService(
        PolarBleService(),
        flushBatchSize: 1,
        uploadFn: (payload) async {
          uploadCalls++;
          throw _fakeStatusError(503);
        },
      );
      addTearDown(service.dispose);
      service.setActiveSessionId('session-1');

      service.debugInjectReading(_reading(bpm: 72));
      await Future<void>.delayed(Duration.zero);

      expect(uploadCalls, 1);
      expect(service.pendingCount, 1,
          reason: 'a 503 is transient — the sample must remain queued for '
              'the next periodic retry, not be discarded');
    });

    test('a successful upload trims the buffer instead of retaining every '
        'sample for the whole session', () async {
      final service = HrTelemetryService(
        PolarBleService(),
        flushBatchSize: 1,
        uploadFn: (payload) async => _fakeSuccessResponse(),
      );
      addTearDown(service.dispose);
      service.setActiveSessionId('session-1');

      service.debugInjectReading(_reading(bpm: 72));
      await Future<void>.delayed(Duration.zero);

      expect(service.pendingCount, 0);
      expect(service.bufferLength, 0,
          reason: 'already-uploaded samples must not accumulate in memory '
              'for the rest of the session');
    });

    test('an out-of-range bpm is skipped entirely (unchanged pre-existing '
        'behavior) and never reaches upload', () async {
      var uploadCalls = 0;
      final service = HrTelemetryService(
        PolarBleService(),
        flushBatchSize: 1,
        uploadFn: (payload) async {
          uploadCalls++;
          return _fakeSuccessResponse();
        },
      );
      addTearDown(service.dispose);
      service.setActiveSessionId('session-1');

      service.debugInjectReading(_reading(bpm: 400)); // > 250, invalid
      await Future<void>.delayed(Duration.zero);

      expect(service.pendingCount, 0);
      expect(uploadCalls, 0);
    });
  });
}
