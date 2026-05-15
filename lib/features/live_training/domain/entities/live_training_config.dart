class LiveTrainingConfig {
  const LiveTrainingConfig({
    required this.sessionTitle,
    required this.plannedShots,
    required this.shotsPerSeries,
    required this.baselineHr,
  });

  final String sessionTitle;
  final int plannedShots;
  final int shotsPerSeries;
  final int baselineHr;
}
