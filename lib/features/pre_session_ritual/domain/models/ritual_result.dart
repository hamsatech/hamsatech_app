class RitualResult {
  const RitualResult({
    required this.intention,
    required this.visualization,
    required this.completedAt,
  });

  final String intention;
  final String visualization;
  final DateTime completedAt;

  Map<String, dynamic> toJson() => {
        'intention': intention,
        'visualization': visualization,
        'completedAt': completedAt.toIso8601String(),
      };
}
