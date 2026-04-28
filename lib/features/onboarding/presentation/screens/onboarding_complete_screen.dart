import 'package:flutter/material.dart';
import 'package:hamsatech_design_system/hamsatech_design_system.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';


import '../../../../core/di/injection.dart';


import '../bloc/onboarding_bloc.dart';
import '../bloc/onboarding_state.dart';

class OnboardingCompleteScreen extends StatelessWidget {
  const OnboardingCompleteScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: getIt<OnboardingBloc>(),
      child: const _OnboardingCompleteView(),
    );
  }
}

class _OnboardingCompleteView extends StatelessWidget {
  const _OnboardingCompleteView();

  String _scoreLabel(double score) {
    if (score >= 70) return 'Strong';
    if (score >= 45) return 'Developing';
    return 'Needs Work';
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<OnboardingBloc, OnboardingState>(
      builder: (context, state) {
        final scores = state.baselineScores;
        final focus = scores['focus'] ?? 0;
        final emotional = scores['emotionalStability'] ?? 0;
        final decision = scores['decisionStyle'] ?? 0;
        final motivation = scores['motivation'] ?? 0;
        final overall =
            focus * 0.30 + emotional * 0.25 + decision * 0.25 + motivation * 0.20;

        return Scaffold(
          body: SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const SizedBox(height: 24),
                  Container(
                    width: 72,
                    height: 72,
                    decoration: BoxDecoration(
                      color: DSColors.success.withValues(alpha: 0.15),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.check_rounded,
                      color: DSColors.success,
                      size: 40,
                    ),
                  ),
                  const SizedBox(height: 20),
                  Text(
                    'Baseline Complete!',
                    style: DSTypography.displayMedium,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Here\'s your mental performance profile, ${state.name}',
                    style: DSTypography.bodyMedium
                        .copyWith(color: DSColors.textSecondary),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 40),
                  DSScoreRing(
                    score: overall,
                    size: 140,
                    label: 'Overall\nReadiness',
                    strokeWidth: 10,
                  ),
                  const SizedBox(height: 36),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      _ScoreItem(
                        label: 'Focus',
                        score: focus,
                        color: DSColors.info,
                      ),
                      _ScoreItem(
                        label: 'Emotional',
                        score: emotional,
                        color: DSColors.success,
                      ),
                      _ScoreItem(
                        label: 'Decision',
                        score: decision,
                        color: DSColors.warning,
                      ),
                      _ScoreItem(
                        label: 'Motivation',
                        score: motivation,
                        color: DSColors.brand,
                      ),
                    ],
                  ),
                  const SizedBox(height: 36),
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: DSColors.appCard,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: DSColors.appBorder),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('What this means',
                            style: DSTypography.headingSmall),
                        const SizedBox(height: 12),
                        _interpretScore('Focus', focus, _scoreLabel(focus)),
                        _interpretScore('Emotional Stability', emotional,
                            _scoreLabel(emotional)),
                        _interpretScore(
                            'Decision Style', decision, _scoreLabel(decision)),
                        _interpretScore(
                            'Motivation', motivation, _scoreLabel(motivation)),
                      ],
                    ),
                  ),
                  const SizedBox(height: 36),
                  DSButton(
                    label: 'Enter My Dashboard',
                    onPressed: () => context.go('/home'),
                    leadingIcon: const Icon(Icons.dashboard_rounded),
                    isFullWidth: true,
                  ),
                  const SizedBox(height: 24),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _interpretScore(String label, double score, String level) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          SizedBox(
            width: 140,
            child: Text(label, style: DSTypography.bodySmall),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: LinearProgressIndicator(
                value: score / 100,
                minHeight: 6,
                backgroundColor: DSColors.appBorder,
                valueColor:
                    AlwaysStoppedAnimation<Color>(_levelColor(level)),
              ),
            ),
          ),
          const SizedBox(width: 8),
          Text(
            level,
            style: DSTypography.caption
                .copyWith(color: _levelColor(level)),
          ),
        ],
      ),
    );
  }

  Color _levelColor(String level) {
    return switch (level) {
      'Strong' => DSColors.success,
      'Developing' => DSColors.warning,
      _ => DSColors.error,
    };
  }
}

class _ScoreItem extends StatelessWidget {
  const _ScoreItem({
    required this.label,
    required this.score,
    required this.color,
  });

  final String label;
  final double score;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        DSScoreRing(score: score, size: 64, strokeWidth: 5, color: color),
        const SizedBox(height: 6),
        Text(label, style: DSTypography.caption),
      ],
    );
  }
}
