import '../../../../core/services/storage_service.dart';
import '../../domain/entities/session_setup_entity.dart';
import '../../domain/repositories/session_setup_repository.dart';
import '../models/session_setup_model.dart';

class SessionSetupRepositoryImpl implements SessionSetupRepository {
  // Discipline list is defined here and can be swapped for an API call.
  static const _disciplines = [
    'Air Pistol',
    'Air Rifle',
    '25m Pistol',
    '50m Pistol',
    '50m Rifle 3×40',
    '50m Rifle Prone',
    '10m Running Target',
    'Trap',
    'Skeet',
    'Double Trap',
  ];

  @override
  List<String> getDisciplines() => List.unmodifiable(_disciplines);

  @override
  SessionSetupEntity? getLastSetup() {
    final json = StorageService.getSessionSetup();
    if (json == null) return null;
    try {
      return SessionSetupModel.fromJson(json);
    } catch (_) {
      return null;
    }
  }

  @override
  Future<void> saveSetup(SessionSetupEntity setup) async {
    final model = SessionSetupModel(
      rangeType: setup.rangeType,
      sessionType: setup.sessionType,
      plannedShots: setup.plannedShots,
      discipline: setup.discipline,
    );
    await StorageService.saveSessionSetup(model.toJson());
  }
}
