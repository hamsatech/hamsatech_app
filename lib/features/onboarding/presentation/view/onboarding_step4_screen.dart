import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../bloc/onboarding_step4_bloc.dart';
import '../bloc/onboarding_step4_event.dart';
import '../bloc/onboarding_step4_state.dart';

class OnboardingStep4Screen extends StatelessWidget {
  const OnboardingStep4Screen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => OnboardingStep4Bloc(),
      child: const _OnboardingStep4View(),
    );
  }
}

class _OnboardingStep4View extends StatefulWidget {
  const _OnboardingStep4View();

  @override
  State<_OnboardingStep4View> createState() => _OnboardingStep4ViewState();
}

class _OnboardingStep4ViewState extends State<_OnboardingStep4View> {
  late final TextEditingController _goal30Controller;
  late final TextEditingController _goal6MonthController;

  @override
  void initState() {
    super.initState();
    _goal30Controller = TextEditingController();
    _goal6MonthController = TextEditingController();
  }

  @override
  void dispose() {
    _goal30Controller.dispose();
    _goal6MonthController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<OnboardingStep4Bloc, OnboardingStep4State>(
      listenWhen: (previous, current) =>
          previous.submissionSuccess != current.submissionSuccess ||
          previous.errorMessage != current.errorMessage ||
          previous.goal30Value != current.goal30Value ||
          previous.goal6MonthValue != current.goal6MonthValue,
      listener: (context, state) {
        if (_goal30Controller.text != state.goal30Value) {
          _goal30Controller.text = state.goal30Value;
        }
        if (_goal6MonthController.text != state.goal6MonthValue) {
          _goal6MonthController.text = state.goal6MonthValue;
        }
        if (state.submissionSuccess) {
          context.go('/questions');
        }
      },
      builder: (context, state) {
        final bloc = context.read<OnboardingStep4Bloc>();

        return Scaffold(
          backgroundColor: const Color(0xFFF5FDFF),

          // ── AppBar + Progress Bar ──────────────────────────────────────
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
                              onPressed: () => context.go('/onboarding/step3'),
                            ),
                          ),
                          Expanded(
                            child: Center(
                              child: Text(
                                state.stepTitle,
                                style: const TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w700,
                                  color: const Color(0x99000F12),
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

                // ── Progress Bar ─────────────────────────────────────────
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

          // ── Body ──────────────────────────────────────────────────────
          body: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(16, 28, 16, 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ── Title ────────────────────────────────────────────────
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

                // ── Subtitle ─────────────────────────────────────────────
                Text(
                  state.subtitle,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w400,
                    color: const Color(0x99000F12),
                    height: 1.5,
                  ),
                ),
                const SizedBox(height: 32),

                // ── 30-day goal ───────────────────────────────────────────
                _goalLabelRow(
                  label: state.goal30Label,
                  tag: state.goal30Tag,
                ),
                const SizedBox(height: 8),
                _goalTextArea(
                  controller: _goal30Controller,
                  hint: state.goal30Hint,
                  isInvalid: _areGoalsInvalid(state),
                  onChanged: (v) => bloc.add(OnGoal30Changed(v)),
                ),
                const SizedBox(height: 24),

                // ── 6-month goal ──────────────────────────────────────────
                _goalLabelRow(
                  label: state.goal6MonthLabel,
                  tag: state.goal6MonthTag,
                ),
                const SizedBox(height: 8),
                _goalTextArea(
                  controller: _goal6MonthController,
                  hint: state.goal6MonthHint,
                  isInvalid: _areGoalsInvalid(state),
                  onChanged: (v) => bloc.add(OnGoal6MonthChanged(v)),
                ),
                const SizedBox(height: 24),

                // ── Tip box ───────────────────────────────────────────────
                _tipBox(state.tipText),

                const SizedBox(height: 16),
              ],
            ),
          ),

          // ── Fixed Bottom CTA ───────────────────────────────────────────
          bottomNavigationBar: SafeArea(
            minimum: const EdgeInsets.only(bottom: 12),
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  SizedBox(
                    height: 52,
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: state.isValid
                          ? () => bloc.add(const OnStep4Submit())
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
                        state.ctaText,
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    state.helperText,
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w400,
                      color: const Color(0x99000F12),
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 4),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  bool _areGoalsInvalid(OnboardingStep4State state) {
    return state.errorMessage == 'Please fill in at least one goal to continue';
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
              color: const Color(0x99000F12),
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
          maxLines: 5,
          minLines: 5,
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
              color: const Color(0x66000F12),
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

        // Mic icon — bottom-right corner
        const Positioned(
          right: 12,
          bottom: 12,
          child: Icon(
            Icons.mic_none_rounded,
            size: 18,
            color: const Color(0x66000F12),
          ),
        ),
      ],
    );
  }

  // ── Tip box ─────────────────────────────────────────────────────────────
  Widget _tipBox(String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
      decoration: BoxDecoration(
        color: const Color(0xFFE2F4F7),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('💡', style: TextStyle(fontSize: 16)),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w400,
                color: Color(0xFF2F7E8F),
                height: 1.5,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
