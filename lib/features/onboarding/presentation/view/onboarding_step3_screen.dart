import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../bloc/onboarding_step3_bloc.dart';
import '../bloc/onboarding_step3_event.dart';
import '../bloc/onboarding_step3_state.dart';
import '../bloc/onboarding_step4_bloc.dart';
import '../bloc/onboarding_step4_event.dart';
import '../bloc/onboarding_step4_state.dart';
import '../bloc/performance_factor_model.dart';

class OnboardingStep3Screen extends StatelessWidget {
  const OnboardingStep3Screen({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (_) => OnboardingStep3Bloc()),
        // Goals Bloc/API/events reused unchanged — only its UI now renders
        // inside the Step 3 screen instead of its own separate screen.
        BlocProvider(create: (_) => OnboardingStep4Bloc()),
      ],
      child: const _OnboardingStep3View(),
    );
  }
}

class _OnboardingStep3View extends StatefulWidget {
  const _OnboardingStep3View();

  @override
  State<_OnboardingStep3View> createState() => _OnboardingStep3ViewState();
}

class _OnboardingStep3ViewState extends State<_OnboardingStep3View> {
  late final TextEditingController _avgScoreController;
  late final TextEditingController _targetScoreController;
  late final TextEditingController _goal30Controller;
  late final TextEditingController _goal6MonthController;

  @override
  void initState() {
    super.initState();
    _avgScoreController = TextEditingController();
    _targetScoreController = TextEditingController();
    _goal30Controller = TextEditingController();
    _goal6MonthController = TextEditingController();
  }

  @override
  void dispose() {
    _avgScoreController.dispose();
    _targetScoreController.dispose();
    _goal30Controller.dispose();
    _goal6MonthController.dispose();
    super.dispose();
  }

  void _onBothSubmitted(BuildContext context) {
    final step3Done = context.read<OnboardingStep3Bloc>().state.submissionSuccess;
    final step4Done = context.read<OnboardingStep4Bloc>().state.submissionSuccess;
    if (step3Done && step4Done) {
      context.go('/onboarding/step4');
    }
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocListener(
      listeners: [
        BlocListener<OnboardingStep3Bloc, OnboardingStep3State>(
          listenWhen: (previous, current) =>
              previous.avgScore != current.avgScore ||
              previous.targetScore != current.targetScore ||
              previous.submissionSuccess != current.submissionSuccess,
          listener: (context, state) {
            if (_avgScoreController.text != state.avgScore) {
              _avgScoreController.text = state.avgScore;
            }
            if (_targetScoreController.text != state.targetScore) {
              _targetScoreController.text = state.targetScore;
            }
            if (state.submissionSuccess) _onBothSubmitted(context);
          },
        ),
        BlocListener<OnboardingStep4Bloc, OnboardingStep4State>(
          listenWhen: (previous, current) =>
              previous.goal30Value != current.goal30Value ||
              previous.goal6MonthValue != current.goal6MonthValue ||
              previous.submissionSuccess != current.submissionSuccess,
          listener: (context, state) {
            if (_goal30Controller.text != state.goal30Value) {
              _goal30Controller.text = state.goal30Value;
            }
            if (_goal6MonthController.text != state.goal6MonthValue) {
              _goal6MonthController.text = state.goal6MonthValue;
            }
            if (state.submissionSuccess) _onBothSubmitted(context);
          },
        ),
      ],
      child: Builder(
        builder: (context) {
          final state = context.watch<OnboardingStep3Bloc>().state;
          final goalsState = context.watch<OnboardingStep4Bloc>().state;
          final bloc = context.read<OnboardingStep3Bloc>();
          final goalsBloc = context.read<OnboardingStep4Bloc>();
          final canContinue = state.isValid && goalsState.isValid;

          return Scaffold(
            backgroundColor: const Color(0xFFF5FDFF),

            // ── AppBar + Progress Bar ────────────────────────────────────────
            appBar: PreferredSize(
              preferredSize: const Size.fromHeight(60),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    color: Colors.white,
                    child: SafeArea(
                      bottom: false,
                      child: SizedBox(
                        height: 52,
                        child: Row(
                          children: [
                            Padding(
                              padding: const EdgeInsets.only(left: 8),
                              child: IconButton(
                                padding: EdgeInsets.zero,
                                constraints: const BoxConstraints(
                                  minWidth: 40,
                                  minHeight: 40,
                                ),
                                icon: const Icon(
                                  Icons.arrow_back_ios_new_rounded,
                                  color: Colors.black,
                                  size: 20,
                                ),
                                onPressed: () =>
                                    context.go('/onboarding/step2'),
                              ),
                            ),
                            Expanded(
                              child: Center(
                                child: Text(
                                  state.stepTitle,
                                  style: const TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w700,
                                    color: Color(0x99000F12),
                                    letterSpacing: 0.5,
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 56),
                          ],
                        ),
                      ),
                    ),
                  ),

                  // ── Progress Bar ───────────────────────────────────────────
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(2),
                      child: LayoutBuilder(
                        builder: (context, constraints) {
                          return Stack(
                            children: [
                              Container(
                                width: double.infinity,
                                height: 3,
                                color: const Color(0xFFCAE8EE),
                              ),
                              AnimatedContainer(
                                duration: const Duration(milliseconds: 300),
                                curve: Curves.easeInOut,
                                width: constraints.maxWidth *
                                    state.progress.clamp(0.0, 1.0),
                                height: 3,
                                color: const Color(0xFF2F7E8F),
                              ),
                            ],
                          );
                        },
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // ── Body ──────────────────────────────────────────────────────────
            body: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(16, 28, 16, 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ── Title ──────────────────────────────────────────────────
                  Text(
                    state.title,
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF000F12),
                      height: 1.3,
                    ),
                  ),
                  const SizedBox(height: 8),

                  // ── Subtitle ───────────────────────────────────────────────
                  Text(
                    state.subtitle,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w400,
                      color: Color(0x99000F12),
                      height: 1.5,
                    ),
                  ),
                  const SizedBox(height: 32),

                  // ── Avg Practice Score + Target Score (side by side) ────────
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _fieldLabel(state.avgScoreLabel),
                            const SizedBox(height: 8),
                            _scoreInput(
                              controller: _avgScoreController,
                              hint: state.avgScoreHint,
                              isInvalid: _isAvgScoreInvalid(state),
                              onChanged: (v) =>
                                  bloc.add(OnAvgScoreChanged(v)),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _fieldLabel(state.targetScoreLabel),
                            const SizedBox(height: 8),
                            _scoreInput(
                              controller: _targetScoreController,
                              hint: state.targetScoreHint,
                              isInvalid: _isTargetScoreInvalid(state),
                              onChanged: (v) =>
                                  bloc.add(OnTargetScoreChanged(v)),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 28),

                  // ── Performance Factors ────────────────────────────────────
                  Text(
                    state.factorTitle,
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF000F12),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    state.factorSubtitle,
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w400,
                      color: Color(0x99000F12),
                      height: 1.4,
                    ),
                  ),
                  const SizedBox(height: 14),

                  // ── Factor options ─────────────────────────────────────────
                  Wrap(
                    spacing: 16,
                    runSpacing: 12,
                    children: state.factorOptions.map((factor) {
                      final isSelected =
                          state.selectedFactors.contains(factor.id);
                      final atLimit = state.selectedFactors.length >=
                          state.maxFactorSelection;

                      return _factorChip(
                        factor: factor,
                        isSelected: isSelected,
                        dimmed: atLimit && !isSelected,
                        onTap: () => bloc.add(OnFactorToggled(factor.id)),
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 28),

                  // ── 30-Day Goal (reuses OnboardingStep4Bloc, unchanged) ─────
                  _goalLabelRow(
                    label: goalsState.goal30Label,
                    tag: goalsState.goal30Tag,
                  ),
                  const SizedBox(height: 8),
                  _goalTextArea(
                    controller: _goal30Controller,
                    hint: goalsState.goal30Hint,
                    isInvalid: _areGoalsInvalid(goalsState),
                    onChanged: (v) => goalsBloc.add(OnGoal30Changed(v)),
                  ),
                  const SizedBox(height: 24),

                  // ── 6-Month Goal (reuses OnboardingStep4Bloc, unchanged) ────
                  _goalLabelRow(
                    label: goalsState.goal6MonthLabel,
                    tag: goalsState.goal6MonthTag,
                  ),
                  const SizedBox(height: 8),
                  _goalTextArea(
                    controller: _goal6MonthController,
                    hint: goalsState.goal6MonthHint,
                    isInvalid: _areGoalsInvalid(goalsState),
                    onChanged: (v) => goalsBloc.add(OnGoal6MonthChanged(v)),
                  ),

                  const SizedBox(height: 16),
                ],
              ),
            ),

            // ── CTA Button ────────────────────────────────────────────────────
            bottomNavigationBar: SafeArea(
              minimum: const EdgeInsets.only(bottom: 16),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: SizedBox(
                  height: 52,
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: canContinue
                        ? () {
                            bloc.add(const OnStep3Submit());
                            goalsBloc.add(const OnStep4Submit());
                          }
                        : null,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF2F7E8F),
                      disabledBackgroundColor:
                          const Color(0xFF2F7E8F).withValues(alpha: 0.45),
                      disabledForegroundColor:
                          Colors.white.withValues(alpha: 0.85),
                      foregroundColor: Colors.white,
                      shadowColor: Colors.transparent,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    child: Text(
                      state.ctaLabel,
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  bool _isAvgScoreInvalid(OnboardingStep3State state) {
    return state.errorMessage == 'Please enter your average practice score';
  }

  bool _isTargetScoreInvalid(OnboardingStep3State state) {
    return state.errorMessage == 'Please enter your target score';
  }

  bool _areGoalsInvalid(OnboardingStep4State state) {
    return state.errorMessage == 'Please fill in at least one goal to continue';
  }

  // ── Field Label ─────────────────────────────────────────────────────────
  Widget _fieldLabel(String label) {
    return Text(
      label,
      style: const TextStyle(
        fontSize: 13,
        fontWeight: FontWeight.w500,
        color: Color(0x99000F12),
      ),
    );
  }

  // ── Score Input ──────────────────────────────────────────────────────────
  Widget _scoreInput({
    required TextEditingController controller,
    required String hint,
    required bool isInvalid,
    required ValueChanged<String> onChanged,
  }) {
    final borderColor =
        isInvalid ? const Color(0xFF2F7E8F) : const Color(0xFFCAE8EE);

    return TextField(
      controller: controller,
      keyboardType: TextInputType.number,
      onChanged: onChanged,
      style: const TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w400,
        color: Color(0xFF000F12),
      ),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w400,
          color: Color(0x66000F12),
        ),
        filled: true,
        fillColor: Colors.white,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 14,
          vertical: 13,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: borderColor, width: 1),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: Color(0xFF2F7E8F), width: 1.5),
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: borderColor, width: 1),
        ),
      ),
    );
  }

  // ── Factor Chip ──────────────────────────────────────────────────────────
  Widget _factorChip({
    required PerformanceFactorModel factor,
    required bool isSelected,
    required bool dimmed,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Checkbox
          AnimatedContainer(
            duration: const Duration(milliseconds: 150),
            width: 20,
            height: 20,
            decoration: BoxDecoration(
              color: isSelected ? const Color(0xFF2F7E8F) : Colors.white,
              borderRadius: BorderRadius.circular(4),
              border: Border.all(
                color: isSelected
                    ? const Color(0xFF2F7E8F)
                    : dimmed
                        ? const Color(0xFFCAE8EE)
                        : const Color(0xFF7FB8C4),
                width: 1.5,
              ),
            ),
            child: isSelected
                ? const Icon(Icons.check_rounded,
                    size: 13, color: Colors.white)
                : null,
          ),
          const SizedBox(width: 8),

          // Label
          Text(
            factor.label,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w400,
              color:
                  dimmed ? const Color(0xFF7FB8C4) : const Color(0xFF000F12),
            ),
          ),
        ],
      ),
    );
  }

  // ── Goal label row: bold label left + pill tag right ────────────────────
  Widget _goalLabelRow({required String label, required String tag}) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w600,
            color: Color(0xFF000F12),
          ),
        ),
        const Spacer(),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
          decoration: BoxDecoration(
            border: Border.all(color: const Color(0xFFCAE8EE), width: 1),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Text(
            tag,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w400,
              color: Color(0x99000F12),
            ),
          ),
        ),
      ],
    );
  }

  // ── Multiline goal textarea with mic icon ───────────────────────────────
  Widget _goalTextArea({
    required TextEditingController controller,
    required String hint,
    required bool isInvalid,
    required ValueChanged<String> onChanged,
  }) {
    final borderColor =
        isInvalid ? const Color(0xFF2F7E8F) : const Color(0xFFCAE8EE);

    return Stack(
      children: [
        TextField(
          controller: controller,
          onChanged: onChanged,
          maxLines: 4,
          minLines: 4,
          keyboardType: TextInputType.multiline,
          textInputAction: TextInputAction.newline,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w400,
            color: Color(0xFF000F12),
            height: 1.5,
          ),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w400,
              color: Color(0x66000F12),
              height: 1.5,
            ),
            filled: true,
            fillColor: Colors.white,
            contentPadding: const EdgeInsets.fromLTRB(14, 14, 40, 14),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: borderColor, width: 1),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide:
                  const BorderSide(color: Color(0xFF2F7E8F), width: 1.5),
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: borderColor, width: 1),
            ),
          ),
        ),
        const Positioned(
          right: 12,
          bottom: 12,
          child: Icon(
            Icons.mic_none_rounded,
            size: 18,
            color: Color(0x66000F12),
          ),
        ),
      ],
    );
  }
}
