import 'package:equatable/equatable.dart';

import '../domain/entities/session_summary_entity.dart';

abstract class SessionSummaryState extends Equatable {
  const SessionSummaryState();

  @override
  List<Object?> get props => [];
}

class SessionSummaryInitial extends SessionSummaryState {
  const SessionSummaryInitial();
}

class SessionSummaryLoading extends SessionSummaryState {
  const SessionSummaryLoading();
}

class SessionSummaryLoaded extends SessionSummaryState {
  const SessionSummaryLoaded({
    required this.data,
    required this.selectedSeriesIndex,
  });

  final SessionSummaryEntity data;
  final int selectedSeriesIndex;

  SessionSummaryLoaded copyWith({int? selectedSeriesIndex}) =>
      SessionSummaryLoaded(
        data: data,
        selectedSeriesIndex: selectedSeriesIndex ?? this.selectedSeriesIndex,
      );

  @override
  List<Object?> get props => [data, selectedSeriesIndex];
}

class SessionSummaryError extends SessionSummaryState {
  const SessionSummaryError(this.message);

  final String message;

  @override
  List<Object?> get props => [message];
}
