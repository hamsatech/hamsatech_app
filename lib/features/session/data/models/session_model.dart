import '../../domain/entities/session_entity.dart';

class SessionModel extends SessionEntity {
  const SessionModel({
    required super.id,
    required super.date,
    required super.preSession,
    super.postSession,
    super.durationMinutes,
    super.status,
  });

  factory SessionModel.fromJson(Map<String, dynamic> json) {
    final preJson = json['preSession'] as Map<String, dynamic>;
    final postJson = json['postSession'] as Map<String, dynamic>?;

    return SessionModel(
      id: json['id'] as String,
      date: DateTime.parse(json['date'] as String),
      durationMinutes: (json['durationMinutes'] as num?)?.toInt(),
      status: SessionStatus.values.firstWhere(
        (e) => e.name == json['status'],
        orElse: () => SessionStatus.notStarted,
      ),
      preSession: PreSessionData(
        energy: (preJson['energy'] as num).toInt(),
        focus: (preJson['focus'] as num).toInt(),
        stress: (preJson['stress'] as num).toInt(),
        confidence: (preJson['confidence'] as num).toInt(),
      ),
      postSession: postJson == null
          ? null
          : PostSessionData(
              overallRating: (postJson['overallRating'] as num).toInt(),
              wentWell: postJson['wentWell'] as String,
              wentWrong: postJson['wentWrong'] as String,
              mentalNotes: postJson['mentalNotes'] as String,
            ),
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'date': date.toIso8601String(),
        'durationMinutes': durationMinutes,
        'status': status.name,
        'preSession': {
          'energy': preSession.energy,
          'focus': preSession.focus,
          'stress': preSession.stress,
          'confidence': preSession.confidence,
        },
        'postSession': postSession == null
            ? null
            : {
                'overallRating': postSession!.overallRating,
                'wentWell': postSession!.wentWell,
                'wentWrong': postSession!.wentWrong,
                'mentalNotes': postSession!.mentalNotes,
              },
      };
}
