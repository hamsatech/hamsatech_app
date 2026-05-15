import 'package:equatable/equatable.dart';

abstract class SessionReportEvent extends Equatable {
  const SessionReportEvent();
  @override
  List<Object?> get props => [];
}

class SessionReportLoadRequested extends SessionReportEvent {
  const SessionReportLoadRequested();
}
