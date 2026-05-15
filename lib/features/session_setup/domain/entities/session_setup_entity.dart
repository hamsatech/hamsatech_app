import 'package:equatable/equatable.dart';

enum RangeType {
  paper,
  electronic;

  String get label => switch (this) {
        RangeType.paper => 'Paper',
        RangeType.electronic => 'Electronic',
      };
}

enum SessionType {
  scoring,
  grouping,
  dryFire;

  String get label => switch (this) {
        SessionType.scoring => 'Scoring',
        SessionType.grouping => 'Grouping',
        SessionType.dryFire => 'Dry Fire',
      };
}

class SessionSetupEntity extends Equatable {
  const SessionSetupEntity({
    required this.rangeType,
    required this.plannedShots,
    required this.discipline,
    this.sessionType,
  });

  final RangeType rangeType;
  final SessionType? sessionType;
  final int plannedShots;
  final String discipline;

  bool get isValid => plannedShots > 0 && discipline.isNotEmpty;

  SessionSetupEntity copyWith({
    RangeType? rangeType,
    SessionType? sessionType,
    int? plannedShots,
    String? discipline,
  }) =>
      SessionSetupEntity(
        rangeType: rangeType ?? this.rangeType,
        sessionType: sessionType ?? this.sessionType,
        plannedShots: plannedShots ?? this.plannedShots,
        discipline: discipline ?? this.discipline,
      );

  @override
  List<Object?> get props => [rangeType, sessionType, plannedShots, discipline];
}
