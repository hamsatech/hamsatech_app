import 'package:flutter/material.dart';
import 'package:hamsatech_design_system/hamsatech_design_system.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';


import '../../../../core/di/injection.dart';

import '../bloc/onboarding_bloc.dart';
import '../bloc/onboarding_event.dart';
import '../bloc/onboarding_state.dart';

class BaselineAssessmentScreen extends StatelessWidget {
  const BaselineAssessmentScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: getIt<OnboardingBloc>(),
      child: const _AssessmentView(),
    );
  }
}

class _AssessmentView extends StatelessWidget {
  const _AssessmentView();

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<OnboardingBloc, OnboardingState>(
      listener: (context, state) {
        if (state.step == OnboardingStep.complete) {
          context.go('/onboarding/complete');
        } else if (state.status == OnboardingStatus.failure) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.errorMessage ?? 'An error occurred'),
              backgroundColor: DSColors.error,
            ),
          );
        }
      },
      builder: (context, state) {
        if (state.questions.isEmpty) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        final question = state.currentQuestion!;
        final selectedIndex = state.answers[question.id];

        return Scaffold(
          appBar: AppBar(
            leading: IconButton(
              icon: const Icon(Icons.arrow_back_ios_new_rounded),
              onPressed: () {
                if (state.currentQuestionIndex > 0) {
                  context
                      .read<OnboardingBloc>()
                      .add(const OnboardingPreviousQuestion());
                } else {
                  context.pop();
                }
              },
            ),
            title: Text(
              'Question ${state.currentQuestionIndex + 1} of ${state.questions.length}',
              style: DSTypography.labelLarge
                  .copyWith(color: DSColors.textSecondary),
            ),
          ),
          body: SafeArea(
            child: Column(
              children: [
                // Progress bar
                LinearProgressIndicator(
                  value: state.assessmentProgress,
                  backgroundColor: DSColors.appBorder,
                  valueColor:
                      const AlwaysStoppedAnimation<Color>(DSColors.brand),
                  minHeight: 3,
                ),
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 8),
                        _CategoryBadge(category: question.category),
                        const SizedBox(height: 20),
                        Text(
                          question.question,
                          style: DSTypography.headingMedium,
                        ),
                        const SizedBox(height: 28),
                        ...question.options.asMap().entries.map((entry) {
                          final index = entry.key;
                          final option = entry.value;
                          final isSelected = selectedIndex == index;

                          return _OptionCard(
                            text: option.text,
                            isSelected: isSelected,
                            onTap: () {
                              context.read<OnboardingBloc>().add(
                                    OnboardingAnswerSelected(
                                      questionId: question.id,
                                      optionIndex: index,
                                    ),
                                  );
                            },
                          );
                        }),
                        const SizedBox(height: 32),
                      ],
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
                  child: state.isLastQuestion
                      ? DSButton(
                          label: 'Complete Assessment',
                          onPressed: selectedIndex != null
                              ? () => context.read<OnboardingBloc>().add(
                                    const OnboardingAssessmentCompleted(),
                                  )
                              : null,
                          isLoading: state.status == OnboardingStatus.loading,
                          leadingIcon: const Icon(Icons.check_rounded),
                          isFullWidth: true,
                        )
                      : DSButton(
                          label: 'Next Question',
                          onPressed: selectedIndex != null
                              ? () => context
                                  .read<OnboardingBloc>()
                                  .add(const OnboardingNextQuestion())
                              : null,
                          leadingIcon: const Icon(Icons.arrow_forward_rounded),
                          isFullWidth: true,
                        ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _CategoryBadge extends StatelessWidget {
  const _CategoryBadge({required this.category});

  final String category;

  static const _labels = {
    'focus': ('FOCUS', DSColors.info),
    'emotional_stability': ('EMOTIONAL STABILITY', DSColors.success),
    'decision_style': ('DECISION STYLE', DSColors.warning),
    'motivation': ('MOTIVATION', DSColors.brand),
  };

  @override
  Widget build(BuildContext context) {
    final (label, color) = _labels[category] ??
        ('ASSESSMENT', DSColors.textSecondary);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: color.withValues(alpha: 0.4)),
      ),
      child: Text(
        label,
        style: DSTypography.caption.copyWith(
          color: color,
          fontWeight: FontWeight.w700,
          letterSpacing: 1,
        ),
      ),
    );
  }
}

class _OptionCard extends StatelessWidget {
  const _OptionCard({
    required this.text,
    required this.isSelected,
    required this.onTap,
  });

  final String text;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isSelected
              ? DSColors.brand.withValues(alpha: 0.12)
              : DSColors.appCard,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? DSColors.brand : DSColors.appBorder,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Row(
          children: [
            AnimatedContainer(
              duration: const Duration(milliseconds: 150),
              width: 20,
              height: 20,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color:
                    isSelected ? DSColors.brand : Colors.transparent,
                border: Border.all(
                  color: isSelected
                      ? DSColors.brand
                      : DSColors.textMuted,
                  width: 2,
                ),
              ),
              child: isSelected
                  ? const Icon(Icons.check_rounded,
                      size: 12, color: Colors.white)
                  : null,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                text,
                style: DSTypography.bodyMedium.copyWith(
                  color: isSelected
                      ? DSColors.textPrimary
                      : DSColors.textSecondary,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
