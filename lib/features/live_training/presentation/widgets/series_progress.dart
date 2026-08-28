import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../bloc/live_training_bloc.dart';
import '../../bloc/live_training_event.dart';

class SeriesProgress extends StatelessWidget {
  const SeriesProgress({
    required this.currentSeriesIndex,
    required this.totalSeries,
    required this.shotsPerSeries,
    super.key,
  });

  final int currentSeriesIndex;
  final int totalSeries;
  final int shotsPerSeries;

  int get _seriesNumber => currentSeriesIndex + 1;
  int get _seriesRemaining => totalSeries - currentSeriesIndex - 1;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Series progress',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: const Color(0xFF000F12),
            ),
          ),
          const SizedBox(height: 10),
          _SegmentedBar(
            currentIndex: currentSeriesIndex,
            total: totalSeries,
          ),
          const SizedBox(height: 16),
          _MarkSeriesButton(seriesNumber: _seriesNumber),
          const SizedBox(height: 10),
          Text(
            'Currently in Series $_seriesNumber · $shotsPerSeries shots'
            '${_seriesRemaining > 0 ? ' · $_seriesRemaining remaining' : ''}',
            style: const TextStyle(
              fontSize: 12,
              color: const Color(0x66000F12),
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

// ─── Segmented bar ────────────────────────────────────────────────────────────

class _SegmentedBar extends StatelessWidget {
  const _SegmentedBar({required this.currentIndex, required this.total});

  final int currentIndex;
  final int total;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: List.generate(total, (i) {
        final isFilled = i <= currentIndex;
        return Expanded(
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeOut,
            height: 6,
            margin: EdgeInsets.only(left: i == 0 ? 0 : 4),
            decoration: BoxDecoration(
              color:
                  isFilled ? const Color(0xFF2F7E8F) : const Color(0xFFCAE8EE),
              borderRadius: BorderRadius.circular(3),
            ),
          ),
        );
      }),
    );
  }
}

// ─── Mark series button ───────────────────────────────────────────────────────

class _MarkSeriesButton extends StatelessWidget {
  const _MarkSeriesButton({required this.seriesNumber});

  final int seriesNumber;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 52,
      child: ElevatedButton(
        onPressed: () => context
            .read<LiveTrainingBloc>()
            .add(const LiveTrainingSeriesCompleted()),
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF2F7E8F),
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          elevation: 0,
        ),
        child: Text(
          'Mark end of Series $seriesNumber',
          style: const TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}
