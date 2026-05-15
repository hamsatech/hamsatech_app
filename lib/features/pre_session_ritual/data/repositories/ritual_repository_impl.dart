import '../../../../core/services/storage_service.dart';
import '../../domain/models/ritual_config.dart';
import '../../domain/models/ritual_result.dart';
import '../../domain/repositories/ritual_repository.dart';

class RitualRepositoryImpl implements RitualRepository {
  static const _bodyScanAreas = [
    'Feet and ankles',
    'Calves and shins',
    'Knees',
    'Thighs and hips',
    'Core and abdomen',
    'Lower back',
    'Chest',
    'Shoulders',
    'Arms and hands',
    'Neck and jaw',
  ];

  @override
  RitualConfig getConfig() => const RitualConfig(
        breathingDurationSeconds: 48,
        breathPhaseSeconds: 4,
        bodyScanAreas: _bodyScanAreas,
        bodyScanAreaDurationSeconds: 15,
      );

  @override
  Future<void> saveResult(RitualResult result) async =>
      StorageService.saveRitualResult(result.toJson());
}
