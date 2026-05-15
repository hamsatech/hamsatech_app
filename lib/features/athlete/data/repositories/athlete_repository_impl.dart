import '../../domain/entities/athlete_entity.dart';
import '../../domain/repositories/athlete_repository.dart';
import '../datasources/athlete_remote_datasource.dart';
import '../models/athlete_model.dart';

/// Bridges the domain contract and the HTTP datasource.
///
/// This layer is the right place to add:
///   - Local cache reads before hitting the network
///   - Retry logic
///   - Mapping between multiple datasources (remote + local)
class AthleteRepositoryImpl implements AthleteRepository {
  AthleteRepositoryImpl(this._datasource);

  final AthleteRemoteDatasource _datasource;

  @override
  Future<AthleteEntity> getAthleteProfile(String athleteId) {
    return _datasource.getAthleteProfile(athleteId);
  }

  @override
  Future<AthleteEntity> createAthlete({
    required String athleteId,
    required String athleteName,
    required int age,
    required String gender,
    required String sport,
  }) {
    final body = AthleteModel(
      athleteId: athleteId,
      athleteName: athleteName,
      age: age,
      gender: gender,
      sport: sport,
    ).toJson();

    return _datasource.createAthlete(body);
  }
}
