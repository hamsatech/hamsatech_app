import 'package:equatable/equatable.dart';
import '../../domain/entities/athlete_entity.dart';

abstract class AthleteState extends Equatable {
  const AthleteState();
  @override
  List<Object?> get props => [];
}

class AthleteInitial extends AthleteState {
  const AthleteInitial();
}

class AthleteLoading extends AthleteState {
  const AthleteLoading();
}

/// Emitted after a successful GET or POST.
class AthleteLoaded extends AthleteState {
  const AthleteLoaded(this.athlete);
  final AthleteEntity athlete;
  @override
  List<Object?> get props => [athlete];
}

class AthleteError extends AthleteState {
  const AthleteError(this.message);
  final String message;
  @override
  List<Object?> get props => [message];
}
