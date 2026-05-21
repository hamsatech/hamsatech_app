import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/services/api_service.dart';
import '../../../../core/services/auth_helper.dart';
import '../../../../core/services/session_memory.dart';
import '../../../../core/services/storage_service.dart';
import '../../domain/entities/session_setup_entity.dart';
import '../../domain/repositories/session_setup_repository.dart';
import 'session_setup_event.dart';
import 'session_setup_state.dart';

class SessionSetupBloc extends Bloc<SessionSetupEvent, SessionSetupState> {
  SessionSetupBloc(this._repository) : super(const SessionSetupInitial()) {
    on<SessionSetupLoadRequested>(_onLoad);
    on<SessionSetupRangeTypeChanged>(_onRangeTypeChanged);
    on<SessionSetupSessionTypeChanged>(_onSessionTypeChanged);
    on<SessionSetupShotsChanged>(_onShotsChanged);
    on<SessionSetupDisciplineChanged>(_onDisciplineChanged);
    on<SessionSetupBeginRitualRequested>(_onBeginRitual);
  }

  final SessionSetupRepository _repository;

  void _onLoad(
    SessionSetupLoadRequested event,
    Emitter<SessionSetupState> emit,
  ) {
    final disciplines = _repository.getDisciplines();
    final lastSetup = _repository.getLastSetup();

    if (lastSetup != null) {
      emit(SessionSetupEditing(
        rangeType: lastSetup.rangeType,
        sessionType: lastSetup.sessionType,
        plannedShots: lastSetup.plannedShots,
        discipline: lastSetup.discipline,
        disciplines: disciplines,
      ));
    } else {
      emit(SessionSetupEditing(
        disciplines: disciplines,
        discipline: disciplines.isNotEmpty ? disciplines.first : '',
      ));
    }
  }

  void _onRangeTypeChanged(
    SessionSetupRangeTypeChanged event,
    Emitter<SessionSetupState> emit,
  ) {
    if (state is SessionSetupEditing) {
      emit((state as SessionSetupEditing).copyWith(rangeType: event.rangeType));
    }
  }

  void _onSessionTypeChanged(
    SessionSetupSessionTypeChanged event,
    Emitter<SessionSetupState> emit,
  ) {
    if (state is SessionSetupEditing) {
      emit(
        (state as SessionSetupEditing).copyWith(sessionType: event.sessionType),
      );
    }
  }

  void _onShotsChanged(
    SessionSetupShotsChanged event,
    Emitter<SessionSetupState> emit,
  ) {
    if (state is! SessionSetupEditing) return;
    final clamped = event.shots
        .clamp(SessionSetupEditing.minShots, SessionSetupEditing.maxShots);
    emit((state as SessionSetupEditing).copyWith(plannedShots: clamped));
  }

  void _onDisciplineChanged(
    SessionSetupDisciplineChanged event,
    Emitter<SessionSetupState> emit,
  ) {
    if (state is SessionSetupEditing) {
      emit(
        (state as SessionSetupEditing).copyWith(discipline: event.discipline),
      );
    }
  }

  Future<void> _onBeginRitual(
    SessionSetupBeginRitualRequested event,
    Emitter<SessionSetupState> emit,
  ) async {
    if (state is! SessionSetupEditing) return;
    final editing = state as SessionSetupEditing;
    if (!editing.canBeginRitual) return;

    emit(editing.copyWith(isSubmitting: true));
    try {
      // ── Step 1: create session row ─────────────────────────────────────────
      String? sessionId;
      final athleteId = AuthHelper.getCurrentAthleteId();
      if (athleteId != null) {
        try {
          debugPrint('[SESSION] calling createSession athleteId=$athleteId');
          final response = await ApiService.instance.createSession(
            athleteId: athleteId,
            sessionType: _toApiSessionType(editing.sessionType),
          );
          debugPrint('[SESSION CREATED]');
          debugPrint('[SESSION RESPONSE] ${response.data}');
          sessionId = _extractSessionId(response.data);
          SessionMemory.sessionId = sessionId;
          if (sessionId != null) {
            await StorageService.saveSessionId(sessionId);
            debugPrint('[SESSION] session_id persisted to StorageService: $sessionId');
          }
          debugPrint('[SESSION ID] $sessionId');
        } catch (apiError) {
          _logApiError('SESSION CREATE', apiError);
          // API failure does not block the local flow.
        }
      } else {
        debugPrint('[SESSION] skipped — no athlete_id (onboarding incomplete)');
      }

      // ── Step 2: pre-log (must not block session setup on failure) ──────────
      if (sessionId != null) {
        try {
          final preLogBody = {
            'session_id': sessionId,
            'training_plan': _toApiSessionType(editing.sessionType),
            'equipment_status': 'ready',
            'energy_level': 5,
            'readiness_score': 5,
            'mental_state': 'neutral',
            'feeling_rating': 'moderate',
            'mental_tags': <String>[],
          };
          debugPrint('[PRE LOG FLOW ENTERED]');
          debugPrint('[PRE LOG CALL START]');
          debugPrint('[PRE LOG BODY] $preLogBody');

          final preRes = await ApiService.instance.savePreSessionLog(
            sessionId: sessionId,
            energyLevel: 5,
            readinessScore: 5,
            mentalState: 'neutral',
            feelingRating: 'moderate',
          );
          debugPrint('[PRE LOG RESPONSE] status=${preRes.statusCode} data=${preRes.data}');
        } catch (preLogError) {
          _logApiError('PRE LOG', preLogError);
        }
      } else {
        debugPrint('[PRE LOG] skipped — sessionId is null');
      }

      // ── Step 3: save setup locally and navigate ────────────────────────────
      await _repository.saveSetup(SessionSetupEntity(
        rangeType: editing.rangeType,
        sessionType: editing.sessionType,
        plannedShots: editing.plannedShots,
        discipline: editing.discipline,
      ));
      emit(const SessionSetupSuccess());
    } catch (e) {
      emit(SessionSetupError(e.toString()));
    }
  }

  // ── helpers ────────────────────────────────────────────────────────────────

  String _toApiSessionType(SessionType? type) => switch (type) {
        SessionType.scoring => 'scoring',
        SessionType.grouping => 'grouping',
        SessionType.dryFire => 'dry_fire',
        null => 'training',
      };

  String? _extractSessionId(dynamic data) {
    if (data is List && data.isNotEmpty) {
      final row = data.first;
      if (row is Map) return (row['session_id'] ?? row['id'])?.toString();
    }
    if (data is Map) return (data['session_id'] ?? data['id'])?.toString();
    return null;
  }

  void _logApiError(String tag, Object e) {
    if (e is DioException) {
      debugPrint('[$tag ERROR] DioException type=${e.type.name}');
      debugPrint('[$tag ERROR] status=${e.response?.statusCode}');
      debugPrint('[$tag ERROR] body=${e.response?.data}');
      debugPrint('[$tag ERROR] message=${e.message}');
    } else {
      debugPrint('[$tag ERROR] $e');
    }
  }
}
