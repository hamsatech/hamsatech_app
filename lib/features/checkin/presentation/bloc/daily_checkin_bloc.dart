import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/entities/daily_checkin_entity.dart';
import '../../domain/repositories/daily_checkin_repository.dart';
import 'daily_checkin_event.dart';
import 'daily_checkin_state.dart';

class DailyCheckinBloc extends Bloc<DailyCheckinEvent, DailyCheckinState> {
  DailyCheckinBloc(this._repository) : super(const DailyCheckinInitial()) {
    on<DailyCheckinLoadRequested>(_onLoad);
    on<DailyCheckinMoodChanged>(_onMoodChanged);
    on<DailyCheckinEnergyChanged>(_onEnergyChanged);
    on<DailyCheckinSleepChanged>(_onSleepChanged);
    on<DailyCheckinEmotionToggled>(_onEmotionToggled);
    on<DailyCheckinSubmitRequested>(_onSubmit);
  }

  final DailyCheckinRepository _repository;

  void _onLoad(
    DailyCheckinLoadRequested event,
    Emitter<DailyCheckinState> emit,
  ) {
    final existing = _repository.getTodayCheckin();
    final estimate = _repository.getPolarSleepEstimate();
    if (existing != null) {
      emit(DailyCheckinEditing(
        mood: existing.mood,
        energy: existing.energy,
        sleep: existing.sleep,
        emotions: existing.emotions,
        polarSleepEstimate: estimate,
      ));
    } else {
      emit(DailyCheckinEditing(polarSleepEstimate: estimate));
    }
  }

  void _onMoodChanged(
    DailyCheckinMoodChanged event,
    Emitter<DailyCheckinState> emit,
  ) {
    if (state is DailyCheckinEditing) {
      emit((state as DailyCheckinEditing).copyWith(mood: event.mood));
    }
  }

  void _onEnergyChanged(
    DailyCheckinEnergyChanged event,
    Emitter<DailyCheckinState> emit,
  ) {
    if (state is DailyCheckinEditing) {
      emit((state as DailyCheckinEditing).copyWith(energy: event.energy));
    }
  }

  void _onSleepChanged(
    DailyCheckinSleepChanged event,
    Emitter<DailyCheckinState> emit,
  ) {
    if (state is DailyCheckinEditing) {
      emit((state as DailyCheckinEditing).copyWith(sleep: event.sleep));
    }
  }

  void _onEmotionToggled(
    DailyCheckinEmotionToggled event,
    Emitter<DailyCheckinState> emit,
  ) {
    if (state is! DailyCheckinEditing) return;
    final editing = state as DailyCheckinEditing;
    final updated = List<EmotionTag>.from(editing.emotions);
    if (updated.contains(event.emotion)) {
      updated.remove(event.emotion);
    } else {
      updated.add(event.emotion);
    }
    emit(editing.copyWith(emotions: updated));
  }

  Future<void> _onSubmit(
    DailyCheckinSubmitRequested event,
    Emitter<DailyCheckinState> emit,
  ) async {
    if (state is! DailyCheckinEditing) return;
    final editing = state as DailyCheckinEditing;
    if (!editing.canSubmit) return;

    emit(editing.copyWith(isSubmitting: true));
    try {
      final checkin = DailyCheckinEntity(
        id: DateTime.now().toIso8601String(),
        date: DateTime.now(),
        mood: editing.mood!,
        energy: editing.energy,
        sleep: editing.sleep!,
        emotions: List.unmodifiable(editing.emotions),
      );
      await _repository.saveCheckin(checkin);
      emit(const DailyCheckinSuccess());
    } catch (e) {
      emit(DailyCheckinError(e.toString()));
    }
  }
}
