import '../entities/session_report_entity.dart';

abstract interface class SessionReportRepository {
  Future<SessionReportEntity> getReport();
}
