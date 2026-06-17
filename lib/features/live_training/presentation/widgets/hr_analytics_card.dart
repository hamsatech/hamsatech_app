import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/services/storage_service.dart';
import '../../../../features/polar/presentation/bloc/polar_bloc.dart';
import '../../../../features/polar/presentation/bloc/polar_state.dart';

class HrAnalyticsCard extends StatelessWidget {
  const HrAnalyticsCard({
    required this.baselineHr,
    // Simulated fallback data from LiveTrainingBloc — used when no Polar device
    // is connected so the card always shows live-updating values.
    this.simulatedHr,
    this.simulatedHrHistory = const [],
    super.key,
  });

  final int baselineHr;
  final int? simulatedHr;
  final List<int> simulatedHrHistory;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<PolarBloc, PolarState>(
      builder: (context, polarState) {
        // When user explicitly skipped Polar and no device is active, show
        // the "not connected" placeholder rather than simulated data.
        final polarSkipped = !StorageService.isPolarEnabled();
        if (polarSkipped && !polarState.isConnected) {
          return Container(
            margin: const EdgeInsets.symmetric(horizontal: 16),
            padding: const EdgeInsets.fromLTRB(16, 20, 16, 20),
            decoration: BoxDecoration(
              color: const Color(0xFFEAF7FA),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: const Color(0xFFCAE8EE),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.favorite_border_rounded,
                    color: Color(0xFF2F7E8F),
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                const Expanded(
                  child: Text(
                    'Polar not connected yet',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: Color(0xFF2F7E8F),
                    ),
                  ),
                ),
              ],
            ),
          );
        }

        // Prefer real Polar data; fall back to bloc-driven simulation.
        final polarHr = polarState.latestReading?.bpm;
        final currentHr = polarHr ?? simulatedHr;

        final List<int> bpmHistory;
        if (polarState.hrHistory.isNotEmpty) {
          final src = polarState.hrHistory;
          final slice = src.length > 30 ? src.sublist(src.length - 30) : src;
          bpmHistory = slice.map((r) => r.bpm).toList();
        } else {
          bpmHistory = simulatedHrHistory;
        }

        final delta = currentHr != null ? currentHr - baselineHr : null;

        return Container(
          margin: const EdgeInsets.symmetric(horizontal: 16),
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 14),
          decoration: BoxDecoration(
            color: const Color(0xFFEAF7FA),
            borderRadius: BorderRadius.circular(14),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── BPM row ─────────────────────────────────────────────
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const Padding(
                    padding: EdgeInsets.only(top: 2),
                    child: Icon(
                      Icons.favorite_rounded,
                      color: Color(0xFFEF4444),
                      size: 18,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _BpmDisplay(value: currentHr),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            Text(
                              'Baseline $baselineHr',
                              style: const TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w400,
                                color: const Color(0x99000F12),
                              ),
                            ),
                            if (delta != null) ...[
                              const SizedBox(width: 6),
                              _DeltaChip(delta: delta),
                            ],
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              // ── Bar chart ────────────────────────────────────────────
              _HrBarChart(bpmValues: bpmHistory),
              const SizedBox(height: 6),
              const Text(
                'HR Last 30 Readings',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w400,
                  color: const Color(0x66000F12),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

// ─── BPM number + unit ────────────────────────────────────────────────────────

class _BpmDisplay extends StatelessWidget {
  const _BpmDisplay({this.value});

  final int? value;

  @override
  Widget build(BuildContext context) {
    final hasData = value != null;
    final numColor =
        hasData ? const Color(0xFF0A1C20) : const Color(0xFFB0D8E0);
    final unitColor =
        hasData ? const Color(0xFF2A5562) : const Color(0xFFB0D8E0);

    return Row(
      crossAxisAlignment: CrossAxisAlignment.baseline,
      textBaseline: TextBaseline.alphabetic,
      children: [
        Text(
          hasData ? '$value' : '--',
          style: TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.w700,
            color: numColor,
            height: 1.1,
          ),
        ),
        const SizedBox(width: 4),
        Text(
          'bpm',
          style: TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w500,
            color: unitColor,
          ),
        ),
      ],
    );
  }
}

// ─── Delta chip ───────────────────────────────────────────────────────────────

class _DeltaChip extends StatelessWidget {
  const _DeltaChip({required this.delta});

  final int delta;

  @override
  Widget build(BuildContext context) {
    final isUp = delta >= 0;
    final color =
        delta.abs() <= 5 ? const Color(0xFF10B981) : const Color(0xFFEF4444);
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          isUp ? Icons.arrow_upward_rounded : Icons.arrow_downward_rounded,
          size: 11,
          color: color,
        ),
        const SizedBox(width: 1),
        Text(
          '${isUp ? '+' : ''}$delta',
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: color,
          ),
        ),
      ],
    );
  }
}

// ─── HR bar chart — accepts plain List<int> bpm values ───────────────────────

class _HrBarChart extends StatelessWidget {
  const _HrBarChart({required this.bpmValues});

  final List<int> bpmValues;

  static const _barColor = Color(0xFFEF4444);
  static const _maxHeight = 60.0;
  static const _barCount = 30;

  // Naturalistic rising pattern shown before any readings arrive.
  static const _placeholderHeights = [
    0.28,
    0.32,
    0.30,
    0.35,
    0.38,
    0.36,
    0.40,
    0.44,
    0.42,
    0.48,
    0.50,
    0.47,
    0.52,
    0.56,
    0.53,
    0.58,
    0.62,
    0.59,
    0.66,
    0.70,
    0.68,
    0.73,
    0.70,
    0.76,
    0.74,
    0.80,
    0.76,
    0.82,
    0.79,
    0.74,
  ];

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: _maxHeight,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: _buildBars(),
      ),
    );
  }

  List<Widget> _buildBars() {
    if (bpmValues.isEmpty) {
      return List.generate(
        _barCount,
        (i) => _bar(_placeholderHeights[i], isPlaceholder: true),
      );
    }

    final minBpm = bpmValues.reduce((a, b) => a < b ? a : b).toDouble();
    final maxBpm = bpmValues.reduce((a, b) => a > b ? a : b).toDouble();
    final range = (maxBpm - minBpm).clamp(1.0, double.infinity);

    final bars = bpmValues.map((bpm) {
      final normalized = (bpm - minBpm) / range;
      return _bar(0.15 + normalized * 0.85);
    }).toList();

    // Left-pad with dimmed bars until we have 30 slots.
    while (bars.length < _barCount) {
      bars.insert(0, _bar(0.15, isPlaceholder: true));
    }

    return bars;
  }

  Widget _bar(double heightFraction, {bool isPlaceholder = false}) {
    return Expanded(
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 1.0),
        height: _maxHeight * heightFraction.clamp(0.08, 1.0),
        decoration: BoxDecoration(
          color: isPlaceholder ? _barColor.withValues(alpha: 0.22) : _barColor,
          borderRadius: const BorderRadius.vertical(
            top: Radius.circular(2),
          ),
        ),
      ),
    );
  }
}
