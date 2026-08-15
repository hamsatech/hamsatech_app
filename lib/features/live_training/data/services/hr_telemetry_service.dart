import 'dart:async';
import 'dart:convert';

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
  })  : _flushBatchSize = flushBatchSize,
        _flushInterval = flushInterval {
    _hrSubscription = _polarBleService.hrStream.listen(_onHrReading);
  }

  final PolarBleService _polarBleService;
  final int _flushBatchSize;
  final Duration _flushInterval;

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

  void setActiveSessionId(String? sessionId) {
    _activeSessionId = sessionId;
    // TEMPORARY DEBUG (Phase 5 upload) — remove once this ships.
    debugPrint('[HrTelemetry] active sessionId set to: $sessionId');
  }

  static const _minValidBpm = 30;
  static const _maxValidBpm = 250;

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

    final wasPendingEmpty = pendingCount == 0;
    _buffer.add(HrTelemetrySample(
      reading: reading,
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

  /// Awaits any in-flight upload, then sends whatever remains pending —
  /// used at session end so already-buffered samples are sent immediately
  /// rather than waiting for the next periodic tick. Never starts a second
  /// upload while one from [_flush] is already running.
  Future<void> flushNow() async {
    if (pendingCount == 0) return;

    final inFlight = _currentUpload;
    if (_isUploading && inFlight != null) {
      await inFlight;
    }

    if (pendingCount == 0) return;

    final pending = _buffer.sublist(_flushedUpTo);
    if (pending.isEmpty) return;

    final payload = _buildPayload(pending);

    // TEMPORARY DEBUG (Phase 5 upload) — remove once this ships.
    debugPrint('[HrTelemetry] FLUSH TRIGGERED — reason: final flush (session end) | '
        'samples: ${pending.length}');
    debugPrint('[HrTelemetry] payload: ${jsonEncode(payload)}');

    final upload = _uploadBatch(pending, payload);
    _currentUpload = upload;
    await upload;
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
      final response = await ApiService.instance.uploadHrSamples(payload);
      // TEMPORARY DEBUG (Phase 5 upload) — remove once this ships.
      debugPrint('[HrTelemetry] upload SUCCESS — status: '
          '${response.statusCode} | samples uploaded: ${pending.length}');
      _flushedUpTo = flushEndIndex;
      _stopFlushTimerIfIdle();
    } catch (e) {
      // TEMPORARY DEBUG (Phase 5 upload) — remove once this ships.
      debugPrint('[HrTelemetry] upload FAILED — samples remain pending: '
          '${pending.length} | error: $e');
      // _flushedUpTo intentionally left unchanged — no retry in this phase.
    } finally {
      _isUploading = false;
    }
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
