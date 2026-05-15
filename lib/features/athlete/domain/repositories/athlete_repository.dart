import '../entities/athlete_entity.dart';

/// Contract that the BLoC depends on.
/// The data layer implements this; tests can mock it.
abstract class AthleteRepository {
  /// `GET /rest/v1/athletes?athlete_id=eq.<id>&select=*,athlete_details(*),athlete_family(*)`
  Future<AthleteEntity> getAthleteProfile(String athleteId);

  /// POST /rest/v1/athletes
  Future<AthleteEntity> createAthlete({
    required String athleteId,
    required String athleteName,
    required int age,
    required String gender,
    required String sport,
  });
}
