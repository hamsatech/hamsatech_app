import '../../domain/entities/session_setup_entity.dart';

class SessionSetupModel extends SessionSetupEntity {
  const SessionSetupModel({
    required super.rangeType,
    required super.plannedShots,
    required super.discipline,
    super.sessionType,
  });

  factory SessionSetupModel.fromJson(Map<String, dynamic> json) {
    return SessionSetupModel(
      rangeType: RangeType.values.firstWhere(
        (e) => e.name == json['rangeType'],
        orElse: () => RangeType.paper,
      ),
      sessionType: json['sessionType'] != null
          ? SessionType.values.firstWhere(
              (e) => e.name == json['sessionType'],
            )
          : null,
      plannedShots: (json['plannedShots'] as num?)?.toInt() ?? 60,
      discipline: json['discipline'] as String? ?? '',
    );
  }

  Map<String, dynamic> toJson() => {
        'rangeType': rangeType.name,
        'sessionType': sessionType?.name,
        'plannedShots': plannedShots,
        'discipline': discipline,
      };
}
