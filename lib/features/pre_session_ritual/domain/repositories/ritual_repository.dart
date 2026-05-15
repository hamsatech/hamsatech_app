import '../models/ritual_config.dart';
import '../models/ritual_result.dart';

abstract class RitualRepository {
  RitualConfig getConfig();
  Future<void> saveResult(RitualResult result);
}
