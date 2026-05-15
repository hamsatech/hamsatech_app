import '../entities/session_setup_entity.dart';

abstract class SessionSetupRepository {
  Future<void> saveSetup(SessionSetupEntity setup);
  SessionSetupEntity? getLastSetup();
  List<String> getDisciplines();
}
