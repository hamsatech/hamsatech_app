import 'package:equatable/equatable.dart';
import '../../domain/entities/session_setup_entity.dart';

abstract class SessionSetupEvent extends Equatable {
  const SessionSetupEvent();

  @override
  List<Object?> get props => [];
}

class SessionSetupLoadRequested extends SessionSetupEvent {
  const SessionSetupLoadRequested();
}

class SessionSetupRangeTypeChanged extends SessionSetupEvent {
  const SessionSetupRangeTypeChanged(this.rangeType);

  final RangeType rangeType;

  @override
  List<Object?> get props => [rangeType];
}

class SessionSetupSessionTypeChanged extends SessionSetupEvent {
  const SessionSetupSessionTypeChanged(this.sessionType);

  final SessionType sessionType;

  @override
  List<Object?> get props => [sessionType];
}

class SessionSetupShotsChanged extends SessionSetupEvent {
  const SessionSetupShotsChanged(this.shots);

  final int shots;

  @override
  List<Object?> get props => [shots];
}

class SessionSetupDisciplineChanged extends SessionSetupEvent {
  const SessionSetupDisciplineChanged(this.discipline);

  final String discipline;

  @override
  List<Object?> get props => [discipline];
}

class SessionSetupBeginRitualRequested extends SessionSetupEvent {
  const SessionSetupBeginRitualRequested();
}
