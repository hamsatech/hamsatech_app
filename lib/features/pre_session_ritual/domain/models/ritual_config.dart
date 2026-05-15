class RitualConfig {
  const RitualConfig({
    required this.breathingDurationSeconds,
    required this.breathPhaseSeconds,
    required this.bodyScanAreas,
    required this.bodyScanAreaDurationSeconds,
  });

  final int breathingDurationSeconds;
  final int breathPhaseSeconds;
  final List<String> bodyScanAreas;
  final int bodyScanAreaDurationSeconds;
}
