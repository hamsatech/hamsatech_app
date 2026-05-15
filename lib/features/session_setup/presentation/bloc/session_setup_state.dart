import 'package:equatable/equatable.dart';
import '../../domain/entities/session_setup_entity.dart';

abstract class SessionSetupState extends Equatable {
  const SessionSetupState();

  @override
  List<Object?> get props => [];
}

class SessionSetupInitial extends SessionSetupState {
  const SessionSetupInitial();
}

class SessionSetupEditing extends SessionSetupState {
  const SessionSetupEditing({
    this.rangeType = RangeType.paper,
    this.sessionType,
    this.plannedShots = 60,
    this.discipline = '',
    this.disciplines = const [],
    this.isSubmitting = false,
  });

  final RangeType rangeType;
  final SessionType? sessionType;
  final int plannedShots;
  final String discipline;
  final List<String> disciplines;
  final bool isSubmitting;

  static const int minShots = 1;
  static const int maxShots = 300;
  static const List<int> quickSelectValues = [20, 40, 60, 80, 100, 120];

  bool get canBeginRitual =>
      plannedShots >= minShots &&
      plannedShots <= maxShots &&
      discipline.isNotEmpty &&
      !isSubmitting;

  SessionSetupEditing copyWith({
    RangeType? rangeType,
    SessionType? sessionType,
    int? plannedShots,
    String? discipline,
    List<String>? disciplines,
    bool? isSubmitting,
  }) =>
      SessionSetupEditing(
        rangeType: rangeType ?? this.rangeType,
        sessionType: sessionType ?? this.sessionType,
        plannedShots: plannedShots ?? this.plannedShots,
        discipline: discipline ?? this.discipline,
        disciplines: disciplines ?? this.disciplines,
        isSubmitting: isSubmitting ?? this.isSubmitting,
      );

  @override
  List<Object?> get props => [
        rangeType,
        sessionType,
        plannedShots,
        discipline,
        disciplines,
        isSubmitting,
      ];
}

class SessionSetupSuccess extends SessionSetupState {
  const SessionSetupSuccess();
}

class SessionSetupError extends SessionSetupState {
  const SessionSetupError(this.message);

  final String message;

  @override
  List<Object?> get props => [message];
}
