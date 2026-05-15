import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:hamsatech_design_system/hamsatech_design_system.dart';

import '../../bloc/session_summary_bloc.dart';
import '../../bloc/session_summary_event.dart';
import '../../bloc/session_summary_state.dart';
import '../../domain/entities/session_summary_entity.dart';
import '../widgets/mood_correlation_card.dart';
import '../widgets/score_pace_chart.dart';
import '../widgets/series_breakdown_row.dart';
import '../widgets/summary_metric_card.dart';
import '../widgets/target_board.dart';

class SessionSummaryScreen extends StatefulWidget {
  const SessionSummaryScreen({super.key});

  @override
  State<SessionSummaryScreen> createState() => _SessionSummaryScreenState();
}

class _SessionSummaryScreenState extends State<SessionSummaryScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context
          .read<SessionSummaryBloc>()
          .add(const SessionSummaryLoadRequested());
    });
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<SessionSummaryBloc, SessionSummaryState>(
      builder: (context, state) {
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
          ),
          body: switch (state) {
            SessionSummaryLoading() || SessionSummaryInitial() =>
              const Center(child: CircularProgressIndicator()),
            SessionSummaryError(:final message) => Center(
                child: Text(message,
                    style:
                        DSTypography.bodyMd.copyWith(color: DSColors.textSecondary)),
              ),
            SessionSummaryLoaded(:final data, :final selectedSeriesIndex) =>
              _SummaryBody(
                data: data,
                selectedSeriesIndex: selectedSeriesIndex,
              ),
            _ => const SizedBox.shrink(),
          },
        );
      },
    );
  }
}

// ── Body ──────────────────────────────────────────────────────────────────────

class _SummaryBody extends StatelessWidget {
  const _SummaryBody({
    required this.data,
    required this.selectedSeriesIndex,
  });

  final SessionSummaryEntity data;
  final int selectedSeriesIndex;

  static const _teal = Color(0xFF2F7E8F);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Expanded(
          child: SafeArea(
            bottom: false,
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(
                  horizontal: DSSpacing.xl, vertical: DSSpacing.lg),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _Header(data: data),
                  const SizedBox(height: DSSpacing.xl),
                  _MetricGrid(data: data),
                  const SizedBox(height: DSSpacing.xxl),
                  _Section(
                    title: 'Series breakdown',
                    child: _BreakdownSection(data: data),
                  ),
                  const SizedBox(height: DSSpacing.xxl),
                  _Section(
                    title: 'Score pace',
                    child: ScorePaceChart(points: data.scorePoints),
                  ),
                  const SizedBox(height: DSSpacing.xxl),
                  _Section(
                    title: 'Target board',
                    child: TargetBoardCard(
                      seriesBreakdown: data.seriesBreakdown,
                      selectedSeriesIndex: selectedSeriesIndex,
                      onSeriesChanged: (i) => context
                          .read<SessionSummaryBloc>()
                          .add(SessionSummarySeriesSelected(i)),
                    ),
                  ),
                  if (data.moodCorrelation != null) ...[
                    const SizedBox(height: DSSpacing.xxl),
                    _Section(
                      title: 'Mood-score correlation',
                      child: MoodCorrelationCard(mood: data.moodCorrelation!),
                    ),
                  ],
                  const SizedBox(height: DSSpacing.xxxl),
                ],
              ),
            ),
          ),
        ),
        const Divider(height: 1, thickness: 1, color: DSColors.gray200),
        SafeArea(
          top: false,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(
                DSSpacing.xl, DSSpacing.lg, DSSpacing.xl, DSSpacing.xxl),
            child: DSPrimaryButton(
              label: 'Save & View Full Report',
              color: _teal,
              onPressed: () => context.go('/session/report'),
            ),
          ),
        ),
      ],
    );
  }
}

// ── Header ────────────────────────────────────────────────────────────────────

class _Header extends StatelessWidget {
  const _Header({required this.data});

  final SessionSummaryEntity data;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Session summary',
          style: DSTypography.headingXl.copyWith(color: DSColors.black),
        ),
        const SizedBox(height: DSSpacing.xs),
        Text(
          '${data.sessionTitle} · ${data.totalShots} shots · ${data.duration}',
          style: DSTypography.bodySm.copyWith(color: DSColors.textSecondary),
        ),
      ],
    );
  }
}

// ── Metric grid ───────────────────────────────────────────────────────────────

class _MetricGrid extends StatelessWidget {
  const _MetricGrid({required this.data});

  final SessionSummaryEntity data;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Row 1: Total | Average
        IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Expanded(
                child: SummaryMetricCard(
                  primaryValue: data.formattedTotal,
                  valueSuffix: '/ ${data.maxPossible.toInt()}',
                  label: 'Total',
                ),
              ),
              const SizedBox(width: DSSpacing.sm),
              Expanded(
                child: SummaryMetricCard(
                  primaryValue: data.formattedAverage,
                  valueSuffix: 'per shot',
                  label: 'Average',
                  primaryColor: DSColors.info,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: DSSpacing.sm),
        // Row 2: Efficiency (full width)
        SummaryMetricCard(
          primaryValue: '${data.formattedEfficiency}%',
          valueSuffix: 'of max',
          label: 'Efficiency',
          primaryColor: DSColors.info,
        ),
        const SizedBox(height: DSSpacing.sm),
        // Row 3: Best shot | Worst shot
        IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Expanded(
                child: SummaryMetricCard(
                  primaryValue: data.formattedBestShot,
                  label: 'Best shot',
                  primaryColor: DSColors.success,
                ),
              ),
              const SizedBox(width: DSSpacing.sm),
              Expanded(
                child: SummaryMetricCard(
                  primaryValue: data.formattedWorstShot,
                  label: 'Worst shot',
                  primaryColor: DSColors.error,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: DSSpacing.sm),
        // Row 4: Best series | Worst series
        IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Expanded(
                child: SummaryMetricCard(
                  primaryValue: data.bestSeriesLabel,
                  label: 'Best series',
                  primaryColor: DSColors.info,
                ),
              ),
              const SizedBox(width: DSSpacing.sm),
              Expanded(
                child: SummaryMetricCard(
                  primaryValue: data.worstSeriesLabel,
                  label: 'Worst series',
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

// ── Section wrapper ───────────────────────────────────────────────────────────

class _Section extends StatelessWidget {
  const _Section({required this.title, required this.child});

  final String title;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: DSTypography.headingMd.copyWith(color: DSColors.black),
        ),
        const SizedBox(height: DSSpacing.md),
        child,
      ],
    );
  }
}

// ── Series breakdown section ──────────────────────────────────────────────────

class _BreakdownSection extends StatelessWidget {
  const _BreakdownSection({required this.data});

  final SessionSummaryEntity data;

  @override
  Widget build(BuildContext context) {
    if (data.seriesBreakdown.isEmpty) {
      return Text(
        'No series data',
        style: DSTypography.bodySm.copyWith(color: DSColors.textMuted),
      );
    }
    return Column(
      children: data.seriesBreakdown
          .map((s) => SeriesBreakdownRow(series: s))
          .toList(),
    );
  }
}
