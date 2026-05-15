import 'package:equatable/equatable.dart';

abstract class SessionSummaryEvent extends Equatable {
  const SessionSummaryEvent();

  @override
  List<Object?> get props => [];
}

class SessionSummaryLoadRequested extends SessionSummaryEvent {
  const SessionSummaryLoadRequested();
}

class SessionSummarySeriesSelected extends SessionSummaryEvent {
  const SessionSummarySeriesSelected(this.seriesIndex);

  final int seriesIndex;

  @override
  List<Object?> get props => [seriesIndex];
}
