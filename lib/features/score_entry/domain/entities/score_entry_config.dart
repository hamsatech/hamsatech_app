class ScoreEntryConfig {
  const ScoreEntryConfig({
    required this.sessionTitle,
    required this.totalSeries,
    required this.shotsPerSeries,
  });

  final String sessionTitle;
  final int totalSeries;
  final int shotsPerSeries;
}
