class HrReading {
  final int bpm;
  final List<int> rrIntervals;
  final bool sensorContact;
  final DateTime timestamp;

  const HrReading({
    required this.bpm,
    required this.rrIntervals,
    required this.sensorContact,
    required this.timestamp,
  });

  factory HrReading.fromMap(Map<dynamic, dynamic> map) {
    return HrReading(
      bpm: (map['hr'] as int?) ?? 0,
      rrIntervals: List<int>.from(map['rrs'] ?? []),
      sensorContact: (map['contact'] as bool?) ?? false,
      timestamp: DateTime.now(),
    );
  }

  // RMSSD: root mean square of successive RR differences (HRV metric)
  double get rmssd {
    if (rrIntervals.length < 2) return 0;
    double sumSquared = 0;
    for (int i = 1; i < rrIntervals.length; i++) {
      final diff = rrIntervals[i] - rrIntervals[i - 1];
      sumSquared += diff * diff;
    }
    return sumSquared / (rrIntervals.length - 1);
  }
}
