import 'package:equatable/equatable.dart';

import '../domain/entities/session_report_entity.dart';

abstract class SessionReportState extends Equatable {
  const SessionReportState();
  @override
  List<Object?> get props => [];
}

class SessionReportInitial extends SessionReportState {
  const SessionReportInitial();
}

class SessionReportLoading extends SessionReportState {
  const SessionReportLoading();
}

class SessionReportLoaded extends SessionReportState {
  const SessionReportLoaded({required this.data});

  final SessionReportEntity data;

  @override
  List<Object?> get props => [data];
}

class SessionReportError extends SessionReportState {
  const SessionReportError({required this.message});

  final String message;

  @override
  List<Object?> get props => [message];
}
