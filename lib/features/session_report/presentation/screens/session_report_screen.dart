import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:hamsatech_design_system/hamsatech_design_system.dart';

import '../../bloc/session_report_bloc.dart';
import '../../bloc/session_report_event.dart';
import '../../bloc/session_report_state.dart';
import '../../domain/entities/session_report_entity.dart';
import '../widgets/coach_feedback_card.dart';
import '../widgets/hr_chart_card.dart';
import '../widgets/insight_card.dart';
import '../widgets/mental_state_table.dart';
import '../widgets/metric_table_card.dart';
import '../widgets/recommendation_card.dart';
import '../widgets/report_section_header.dart';
import '../widgets/report_series_breakdown_row.dart';

class SessionReportScreen extends StatefulWidget {
  const SessionReportScreen({super.key});

  @override
  State<SessionReportScreen> createState() => _SessionReportScreenState();
}

class _SessionReportScreenState extends State<SessionReportScreen> {
  static const _teal = Color(0xFF2F7E8F);

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context
          .read<SessionReportBloc>()
          .add(const SessionReportLoadRequested());
    });
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<SessionReportBloc, SessionReportState>(
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
            SessionReportLoading() || SessionReportInitial() =>
              const Center(child: CircularProgressIndicator()),
            SessionReportError(:final message) => Center(
                child: Text(
                  message,
                  style: DSTypography.bodyMd.copyWith(color: DSColors.textSecondary),
                ),
              ),
            SessionReportLoaded(:final data) => _ReportBody(
                data: data,
                teal: _teal,
                onDone: () => context.go('/home'),
                onBreathing: () => context.go('/ritual/breathing'),
              ),
            _ => const SizedBox.shrink(),
          },
        );
      },
    );
  }
}

// ── Body ──────────────────────────────────────────────────────────────────────

class _ReportBody extends StatelessWidget {
  const _ReportBody({
    required this.data,
    required this.teal,
    required this.onDone,
    required this.onBreathing,
  });

  final SessionReportEntity data;
  final Color teal;
  final VoidCallback onDone;
  final VoidCallback onBreathing;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(
                DSSpacing.xl, DSSpacing.sm, DSSpacing.xl, DSSpacing.xxl),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ── Header ─────────────────────────────────────────────────
                _PageHeader(data: data),
                const SizedBox(height: DSSpacing.xxl),

                // ── 1. Physiology State ────────────────────────────────────
                const ReportSectionHeader(title: 'Physiology State'),
                buildPhysiologyCard(physiology: data.physiology),
                const SizedBox(height: DSSpacing.xxl),

                // ── 2. Series Breakdown ────────────────────────────────────
                const ReportSectionHeader(title: 'Series Breakdown'),
                _SeriesBreakdownList(series: data.seriesRows),
                const SizedBox(height: DSSpacing.xxl),

                // ── 3. Heart Rate Behavior ─────────────────────────────────
                const ReportSectionHeader(title: 'Heart Rate Behavior'),
                HrChartCard(
                  points: data.hrPoints,
                  metrics: data.hrMetrics,
                ),
                const SizedBox(height: DSSpacing.xxl),

                // ── 4. Mental State ────────────────────────────────────────
                const ReportSectionHeader(
                  title: 'Mental State',
                  subtitle: 'Before vs after',
                ),
                MentalStateTable(comparison: data.mentalState),
                const SizedBox(height: DSSpacing.xxl),

                // ── 5. Key Insight ─────────────────────────────────────────
                const ReportSectionHeader(title: 'Key Insight'),
                InsightCard(insight: data.insight),
                const SizedBox(height: DSSpacing.xxl),

                // ── 6. Recommendations ─────────────────────────────────────
                const ReportSectionHeader(title: 'Recommendations'),
                RecommendationCard(
                  items: data.recommendations,
                  onBreathingTap: onBreathing,
                ),
                const SizedBox(height: DSSpacing.xxl),

                // ── 7. Coach Feedback ──────────────────────────────────────
                const ReportSectionHeader(title: 'Coach Feedback'),
                CoachFeedbackCard(feedback: data.coachFeedback),
              ],
            ),
          ),
        ),

        // ── Fixed bottom CTA ───────────────────────────────────────────────
        const Divider(height: 1, thickness: 1, color: DSColors.gray200),
        SafeArea(
          top: false,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(
                DSSpacing.xl, DSSpacing.lg, DSSpacing.xl, DSSpacing.xxl),
            child: DSPrimaryButton(
              label: 'Done - Back to Home',
              color: teal,
              onPressed: onDone,
            ),
          ),
        ),
      ],
    );
  }
}

// ── Page header ───────────────────────────────────────────────────────────────

class _PageHeader extends StatelessWidget {
  const _PageHeader({required this.data});

  final SessionReportEntity data;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Today\'s Sessions',
          style: DSTypography.bodySm.copyWith(color: DSColors.textSecondary),
        ),
        const SizedBox(height: DSSpacing.xs),
        Text(
          'Session Report',
          style: DSTypography.headingXl.copyWith(color: DSColors.black),
        ),
        const SizedBox(height: DSSpacing.xxs),
        Text(
          data.timeLabel.isNotEmpty
              ? '${data.dateLabel}  ·  ${data.timeLabel}'
              : data.dateLabel,
          style: DSTypography.bodySm.copyWith(color: DSColors.textSecondary),
        ),
      ],
    );
  }
}

// ── Series breakdown list ─────────────────────────────────────────────────────

class _SeriesBreakdownList extends StatelessWidget {
  const _SeriesBreakdownList({required this.series});

  final List<ReportSeriesRowEntity> series;

  @override
  Widget build(BuildContext context) {
    if (series.isEmpty) {
      return Text(
        'No series data',
        style: DSTypography.bodySm.copyWith(color: DSColors.textMuted),
      );
    }
    return Container(
      decoration: BoxDecoration(
        color: DSColors.white,
        border: Border.all(color: DSColors.gray200),
        borderRadius: DSRadius.borderMd,
      ),
      padding: const EdgeInsets.symmetric(
          horizontal: DSSpacing.lg, vertical: DSSpacing.sm),
      child: Column(
        children:
            series.map((s) => ReportSeriesBreakdownRow(series: s)).toList(),
      ),
    );
  }
}
