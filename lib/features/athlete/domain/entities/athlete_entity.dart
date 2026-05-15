import 'package:equatable/equatable.dart';

/// Mirrors the `athletes` table joined with `athlete_details` and
/// `athlete_family` (Supabase embedded relation select).
///
/// Fields in [details] / [family] are kept as dynamic maps because their
/// exact schema may evolve. Add typed sub-entities once the DB schema is
/// confirmed.
class AthleteEntity extends Equatable {
  const AthleteEntity({
    required this.athleteId,
    required this.athleteName,
    required this.age,
    required this.gender,
    required this.sport,
    this.details,
    this.family,
  });

  final String athleteId;
  final String athleteName;
  final int age;
  final String gender;
  final String sport;

  /// Corresponds to `athlete_details(*)` in the Supabase select.
  final Map<String, dynamic>? details;

  /// Corresponds to `athlete_family(*)` in the Supabase select.
  final Map<String, dynamic>? family;

  @override
  List<Object?> get props =>
      [athleteId, athleteName, age, gender, sport, details, family];
}
