import 'package:equatable/equatable.dart';

class PerformanceFactorModel extends Equatable {
  final String id;
  final String label;

  const PerformanceFactorModel({
    required this.id,
    required this.label,
  });

  @override
  List<Object?> get props => [id, label];
}
