import 'package:equatable/equatable.dart';

import '../../domain/entities/alex_summary_entity.dart';

enum AlexSummaryStatus { initial, loading, loaded, error }

class AlexSummaryState extends Equatable {
  const AlexSummaryState({
    this.status = AlexSummaryStatus.initial,
    this.summary,
    this.errorMessage,
  });

  final AlexSummaryStatus status;
  final AlexSummaryEntity? summary;
  final String? errorMessage;

  AlexSummaryState copyWith({
    AlexSummaryStatus? status,
    AlexSummaryEntity? summary,
    String? errorMessage,
  }) {
    return AlexSummaryState(
      status: status ?? this.status,
      summary: summary ?? this.summary,
      errorMessage: errorMessage,
    );
  }

  @override
  List<Object?> get props => [
        status,
        summary,
        errorMessage,
      ];
}
