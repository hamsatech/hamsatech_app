import 'package:flutter_bloc/flutter_bloc.dart';

import '../domain/repositories/session_report_repository.dart';
import 'session_report_event.dart';
import 'session_report_state.dart';

class SessionReportBloc extends Bloc<SessionReportEvent, SessionReportState> {
  SessionReportBloc({required SessionReportRepository repository})
      : _repository = repository,
        super(const SessionReportInitial()) {
    on<SessionReportLoadRequested>(_onLoad);
  }

  final SessionReportRepository _repository;

  Future<void> _onLoad(
    SessionReportLoadRequested event,
    Emitter<SessionReportState> emit,
  ) async {
    emit(const SessionReportLoading());
    try {
      final data = await _repository.getReport();
      emit(SessionReportLoaded(data: data));
    } catch (e) {
      emit(SessionReportError(message: e.toString()));
    }
  }
}
