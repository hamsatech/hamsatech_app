import 'package:equatable/equatable.dart';

abstract class AlexSummaryEvent extends Equatable {
  const AlexSummaryEvent();

  @override
  List<Object?> get props => [];
}

class AlexSummaryLoadRequested extends AlexSummaryEvent {
  const AlexSummaryLoadRequested();
}
