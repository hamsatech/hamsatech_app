import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/repositories/athlete_repository.dart';
import 'athlete_event.dart';
import 'athlete_state.dart';

class AthleteBloc extends Bloc<AthleteEvent, AthleteState> {
  AthleteBloc(this._repository) : super(const AthleteInitial()) {
    on<AthleteProfileRequested>(_onProfileRequested);
    on<AthleteCreateRequested>(_onCreateRequested);
  }

  final AthleteRepository _repository;

  Future<void> _onProfileRequested(
    AthleteProfileRequested event,
    Emitter<AthleteState> emit,
  ) async {
    emit(const AthleteLoading());
    try {
      final athlete = await _repository.getAthleteProfile(event.athleteId);
      emit(AthleteLoaded(athlete));
    } catch (e) {
      emit(AthleteError(e.toString()));
    }
  }

  Future<void> _onCreateRequested(
    AthleteCreateRequested event,
    Emitter<AthleteState> emit,
  ) async {
    emit(const AthleteLoading());
    try {
      final athlete = await _repository.createAthlete(
        athleteId: event.athleteId,
        athleteName: event.athleteName,
        age: event.age,
        gender: event.gender,
        sport: event.sport,
      );
      emit(AthleteLoaded(athlete));
    } catch (e) {
      emit(AthleteError(e.toString()));
    }
  }
}
