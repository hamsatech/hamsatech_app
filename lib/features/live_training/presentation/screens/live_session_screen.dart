import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/di/injection.dart';
import '../../../polar/presentation/bloc/polar_bloc.dart';
import '../../bloc/live_training_bloc.dart';
import '../../bloc/live_training_event.dart';
import '../../bloc/live_training_state.dart';
import '../widgets/hr_analytics_card.dart';
import '../widgets/instruction_card.dart';
import '../widgets/live_header.dart';
import '../widgets/series_progress.dart';

class LiveSessionScreen extends StatelessWidget {
  const LiveSessionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider.value(value: getIt<LiveTrainingBloc>()),
        BlocProvider.value(value: getIt<PolarBloc>()),
      ],
      child: const _LiveSessionView(),
    );
  }
}

class _LiveSessionView extends StatefulWidget {
  const _LiveSessionView();

  @override
  State<_LiveSessionView> createState() => _LiveSessionViewState();
}

class _LiveSessionViewState extends State<_LiveSessionView> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context
          .read<LiveTrainingBloc>()
          .add(const LiveTrainingStartRequested());
    });
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<LiveTrainingBloc, LiveTrainingState>(
      listener: (context, state) {
        if (state is ReflectingState) {
          context.pushReplacement('/session/reflect');
        }
      },
      builder: (context, state) {
        final s =
            state is LiveSessionActiveState ? state : null;
        return Scaffold(
          backgroundColor: const Color(0xFFF5FDFF),
          body: SafeArea(
            child: Column(
              children: [
                // ── Header ───────────────────────────────────────────
                LiveHeader(
                  sessionTitle: s?.sessionTitle ?? '',
                  formattedElapsed: s?.formattedElapsed ?? '0:00',
                  isPaused: s?.isPaused ?? false,
                ),
                const Divider(height: 1, color: Color(0xFFCAE8EE)),

                // ── Scrollable body ───────────────────────────────────
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(vertical: 18),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const InstructionCard(),
                        const SizedBox(height: 16),
                        HrAnalyticsCard(
                          baselineHr: s?.baselineHr ?? 65,
                          simulatedHr: s?.simulatedHr,
                          simulatedHrHistory:
                              s?.simulatedHrHistory ?? const [],
                        ),
                        const SizedBox(height: 24),
                        if (s != null)
                          SeriesProgress(
                            currentSeriesIndex: s.currentSeriesIndex,
                            totalSeries: s.totalSeries,
                            shotsPerSeries: s.shotsPerSeries,
                          ),
                      ],
                    ),
                  ),
                ),

                // ── Bottom action bar ─────────────────────────────────
                _BottomActionBar(isPaused: s?.isPaused ?? false),
              ],
            ),
          ),
        );
      },
    );
  }
}

// ─── Bottom action bar ────────────────────────────────────────────────────────

class _BottomActionBar extends StatelessWidget {
  const _BottomActionBar({required this.isPaused});

  final bool isPaused;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: Color(0xFFCAE8EE))),
      ),
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
      child: Row(
        children: [
          // Pause / Resume
          Expanded(
            child: TextButton.icon(
              onPressed: () => context
                  .read<LiveTrainingBloc>()
                  .add(const LiveTrainingPauseToggled()),
              icon: Icon(
                isPaused
                    ? Icons.play_arrow_rounded
                    : Icons.pause_rounded,
                size: 18,
              ),
              label: Text(isPaused ? 'Resume' : 'Pause'),
              style: TextButton.styleFrom(
                foregroundColor: const Color(0xFF2A5562),
                textStyle: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w500,
                ),
                padding: const EdgeInsets.symmetric(vertical: 14),
              ),
            ),
          ),
          const SizedBox(width: 12),
          // End session
          Expanded(
            flex: 2,
            child: ElevatedButton.icon(
              onPressed: () => context
                  .read<LiveTrainingBloc>()
                  .add(const LiveTrainingEndRequested()),
              icon: const Icon(Icons.check_rounded, size: 18),
              label: const Text('End Session'),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF2F7E8F),
                foregroundColor: Colors.white,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                textStyle: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                ),
                padding: const EdgeInsets.symmetric(vertical: 14),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
