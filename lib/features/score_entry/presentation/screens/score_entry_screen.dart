import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:hamsatech_design_system/hamsatech_design_system.dart';

import '../../bloc/score_entry_bloc.dart';
import '../../bloc/score_entry_event.dart';
import '../../bloc/score_entry_state.dart';
import '../widgets/score_grid.dart';
import '../widgets/shot_tracker.dart';

class ScoreEntryScreen extends StatefulWidget {
  const ScoreEntryScreen({super.key});

  @override
  State<ScoreEntryScreen> createState() => _ScoreEntryScreenState();
}

class _ScoreEntryScreenState extends State<ScoreEntryScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ScoreEntryBloc>().add(const ScoreEntryStartRequested());
    });
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<ScoreEntryBloc, ScoreEntryState>(
      listener: (context, state) {
        if (state is SeriesCompleteState) {
          context.pushReplacement('/session/scores/complete');
        }
      },
      builder: (context, state) {
        if (state is! ScoreEntryActiveState) {
          return const Scaffold(
            backgroundColor: DSColors.appBackground,
            body: Center(child: CircularProgressIndicator()),
          );
        }
        return _ScoreEntryView(state: state);
      },
    );
  }
}

class _ScoreEntryView extends StatelessWidget {
  const _ScoreEntryView({required this.state});

  final ScoreEntryActiveState state;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: DSColors.appBackground,
      appBar: AppBar(
        backgroundColor: DSColors.appBackground,
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: DSColors.black),
          onPressed: () => context.go('/home'),
        ),
        title: Text(
          state.sessionTitle,
          style: DSTypography.headingSmall.copyWith(color: DSColors.black),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: DSSpacing.xl),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: DSSpacing.lg),
              Text(
                'Enter your scores',
                style: DSTypography.headingXl.copyWith(color: DSColors.black),
              ),
              const SizedBox(height: DSSpacing.xs),
              Text(
                'Series ${state.currentSeriesNumber} of ${state.totalSeries}',
                style: DSTypography.bodySm.copyWith(color: DSColors.textSecondary),
              ),
              const SizedBox(height: DSSpacing.xxs),
              Text(
                'Shot ${state.currentShotNumber} of ${state.shotsPerSeries}',
                style: DSTypography.headingMd.copyWith(color: DSColors.black),
              ),
              const SizedBox(height: DSSpacing.xxs),
              Text(
                'Tap or say your score:',
                style: DSTypography.bodySm.copyWith(color: DSColors.textSecondary),
              ),
              const SizedBox(height: DSSpacing.md),
              const ScoreGrid(),
              const SizedBox(height: DSSpacing.xl),
              ShotTracker(
                shots: state.currentShots,
                shotsPerSeries: state.shotsPerSeries,
              ),
              const Spacer(),
              Center(
                child: DSSecondaryTextButton(
                  label: 'Undo last',
                  onPressed: state.canUndo
                      ? () => context
                          .read<ScoreEntryBloc>()
                          .add(const ScoreEntryUndoLast())
                      : null,
                  color: state.canUndo ? DSColors.info : DSColors.gray300,
                ),
              ),
              const SizedBox(height: DSSpacing.lg),
            ],
          ),
        ),
      ),
    );
  }
}
