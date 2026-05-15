import 'package:equatable/equatable.dart';

abstract class AthleteEvent extends Equatable {
  const AthleteEvent();
  @override
  List<Object?> get props => [];
}

/// Triggers GET /athletes — fetches the full profile with details + family.
class AthleteProfileRequested extends AthleteEvent {
  const AthleteProfileRequested(this.athleteId);
  final String athleteId;
  @override
  List<Object?> get props => [athleteId];
}

/// Triggers POST /athletes — creates a new athlete record.
class AthleteCreateRequested extends AthleteEvent {
  const AthleteCreateRequested({
    required this.athleteId,
    required this.athleteName,
    required this.age,
    required this.gender,
    required this.sport,
  });

  final String athleteId;
  final String athleteName;
  final int age;
  final String gender;
  final String sport;

  @override
  List<Object?> get props => [athleteId, athleteName, age, gender, sport];
}
