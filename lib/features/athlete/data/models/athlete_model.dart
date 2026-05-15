import '../../domain/entities/athlete_entity.dart';

/// Data-layer representation of an athlete row.
///
/// Extends [AthleteEntity] so it can be passed directly to the BLoC
/// without mapping — same pattern used across the codebase.
class AthleteModel extends AthleteEntity {
  const AthleteModel({
    required super.athleteId,
    required super.athleteName,
    required super.age,
    required super.gender,
    required super.sport,
    super.details,
    super.family,
  });

  /// Parses the Supabase response row.
  ///
  /// Supabase embedded relations (`athlete_details(*)`) return either a
  /// single object `{}` or `null` — never an array — for one-to-one joins.
  factory AthleteModel.fromJson(Map<String, dynamic> json) {
    return AthleteModel(
      athleteId: json['athlete_id'] as String,
      athleteName: json['athlete_name'] as String,
      age: (json['age'] as num).toInt(),
      gender: json['gender'] as String,
      sport: json['sport'] as String,
      details: json['athlete_details'] as Map<String, dynamic>?,
      family: json['athlete_family'] as Map<String, dynamic>?,
    );
  }

  /// Serialises to the POST body for `createAthlete`.
  /// Excludes relation fields — those live in separate tables.
  Map<String, dynamic> toJson() => {
        'athlete_id': athleteId,
        'athlete_name': athleteName,
        'age': age,
        'gender': gender,
        'sport': sport,
      };

  /// Convenience constructor used when the entity is built locally
  /// (e.g. before the server round-trip in optimistic updates).
  factory AthleteModel.fromEntity(AthleteEntity e) => AthleteModel(
        athleteId: e.athleteId,
        athleteName: e.athleteName,
        age: e.age,
        gender: e.gender,
        sport: e.sport,
        details: e.details,
        family: e.family,
      );
}
