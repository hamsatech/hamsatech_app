import 'package:flutter/material.dart';
import 'package:hamsatech_design_system/hamsatech_design_system.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';


import '../../../../core/di/injection.dart';
import '../bloc/dashboard_bloc.dart';
import '../bloc/dashboard_event.dart';
import '../bloc/dashboard_state.dart';
import '../widgets/action_plan_card.dart';
import '../widgets/ai_insights_card.dart';
import '../widgets/hero_metrics_card.dart';
import '../widgets/performance_chart_card.dart';
import '../widgets/session_summary_card.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) =>
          getIt<DashboardBloc>()..add(const DashboardLoadRequested()),
      child: const _DashboardView(),
    );
  }
}

class _DashboardView extends StatelessWidget {
  const _DashboardView();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BlocBuilder<DashboardBloc, DashboardState>(
        builder: (context, state) {
          return RefreshIndicator(
            color: DSColors.brand,
            backgroundColor: DSColors.appCard,
            onRefresh: () async {
              context
                  .read<DashboardBloc>()
                  .add(const DashboardRefreshRequested());
              await Future.delayed(const Duration(milliseconds: 500));
            },
            child: CustomScrollView(
              slivers: [
                _buildAppBar(context),
                if (state is DashboardLoading)
                  const SliverFillRemaining(
                    child: Center(
                      child: CircularProgressIndicator(
                          color: DSColors.brand),
                    ),
                  )
                else if (state is DashboardError)
                  SliverFillRemaining(
                    child: Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.error_outline_rounded,
                              color: DSColors.error, size: 48),
                          const SizedBox(height: 12),
                          Text(state.message,
                              style: DSTypography.bodyMedium),
                          const SizedBox(height: 16),
                          TextButton(
                            onPressed: () => context.read<DashboardBloc>()
                                .add(const DashboardLoadRequested()),
                            child: const Text('Retry'),
                          ),
                        ],
                      ),
                    ),
                  )
                else if (state is DashboardLoaded)
                  SliverPadding(
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 100),
                    sliver: SliverList(
                      delegate: SliverChildListDelegate([
                        // Row 1 — Hero Metrics
                        HeroMetricsCard(
                          athleteName: state.data.athleteName,
                          metrics: state.data.readiness,
                        ),
                        const SizedBox(height: 16),
                        // Row 2 — AI Insights
                        AiInsightsCard(insights: state.data.aiInsights),
                        const SizedBox(height: 16),
                        // Row 3 — Session Summary
                        SessionSummaryCard(session: state.data.lastSession),
                        const SizedBox(height: 16),
                        // Row 4 — Performance Chart
                        PerformanceChartCard(
                            history: state.data.performanceHistory),
                        const SizedBox(height: 16),
                        // Row 5 — Action Plan
                        ActionPlanCard(actions: state.data.actionPlan),
                      ]),
                    ),
                  ),
              ],
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.push('/session/pre'),
        backgroundColor: DSColors.brand,
        icon: const Icon(Icons.play_arrow_rounded, color: Colors.white),
        label: const Text('Start Session',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
      ),
    );
  }

  SliverAppBar _buildAppBar(BuildContext context) {
    return SliverAppBar(
      floating: true,
      snap: true,
      backgroundColor: DSColors.appBackground,
      elevation: 0,
      title: Row(
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: DSColors.brand,
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(Icons.gps_fixed_rounded,
                color: Colors.white, size: 18),
          ),
          const SizedBox(width: 10),
          Text('HAMSA', style: DSTypography.headingSmall.copyWith(
            letterSpacing: 2,
          )),
        ],
      ),
      actions: [
        IconButton(
          icon: const Icon(Icons.edit_note_rounded,
              color: DSColors.textSecondary),
          tooltip: 'Ask Me Journal',
          onPressed: () => context.go('/journal'),
        ),
      ],
    );
  }
}
