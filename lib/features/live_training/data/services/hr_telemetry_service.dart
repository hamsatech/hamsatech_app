import 'dart:async';
import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

import '../../../../core/services/api_service.dart';
import '../../../polar/data/services/polar_ble_service.dart';
import '../../../polar/domain/models/hr_reading.dart';

class HrTelemetrySample {
  const HrTelemetrySample({
    required this.reading,
    required this.sessionId,
    required this.bufferedAt,
  });

  final HrReading reading;
  final String? sessionId;
  final DateTime bufferedAt;
}

/// Buffers HR samples from [PolarBleService.hrStream] in memory, tagged with
/// the active session id, and uploads batches to the hr_stream backend.
///
/// [_flushedUpTo] tracks how much of [_buffer] has been successfully
/// uploaded. Samples are never removed from [_buffer] — a batch only moves
/// the pointer forward once the backend has accepted it.
class HrTelemetryService {
  HrTelemetryService(
    this._polarBleService, {
    int flushBatchSize = 20,
    Duration flushInterval = const Duration(seconds: 10),
    // Testability seam only — defaults to the real backend call. Lets tests
    // exercise _uploadBatch's permanent-vs-transient failure handling with
    // a controlled DioException instead of needing real network access or
    // a mocking library (neither is used elsewhere in this codebase).
    @visibleForTesting
    Future<Response<dynamic>> Function(Map<String, dynamic>)? uploadFn,
  })  : _flushBatchSize = flushBatchSize,
        _flushInterval = flushInterval,
        _uploadFn = uploadFn ?? ApiService.instance.uploadHrSamples {
    _hrSubscription = _polarBleService.hrStream.listen(_onHrReading);
  }

  final PolarBleService _polarBleService;
  final int _flushBatchSize;
  final Duration _flushInterval;
  final Future<Response<dynamic>> Function(Map<String, dynamic>) _uploadFn;

  late final StreamSubscription<HrReading> _hrSubscription;
  Timer? _flushTimer;
  bool _isUploading = false;
  // Tracks the most recently started upload so flushNow() can await an
  // already-in-flight upload instead of racing/duplicating it.
  Future<void>? _currentUpload;

  final List<HrTelemetrySample> _buffer = [];
  int _flushedUpTo = 0; // index into _buffer already uploaded successfully
  String? _activeSessionId;

  String? get activeSessionId => _activeSessionId;
  int get bufferLength => _buffer.length;
  int get pendingCount => _buffer.length - _flushedUpTo;
  List<HrTelemetrySample> get bufferSnapshot => List.unmodifiable(_buffer);

  /// Testability seam only — feeds a reading through the exact same path a
  /// real Polar HR sample takes (validation, sanitization, buffering,
  /// flush triggers). Production code never calls this: readings only ever
  /// arrive via the real `hrStream` subscription set up in the
  /// constructor, which — unlike `_uploadFn` — has no practical way to be
  /// substituted in a test (it's a real platform EventChannel).
  @visibleForTesting
  void debugInjectReading(HrReading reading) => _onHrReading(reading);

  void setActiveSessionId(String? sessionId) {
    _activeSessionId = sessionId;
    // TEMPORARY DEBUG (Phase 5 upload) — remove once this ships.
    debugPrint('[HrTelemetry] active sessionId set to: $sessionId');
  }

  static const _minValidBpm = 30;
  static const _maxValidBpm = 250;
  // Mirrors the backend's HrSampleItem.rr_interval bounds exactly (see
  // app/modules/heart_rate/schemas/requests.py) — the backend rejects the
  // WHOLE batch (HTTP 422) if any one sample's rr_interval falls outside
  // this range, so validating here, before the sample ever reaches the
  // buffer, is what stops one bad artifact from poisoning every sample
  // queued after it.
  static const _minValidRrMs = 200;
  static const _maxValidRrMs = 3000;

  void _onHrReading(HrReading reading) {
    if (_activeSessionId == null) {
      // TEMPORARY DEBUG (sessionId null-value fix) — remove after diagnosis.
      debugPrint('[HrTelemetry] HR skipped — reason: no active session | '
          '${reading.bpm} bpm');
      return;
    }
    if (reading.bpm < _minValidBpm || reading.bpm > _maxValidBpm) {
      // TEMPORARY DEBUG (sessionId null-value fix) — remove after diagnosis.
      debugPrint('[HrTelemetry] HR skipped — reason: invalid heart rate | '
          '${reading.bpm} bpm (valid range: $_minValidBpm-$_maxValidBpm)');
      return;
    }

    final sanitized = sanitizeRrInterval(reading);

    final wasPendingEmpty = pendingCount == 0;
    _buffer.add(HrTelemetrySample(
      reading: sanitized,
      sessionId: _activeSessionId,
      bufferedAt: DateTime.now(),
    ));

    // TEMPORARY DEBUG (Phase 5 upload) — remove once this ships.
    debugPrint('[HrTelemetry] HR received: ${reading.bpm} bpm | '
        'buffer size: ${_buffer.length} | pending: $pendingCount | '
        'sessionId: $_activeSessionId');

    if (wasPendingEmpty) _startFlushTimer();
    if (pendingCount >= _flushBatchSize) {
      _flush('batch size reached ($_flushBatchSize samples)');
    }
  }

  /// Drops an out-of-range RR interval before it ever reaches the buffer.
  /// The bpm reading itself is untouched and still buffered/uploaded
  /// normally — only the invalid RR value is omitted, never clamped,
  /// rounded, or substituted with a fabricated one.
  @visibleForTesting
  static HrReading sanitizeRrInterval(HrReading reading) {
    if (reading.rrIntervals.isEmpty) return reading;
    final rr = reading.rrIntervals.last;
    if (rr >= _minValidRrMs && rr <= _maxValidRrMs) return reading;
    // TEMPORARY DEBUG (sessionId null-value fix) — remove after diagnosis.
    debugPrint('[HrTelemetry] dropped out-of-range rr_interval=$rr ms '
        '(valid range: $_minValidRrMs-$_maxValidRrMs) — bpm=${reading.bpm} still kept');
    return HrReading(
      bpm: reading.bpm,
      rrIntervals: const [],
      sensorContact: reading.sensorContact,
      timestamp: reading.timestamp,
    );
  }

  // ── Flush timer lifecycle ────────────────────────────────────────────────

  void _startFlushTimer() {
    if (_flushTimer != null) return; // never allow a duplicate timer
    _flushTimer = Timer.periodic(_flushInterval, (_) => _onFlushTimerTick());
    // TEMPORARY DEBUG (Phase 5 upload) — remove once this ships.
    debugPrint('[HrTelemetry] flush timer started '
        '(${_flushInterval.inSeconds}s interval)');
  }

  void _onFlushTimerTick() {
    if (pendingCount == 0) return; // nothing pending; timer stops itself below
    _flush('periodic timer (${_flushInterval.inSeconds}s)');
  }

  void _stopFlushTimerIfIdle() {
    if (pendingCount != 0 || _flushTimer == null) return;
    _flushTimer!.cancel();
    _flushTimer = null;
    // TEMPORARY DEBUG (Phase 5 upload) — remove once this ships.
    debugPrint('[HrTelemetry] flush timer stopped — buffer caught up');
  }

  // ── Flush + upload ───────────────────────────────────────────────────────

  void _flush(String reason) {
    // One upload in flight at a time — the samples that arrive while this
    // one is outstanding simply wait for the next trigger, once it resolves.
    if (_isUploading) return;

    final pending = _buffer.sublist(_flushedUpTo);
    if (pending.isEmpty) return;

    final payload = _buildPayload(pending);

    // TEMPORARY DEBUG (Phase 5 upload) — remove once this ships.
    debugPrint('[HrTelemetry] FLUSH TRIGGERED — reason: $reason | '
        'samples: ${pending.length}');
    debugPrint('[HrTelemetry] payload: ${jsonEncode(payload)}');

    final upload = _uploadBatch(pending, payload);
    _currentUpload = upload;
    unawaited(upload);
  }

  // Bounded retry for the final, session-end flush only — a session-end
  // failure would otherwise only ever be picked up by the next periodic
  // timer tick (if one happens to still be running), or never, since no
  // further HR readings will arrive to (re)start that timer once the
  // session has ended. Fixed delay, not exponential — matches the rest of
  // this class, which has no backoff logic anywhere.
  static const _maxFinalFlushAttempts = 3;
  static const _finalFlushRetryDelay = Duration(seconds: 2);

  /// Awaits any in-flight upload, then sends whatever remains pending —
  /// used at session end so already-buffered samples are sent immediately
  /// rather than waiting for the next periodic tick. Never starts a second
  /// upload while one from [_flush] is already running.
  ///
  /// Retries the final attempt itself up to [_maxFinalFlushAttempts] times
  /// (bounded — never infinite) if the backend request fails. If every
  /// attempt fails, the samples remain pending in [_buffer] — in-memory
  /// only, not persisted to disk — so the existing periodic timer (left
  /// completely untouched by this method) keeps retrying passively for as
  /// long as the app process stays alive; this is recovery *within the
  /// current app lifetime only*, not durable across an app restart.
  Future<void> flushNow() async {
    if (pendingCount == 0) return;

    final inFlight = _currentUpload;
    if (_isUploading && inFlight != null) {
      await inFlight;
    }

    for (var attempt = 1; attempt <= _maxFinalFlushAttempts; attempt++) {
      if (pendingCount == 0) return;

      final pending = _buffer.sublist(_flushedUpTo);
      if (pending.isEmpty) return;

      final payload = _buildPayload(pending);

      // TEMPORARY DEBUG (Phase 5 upload) — remove once this ships.
      debugPrint('[HrTelemetry] FLUSH TRIGGERED — reason: final flush '
          'attempt $attempt/$_maxFinalFlushAttempts (session end) | '
          'samples: ${pending.length}');
      debugPrint('[HrTelemetry] payload: ${jsonEncode(payload)}');

      final upload = _uploadBatch(pending, payload);
      _currentUpload = upload;
      await upload;

      // Either the upload succeeded, or it was permanently rejected and
      // _uploadBatch already advanced past it — both leave nothing pending,
      // and neither needs another attempt.
      if (pendingCount == 0) return;

      if (attempt < _maxFinalFlushAttempts) {
        debugPrint('[HrTelemetry] final flush attempt $attempt failed — '
            'retrying in ${_finalFlushRetryDelay.inSeconds}s');
        await Future<void>.delayed(_finalFlushRetryDelay);
      }
    }

    debugPrint('[HrTelemetry] final flush exhausted $_maxFinalFlushAttempts '
        'attempts — $pendingCount sample(s) remain pending in memory; the '
        'periodic timer will keep retrying passively while the app stays '
        'running (not persisted — lost if the app is killed first)');
  }

  Future<void> _uploadBatch(
    List<HrTelemetrySample> pending,
    Map<String, dynamic> payload,
  ) async {
    _isUploading = true;
    // Captured before the await: _buffer may keep growing while this request
    // is in flight, and only the samples in this specific batch may be
    // marked flushed once it succeeds.
    final flushEndIndex = _flushedUpTo + pending.length;

    try {
      final response = await _uploadFn(payload);
      // TEMPORARY DEBUG (Phase 5 upload) — remove once this ships.
      debugPrint('[HrTelemetry] upload SUCCESS — status: '
          '${response.statusCode} | samples uploaded: ${pending.length}');
      _flushedUpTo = flushEndIndex;
      _trimFlushedBuffer();
      _stopFlushTimerIfIdle();
    } on DioException catch (e) {
      final status = e.response?.statusCode;
      // A 4xx (other than 401, which means the request-level auth
      // interceptor already tried and failed to recover the session, not
      // that this payload specifically is bad) means the server will never
      // accept this exact batch no matter how many times it's resent —
      // retrying it forever is exactly what used to let one bad batch
      // permanently block every sample after it. Advancing past it here
      // (dropping only these already-rejected samples) is what keeps the
      // stream accepting new, valid samples instead of getting stuck.
      final isPermanentlyRejected =
          status != null && status >= 400 && status < 500 && status != 401;
      debugPrint('[HrTelemetry] upload FAILED — status: $status | '
          'samples pending: ${pending.length} | '
          'permanently rejected: $isPermanentlyRejected');
      if (isPermanentlyRejected) {
        _flushedUpTo = flushEndIndex;
        _trimFlushedBuffer();
        _stopFlushTimerIfIdle();
      }
      // Otherwise (network error, timeout, 5xx): _flushedUpTo intentionally
      // left unchanged — transient, worth retrying on the next tick.
    } catch (e) {
      // TEMPORARY DEBUG (Phase 5 upload) — remove once this ships.
      debugPrint('[HrTelemetry] upload FAILED (non-Dio error) — samples '
          'remain pending: ${pending.length} | error: $e');
      // Unknown error shape — treated as transient, matching prior behavior.
    } finally {
      _isUploading = false;
    }
  }

  /// Drops already-uploaded (or permanently-rejected) samples from the
  /// front of [_buffer] so it stays bounded to whatever is still pending,
  /// instead of retaining every sample for the entire session. Safe to call
  /// any time [_flushedUpTo] has advanced — [pendingCount] is unaffected
  /// since both numbers shift by the same amount.
  void _trimFlushedBuffer() {
    if (_flushedUpTo == 0) return;
    _buffer.removeRange(0, _flushedUpTo);
    _flushedUpTo = 0;
  }

  /// Builds the hr_stream upload payload for a batch of samples. Pure
  /// mapping only — no logging, no I/O.
  Map<String, dynamic> _buildPayload(List<HrTelemetrySample> samples) {
    return {
      'samples': samples
          .map((s) => {
                'sessionId': s.sessionId,
                'recordedAt': s.reading.timestamp.toIso8601String(),
                'heartRate': s.reading.bpm,
                'rrInterval': s.reading.rrIntervals.isNotEmpty
                    ? s.reading.rrIntervals.last
                    : null,
              })
          .toList(),
    };
  }

  void dispose() {
    _hrSubscription.cancel();
    _flushTimer?.cancel();
    _flushTimer = null;
  }
}
