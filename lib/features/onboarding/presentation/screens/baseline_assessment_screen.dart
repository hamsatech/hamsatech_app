import 'package:flutter/material.dart';
import 'package:hamsatech_design_system/hamsatech_design_system.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/di/injection.dart';
import '../../../../core/services/storage_service.dart';
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
          StorageService.setOnboardingComplete(true);
          context.go('/home');
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
            backgroundColor: Colors.white,
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
          backgroundColor: Colors.white,
          body: SafeArea(
            child: Column(
              children: [
                // ── Header ──────────────────────────────────────────────
                Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                  child: Row(
                    children: [
                      Text(
                        'Questions',
                        style: DSTypography.bodyMd.copyWith(
                          color: const Color(0xFF6B7280),
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                      const Spacer(),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                              color: const Color(0xFFD1D5DB), width: 1),
                        ),
                        child: Text(
                          '$current/$total',
                          style: DSTypography.bodySm.copyWith(
                            color: const Color(0xFF374151),
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                // ── Progress bar ────────────────────────────────────────
                LinearProgressIndicator(
                  value: state.assessmentProgress,
                  backgroundColor: const Color(0xFFE4E4E7),
                  valueColor: const AlwaysStoppedAnimation<Color>(
                      DSColors.terracotta),
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
                          style: DSTypography.onboardingCaption.copyWith(
                            color: const Color(0xFF0D1F2D),
                            fontWeight: FontWeight.w700,
                            height: 1.35,
                          ),
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

                        const SizedBox(height: 28),

                        // Explain your answer
                        Text(
                          'Explain your answer',
                          style: DSTypography.labelMd.copyWith(
                            color: DSColors.terracotta,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 10),
                        TextField(
                          controller: _explainController,
                          maxLines: 4,
                          style: DSTypography.bodyMd.copyWith(
                            color: const Color(0xFF0D1F2D),
                          ),
                          decoration: InputDecoration(
                            hintText: 'Write your message here...',
                            hintStyle: DSTypography.bodyMd.copyWith(
                              color: const Color(0xFF9CA3AF),
                            ),
                            filled: true,
                            fillColor: Colors.white,
                            contentPadding: const EdgeInsets.all(14),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                              borderSide: BorderSide(
                                  color: DSColors.terracotta.withValues(alpha: 0.3),
                                  width: 1),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                              borderSide: BorderSide(
                                  color: DSColors.terracotta, width: 1),
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),
                      ],
                    ),
                  ),
                ),

                // ── Bottom navigation ───────────────────────────────────
                const Divider(height: 1, color: Color(0xFFE4E4E7)),
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 12, 20, 12),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      GestureDetector(
                        onTap: () {
                          if (state.currentQuestionIndex > 0) {
                            context
                                .read<OnboardingBloc>()
                                .add(const OnboardingPreviousQuestion());
                          } else {
                            context.pop();
                          }
                        },
                        child: SizedBox(
                          width: 64,
                          child: Text(
                            'Back',
                            textAlign: TextAlign.center,
                            style: DSTypography.labelMd.copyWith(
                              color: DSColors.terracotta,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: AnimatedOpacity(
                          duration: const Duration(milliseconds: 200),
                          opacity: selectedIndex != null ? 1.0 : 0.45,
                          child: state.isLastQuestion
                              ? DSPrimaryButton(
                                  label: 'Complete',
                                  color: DSColors.terracotta,
                                  isLoading:
                                      state.status == OnboardingStatus.loading,
                                  onPressed: selectedIndex != null
                                      ? () => context
                                          .read<OnboardingBloc>()
                                          .add(const OnboardingAssessmentCompleted())
                                      : () {},
                                  textStyle: DSTypography.labelMd.copyWith(
                                    color: Colors.white,
                                    fontWeight: FontWeight.w600,
                                  ),
                                )
                              : DSPrimaryButton(
                                  label: 'Next',
                                  color: DSColors.terracotta,
                                  onPressed: selectedIndex != null
                                      ? () => context
                                          .read<OnboardingBloc>()
                                          .add(const OnboardingNextQuestion())
                                      : () {},
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
    return Column(
      children: [
        InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(4),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 14),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    text,
                    style: DSTypography.bodyMd.copyWith(
                      color: isSelected
                          ? const Color(0xFF0D1F2D)
                          : const Color(0xFF6B7280),
                      fontWeight: isSelected
                          ? FontWeight.w500
                          : FontWeight.w400,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                AnimatedContainer(
                  duration: const Duration(milliseconds: 150),
                  width: 24,
                  height: 24,
                  decoration: BoxDecoration(
                    color: isSelected
                        ? DSColors.terracotta
                        : Colors.transparent,
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(
                      color: isSelected
                          ? DSColors.terracotta
                          : const Color(0xFFD1D5DB),
                      width: 1.5,
                    ),
                  ),
                  child: isSelected
                      ? const Icon(Icons.check_rounded,
                          size: 15, color: Colors.white)
                      : null,
                ),
              ],
            ),
          ),
        ),
        const Divider(height: 1, color: Color(0xFFF3F4F6)),
      ],
    );
  }
}
