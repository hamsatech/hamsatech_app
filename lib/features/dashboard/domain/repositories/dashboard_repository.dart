import '../entities/dashboard_data_entity.dart';

abstract class DashboardRepository {
  Future<DashboardDataEntity> getDashboardData();
}
