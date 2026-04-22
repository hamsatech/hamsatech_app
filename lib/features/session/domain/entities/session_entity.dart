import 'package:equatable/equatable.dart';

class SessionEntity extends Equatable {
  const SessionEntity({
    required this.id,
    required this.date,
    required this.preSession,
    this.postSession,
    this.durationMinutes,
    this.status = SessionStatus.notStarted,
  });

  final String id;
  final DateTime date;
  final PreSessionData preSession;
  final PostSessionData? postSession;
  final int? durationMinutes;
  final SessionStatus status;

  SessionEntity copyWith({
    PostSessionData? postSession,
    int? durationMinutes,
    SessionStatus? status,
  }) =>
      SessionEntity(
        id: id,
        date: date,
        preSession: preSession,
        postSession: postSession ?? this.postSession,
        durationMinutes: durationMinutes ?? this.durationMinutes,
        status: status ?? this.status,
      );

  @override
  List<Object?> get props =>
      [id, date, preSession, postSession, durationMinutes, status];
}

class PreSessionData extends Equatable {
  const PreSessionData({
    required this.energy,
    required this.focus,
    required this.stress,
    required this.confidence,
  });

  final int energy;     // 1–10
  final int focus;      // 1–10
  final int stress;     // 1–10
  final int confidence; // 1–10

  @override
  List<Object?> get props => [energy, focus, stress, confidence];
}

class PostSessionData extends Equatable {
  const PostSessionData({
    required this.overallRating,
    required this.wentWell,
    required this.wentWrong,
    required this.mentalNotes,
  });

  final int overallRating; // 1–5
  final String wentWell;
  final String wentWrong;
  final String mentalNotes;

  @override
  List<Object?> get props =>
      [overallRating, wentWell, wentWrong, mentalNotes];
}

enum SessionStatus { notStarted, active, completed }
