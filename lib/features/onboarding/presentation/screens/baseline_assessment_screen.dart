import 'package:flutter/material.dart';
import 'package:hamsatech_design_system/hamsatech_design_system.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/di/injection.dart';
import '../../../../core/widgets/app_button.dart';
import '../bloc/onboarding_bloc.dart';
import '../bloc/onboarding_event.dart';
import '../bloc/onboarding_state.dart';

class BaselineAssessmentScreen extends StatelessWidget {
  const BaselineAssessmentScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: getIt<OnboardingBloc>()..add(const OnboardingAssessmentStarted()),
      child: const _AssessmentView(),
    );
  }
}

class _AssessmentView extends StatefulWidget {
  const _AssessmentView();

  @override
  State<_AssessmentView> createState() => _AssessmentViewState();
}

class _AssessmentViewState extends State<_AssessmentView> {
  final _explainController = TextEditingController();
  int? _lastQuestionId;

  @override
  void dispose() {
    _explainController.dispose();
    super.dispose();
  }

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
        final total = state.questions.length;
        final current = state.currentQuestionIndex + 1;

        // Reset explanation field when question changes
        if (_lastQuestionId != question.id) {
          _lastQuestionId = question.id;
          WidgetsBinding.instance.addPostFrameCallback(
            (_) => _explainController.clear(),
          );
        }

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
              style: AppTextStyles.labelLarge
                  .copyWith(color: AppColors.textSecondary),
            ),
          ),
          body: SafeArea(
            child: Column(
              children: [
                // Progress bar
                LinearProgressIndicator(
                  value: state.assessmentProgress,
                  backgroundColor: AppColors.border,
                  valueColor:
                      const AlwaysStoppedAnimation<Color>(AppColors.primary),
                  minHeight: 3,
                ),

                // ── Scrollable content ──────────────────────────────────
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.fromLTRB(20, 24, 20, 16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Question text
                        Text(
                          question.question,
                          style: AppTextStyles.headingMedium,
                        ),
                        const SizedBox(height: 24),

                        // Options
                        ...question.options.asMap().entries.map((entry) {
                          final idx = entry.key;
                          final opt = entry.value;
                          final isSelected = selectedIndex == idx;
                          return _OptionRow(
                            text: opt.text,
                            isSelected: isSelected,
                            onTap: () => context.read<OnboardingBloc>().add(
                                  OnboardingAnswerSelected(
                                    questionId: question.id,
                                    optionIndex: idx,
                                  ),
                                ),
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
                      ? AppButton(
                          label: 'Complete Assessment',
                          onPressed: selectedIndex != null
                              ? () => context.read<OnboardingBloc>().add(
                                    const OnboardingAssessmentCompleted(),
                                  )
                              : null,
                          isLoading: state.status == OnboardingStatus.loading,
                          icon: Icons.check_rounded,
                        )
                      : AppButton(
                          label: 'Next Question',
                          onPressed: selectedIndex != null
                              ? () => context
                                  .read<OnboardingBloc>()
                                  .add(const OnboardingNextQuestion())
                              : null,
                          icon: Icons.arrow_forward_rounded,
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

// ── Option row ────────────────────────────────────────────────────────────────

class _OptionRow extends StatelessWidget {
  const _OptionRow({
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
              ? AppColors.primary.withValues(alpha: 0.12)
              : AppColors.card,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? AppColors.primary : AppColors.border,
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
                    isSelected ? AppColors.primary : Colors.transparent,
                border: Border.all(
                  color: isSelected
                      ? AppColors.primary
                      : AppColors.textMuted,
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
                style: AppTextStyles.bodyMedium.copyWith(
                  color: isSelected
                      ? AppColors.textPrimary
                      : AppColors.textSecondary,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
