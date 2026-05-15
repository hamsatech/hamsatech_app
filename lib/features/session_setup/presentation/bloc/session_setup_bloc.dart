import 'package:flutter_bloc/flutter_bloc.dart';
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
}
