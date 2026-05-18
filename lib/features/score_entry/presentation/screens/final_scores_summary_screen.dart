import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:hamsatech_design_system/hamsatech_design_system.dart';

import '../../bloc/score_entry_bloc.dart';
import '../../bloc/score_entry_event.dart';
import '../../bloc/score_entry_state.dart';
import '../../domain/entities/session_series_entity.dart';

class FinalScoresSummaryScreen extends StatelessWidget {
  const FinalScoresSummaryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<ScoreEntryBloc, ScoreEntryState>(
      listener: (context, state) {
        if (state is ScoreEntrySavedState) {
          context.go('/session/reflection');
        }
      },
      builder: (context, state) {
        if (state is! AllSeriesCompleteState) {
          return const Scaffold(
            backgroundColor: DSColors.appBackground,
            body: Center(child: CircularProgressIndicator()),
          );
        }
        return _SummaryView(state: state);
      },
    );
  }
}

class _SummaryView extends StatelessWidget {
  const _SummaryView({required this.state});

  final AllSeriesCompleteState state;

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
          onPressed: () => Navigator.of(context).maybePop(),
        ),
      ),
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(
                  DSSpacing.xl, DSSpacing.sm, DSSpacing.xl, DSSpacing.lg),
              child: Text(
                'All Scores entered',
                style: DSTypography.headingXl.copyWith(color: DSColors.black),
              ),
            ),
            Expanded(
              child: ListView.separated(
                padding: EdgeInsets.zero,
                itemCount: state.allSeries.length + 1,
                separatorBuilder: (_, __) => const Divider(
                  height: 1,
                  thickness: 1,
                  color: DSColors.gray200,
                  indent: DSSpacing.xl,
                  endIndent: DSSpacing.xl,
                ),
                itemBuilder: (context, index) {
                  if (index < state.allSeries.length) {
                    return _SeriesRow(series: state.allSeries[index]);
                  }
                  return _TotalRow(total: state.formattedGrandTotal);
                },
              ),
            ),
            const Divider(
                height: 1, thickness: 1, color: DSColors.gray200),
            Padding(
              padding: const EdgeInsets.fromLTRB(
                  DSSpacing.xl, DSSpacing.lg, DSSpacing.xl, DSSpacing.xxl),
              child: DSPrimaryButton(
                label: 'Looks correct - Continue  ✓',
                color: const Color(0xFF2F7E8F),
                onPressed: () => context
                    .read<ScoreEntryBloc>()
                    .add(const ScoreEntryFinalConfirmed()),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SeriesRow extends StatelessWidget {
  const _SeriesRow({required this.series});

  final SessionSeries series;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(
          horizontal: DSSpacing.xl, vertical: DSSpacing.lg),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            'Series ${series.seriesNumber}',
            style: DSTypography.bodyLg.copyWith(color: DSColors.black),
          ),
          Text(
            series.formattedTotal,
            style: DSTypography.headingMd.copyWith(color: DSColors.black),
          ),
        ],
      ),
    );
  }
}

class _TotalRow extends StatelessWidget {
  const _TotalRow({required this.total});

  final String total;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(
          horizontal: DSSpacing.xl, vertical: DSSpacing.lg),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            'Total',
            style: DSTypography.headingMd.copyWith(color: DSColors.black),
          ),
          Text(
            total,
            style: DSTypography.headingLarge.copyWith(
              color: DSColors.success,
            ),
          ),
        ],
      ),
    );
  }
}
