import 'package:equatable/equatable.dart';

class AlexSummaryEntity extends Equatable {
  const AlexSummaryEntity({
    required this.discipline,
    required this.goal,
    required this.restingHr,
    required this.coachStatus,
  });

  final String discipline;
  final String goal;
  final String restingHr;
  final String coachStatus;

  @override
  List<Object> get props => [
        discipline,
        goal,
        restingHr,
        coachStatus,
      ];
}
