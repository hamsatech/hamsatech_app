import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:hamsatech_design_system/hamsatech_design_system.dart';

import '../../bloc/score_entry_bloc.dart';
import '../../bloc/score_entry_event.dart';
import '../../bloc/score_entry_state.dart';
import '../../domain/entities/session_series_entity.dart';

class SeriesCompleteScreen extends StatelessWidget {
  const SeriesCompleteScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<ScoreEntryBloc, ScoreEntryState>(
      listener: (context, state) {
        if (state is ScoreEntryActiveState) {
          context.pushReplacement('/session/scores');
        } else if (state is AllSeriesCompleteState) {
          context.pushReplacement('/session/scores/summary');
        }
      },
      builder: (context, state) {
        if (state is! SeriesCompleteState) {
          return const Scaffold(
            backgroundColor: DSColors.appBackground,
            body: Center(child: CircularProgressIndicator()),
          );
        }
        return _SeriesCompleteView(state: state);
      },
    );
  }
}

class _SeriesCompleteView extends StatelessWidget {
  const _SeriesCompleteView({required this.state});

  final SeriesCompleteState state;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: DSColors.appBackground,
      appBar: AppBar(
        backgroundColor: DSColors.appBackground,
        elevation: 0,
        scrolledUnderElevation: 0,
        automaticallyImplyLeading: false,
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
              const SizedBox(height: DSSpacing.xxl),
              Text(
                'Series ${state.justCompletedSeriesNumber} complete',
                style: DSTypography.headingXl.copyWith(color: DSColors.black),
              ),
              const SizedBox(height: DSSpacing.xs),
              Text(
                'Series ${state.justCompletedSeriesNumber} of ${state.totalSeries}',
                style: DSTypography.bodySm.copyWith(color: DSColors.textSecondary),
              ),
              const SizedBox(height: DSSpacing.xxxl),
              _ShotChips(shots: state.justCompletedShots),
              const SizedBox(height: DSSpacing.xxl),
              const Divider(height: 1, thickness: 1, color: DSColors.gray200),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: DSSpacing.lg),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Series Total',
                      style: DSTypography.bodyLg.copyWith(
                          color: DSColors.textSecondary),
                    ),
                    Text(
                      state.formattedTotal,
                      style: DSTypography.headingLarge
                          .copyWith(color: DSColors.black),
                    ),
                  ],
                ),
              ),
              const Divider(height: 1, thickness: 1, color: DSColors.gray200),
              const Spacer(),
              DSPrimaryButton(
                label: state.isLastSeries
                    ? 'View Final Summary'
                    : 'Next Series',
                onPressed: () => context
                    .read<ScoreEntryBloc>()
                    .add(const ScoreEntrySeriesConfirmed()),
                color: DSColors.info,
              ),
              const SizedBox(height: DSSpacing.md),
              DSButton(
                label: 'Edit Scores',
                variant: DSButtonVariant.outline,
                size: DSButtonSize.lg,
                isFullWidth: true,
                onPressed: () => context
                    .read<ScoreEntryBloc>()
                    .add(const ScoreEntryEditRequested()),
              ),
              const SizedBox(height: DSSpacing.xxl),
            ],
          ),
        ),
      ),
    );
  }
}

class _ShotChips extends StatelessWidget {
  const _ShotChips({required this.shots});

  final List<ScoreValue> shots;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: DSSpacing.sm,
      runSpacing: DSSpacing.sm,
      children: shots.map((shot) {
        final Color bg;
        final Color text;
        if (shot.isMiss) {
          bg = DSColors.error;
          text = DSColors.white;
        } else if (shot.isSubFive) {
          bg = DSColors.error.withValues(alpha: 0.07);
          text = DSColors.error;
        } else {
          bg = DSColors.gray100;
          text = DSColors.black;
        }

        return Container(
          padding: const EdgeInsets.symmetric(
              horizontal: DSSpacing.md, vertical: DSSpacing.sm),
          decoration: BoxDecoration(
            color: bg,
            borderRadius: DSRadius.borderSm,
          ),
          child: Text(
            shot.display,
            style: DSTypography.headingSm.copyWith(color: text),
          ),
        );
      }).toList(),
    );
  }
}
