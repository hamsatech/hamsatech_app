import 'package:flutter/material.dart';
import 'package:hamsatech_design_system/hamsatech_design_system.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/services/storage_service.dart';
import '../../domain/entities/assessment_result_entity.dart';

class AssessmentResultScreen extends StatelessWidget {
  const AssessmentResultScreen({super.key, required this.extra});

  final Map<String, dynamic>? extra;

  void _onContinue(BuildContext context) {
    if (StorageService.isOnboardingComplete()) {
      // Dashboard refreshes itself on (re)mount and whenever the caller that
      // pushed /questions awaits its return (see dashboard_screen.dart) — no
      // separate refresh call is needed here, since getIt<DashboardBloc>()
      // would only ever construct a disconnected, throwaway factory instance
      // that nobody is listening to.
      context.go('/home');
    } else {
      context.go('/permissions');
    }
  }

  @override
  Widget build(BuildContext context) {
    final categoryScores =
        (extra?['categoryScores'] as List<CategoryScoreEntity>?) ?? const [];
    final insights =
        (extra?['insights'] as List<AssessmentInsightEntity>?) ?? const [];

    return Scaffold(
      backgroundColor: DSColors.appBackground,
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'Your Results',
                  style: DSTypography.bodyMd.copyWith(
                    color: const Color(0x99000F12),
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ),
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(20, 8, 20, 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Here\'s what we learned about you',
                      style: DSTypography.onboardingCaption.copyWith(
                        color: const Color(0xFF000F12),
                        fontWeight: FontWeight.w700,
                        height: 1.35,
                      ),
                    ),
                    const SizedBox(height: 24),
                    ...categoryScores.map((c) => _CategoryScoreCard(score: c)),
                    if (insights.isNotEmpty) ...[
                      const SizedBox(height: 12),
                      Text(
                        'Insights',
                        style: DSTypography.labelMd.copyWith(
                          color: DSColors.terracotta,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 12),
                      ...insights.map((i) => _InsightCard(insight: i)),
                    ],
                  ],
                ),
              ),
            ),
            const Divider(height: 1, color: Color(0xFFCAE8EE)),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 16),
              child: SizedBox(
                width: double.infinity,
                child: DSPrimaryButton(
                  label: 'Continue',
                  color: DSColors.terracotta,
                  onPressed: () => _onContinue(context),
                  textStyle: DSTypography.labelMd.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CategoryScoreCard extends StatelessWidget {
  const _CategoryScoreCard({required this.score});

  final CategoryScoreEntity score;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE2F4F7)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  score.displayName,
                  style: DSTypography.bodyMd.copyWith(
                    color: const Color(0xFF000F12),
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              if (score.score != null)
                Text(
                  '${score.score!.round()}',
                  style: DSTypography.bodyMd.copyWith(
                    color: DSColors.terracotta,
                    fontWeight: FontWeight.w700,
                  ),
                ),
            ],
          ),
          if (score.childDescription != null) ...[
            const SizedBox(height: 6),
            Text(
              score.childDescription!,
              style: DSTypography.bodySm.copyWith(
                color: const Color(0x99000F12),
              ),
            ),
          ],
          if (score.interpretation != null) ...[
            const SizedBox(height: 6),
            Text(
              score.interpretation!,
              style: DSTypography.bodySm.copyWith(
                color: const Color(0xFF4D8F9C),
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _InsightCard extends StatelessWidget {
  const _InsightCard({required this.insight});

  final AssessmentInsightEntity insight;

  @override
  Widget build(BuildContext context) {
    if (insight.title == null && insight.insightText == null) {
      return const SizedBox.shrink();
    }
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFF5FDFF),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFCAE8EE)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (insight.title != null)
            Text(
              insight.title!,
              style: DSTypography.bodyMd.copyWith(
                color: const Color(0xFF000F12),
                fontWeight: FontWeight.w600,
              ),
            ),
          if (insight.insightText != null) ...[
            const SizedBox(height: 6),
            Text(
              insight.insightText!,
              style: DSTypography.bodySm.copyWith(
                color: const Color(0x99000F12),
                height: 1.4,
              ),
            ),
          ],
        ],
      ),
    );
  }
}
