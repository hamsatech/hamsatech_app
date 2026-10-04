import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/repositories/dashboard_repository.dart';
import 'dashboard_event.dart';
import 'dashboard_state.dart';

class DashboardBloc extends Bloc<DashboardEvent, DashboardState> {
  DashboardBloc(this._repository) : super(const DashboardInitial()) {
    on<DashboardLoadRequested>(_onLoad);
    on<DashboardRefreshRequested>(_onRefresh);
    on<DashboardCoachFeedbackMarkRead>(_onMarkFeedbackRead);
  }

  final DashboardRepository _repository;

  Future<void> _onLoad(
    DashboardLoadRequested event,
    Emitter<DashboardState> emit,
  ) async {
    emit(const DashboardLoading());
    try {
      final data = await _repository.getDashboardData();
      emit(DashboardLoaded(data));
    } catch (e) {
      // Never surface a raw exception string — DashboardRepositoryImpl
      // already treats every individual backend call as non-fatal
      // (fetch failures fall back to empty/null fields), so reaching this
      // catch means something more fundamental broke (e.g. local storage).
      emit(const DashboardError(
        'Unable to load your dashboard right now. Please try again.',
      ));
    }
  }

  Future<void> _onRefresh(
    DashboardRefreshRequested event,
    Emitter<DashboardState> emit,
  ) async {
    try {
      final data = await _repository.getDashboardData();
      emit(DashboardLoaded(data));
    } catch (e) {
      emit(const DashboardError(
        'Unable to refresh your dashboard right now. Please try again.',
      ));
    }
  }

  void _onMarkFeedbackRead(
    DashboardCoachFeedbackMarkRead event,
    Emitter<DashboardState> emit,
  ) {
    final current = state;
    if (current is DashboardLoaded && current.data.coachFeedback != null) {
      emit(DashboardLoaded(
        current.data.copyWith(
          coachFeedback: current.data.coachFeedback!.copyWith(isRead: true),
        ),
      ));
    }
  }
}
