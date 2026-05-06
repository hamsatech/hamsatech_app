import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../bloc/onboarding_step3_bloc.dart';
import '../bloc/onboarding_step3_event.dart';
import '../bloc/onboarding_step3_state.dart';
import '../bloc/performance_factor_model.dart';

class OnboardingStep3Screen extends StatelessWidget {
  const OnboardingStep3Screen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => OnboardingStep3Bloc(),
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

  @override
  void initState() {
    super.initState();
    _avgScoreController = TextEditingController();
    _targetScoreController = TextEditingController();
  }

  @override
  void dispose() {
    _avgScoreController.dispose();
    _targetScoreController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<OnboardingStep3Bloc, OnboardingStep3State>(
      listenWhen: (previous, current) =>
          previous.submissionSuccess != current.submissionSuccess ||
          previous.errorMessage != current.errorMessage ||
          previous.avgScore != current.avgScore ||
          previous.targetScore != current.targetScore,
      listener: (context, state) {
        if (_avgScoreController.text != state.avgScore) {
          _avgScoreController.text = state.avgScore;
        }
        if (_targetScoreController.text != state.targetScore) {
          _targetScoreController.text = state.targetScore;
        }
        if (state.submissionSuccess) {
          context.go('/onboarding/step4');
        } else if (state.errorMessage != null) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(state.errorMessage!)),
          );
        }
      },
      builder: (context, state) {
        final bloc = context.read<OnboardingStep3Bloc>();

        return Scaffold(
          backgroundColor: Colors.white,

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
                              onPressed: () => Navigator.of(context).pop(),
                            ),
                          ),
                          Expanded(
                            child: Center(
                              child: Text(
                                state.stepTitle,
                                style: const TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w700,
                                  color: Color(0xFF8E8E8E),
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
                              color: const Color(0xFFE6E6E6),
                            ),
                            AnimatedContainer(
                              duration: const Duration(milliseconds: 300),
                              curve: Curves.easeInOut,
                              width: constraints.maxWidth *
                                  state.progress.clamp(0.0, 1.0),
                              height: 3,
                              color: const Color(0xFFE53935),
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
                    color: Color(0xFF1A1A1A),
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
                    color: Color(0xFF6E6E6E),
                    height: 1.5,
                  ),
                ),
                const SizedBox(height: 32),

                // ── Average Practice Score ─────────────────────────────────
                _fieldLabel(state.avgScoreLabel),
                const SizedBox(height: 8),
                _scoreInput(
                  controller: _avgScoreController,
                  hint: state.avgScoreHint,
                  onChanged: (v) => bloc.add(OnAvgScoreChanged(v)),
                ),
                const SizedBox(height: 20),

                // ── Target Score ───────────────────────────────────────────
                _fieldLabel(state.targetScoreLabel),
                const SizedBox(height: 8),
                _scoreInput(
                  controller: _targetScoreController,
                  hint: state.targetScoreHint,
                  onChanged: (v) => bloc.add(OnTargetScoreChanged(v)),
                ),
                const SizedBox(height: 28),

                // ── Performance Factors ────────────────────────────────────
                Text(
                  state.factorTitle,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF1A1A1A),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  state.factorSubtitle,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w400,
                    color: Color(0xFF6E6E6E),
                    height: 1.4,
                  ),
                ),
                const SizedBox(height: 14),

                // ── Factor options ─────────────────────────────────────────
                ...state.factorOptions.map((factor) {
                  final isSelected =
                      state.selectedFactors.contains(factor.id);
                  final atLimit =
                      state.selectedFactors.length >= state.maxFactorSelection;

                  return Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: _factorTile(
                      factor: factor,
                      isSelected: isSelected,
                      dimmed: atLimit && !isSelected,
                      onTap: () => bloc.add(OnFactorToggled(factor.id)),
                    ),
                  );
                }),

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
                  onPressed: () => bloc.add(const OnStep3Submit()),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFE53935),
                    disabledBackgroundColor: const Color(0xFFE53935),
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
    );
  }

  // ── Field Label ─────────────────────────────────────────────────────────
  Widget _fieldLabel(String label) {
    return Text(
      label,
      style: const TextStyle(
        fontSize: 13,
        fontWeight: FontWeight.w500,
        color: Color(0xFF4A4A4A),
      ),
    );
  }

  // ── Score Input ──────────────────────────────────────────────────────────
  Widget _scoreInput({
    required TextEditingController controller,
    required String hint,
    required ValueChanged<String> onChanged,
  }) {
    return TextField(
      controller: controller,
      keyboardType: TextInputType.number,
      onChanged: onChanged,
      style: const TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w400,
        color: Color(0xFF1A1A1A),
      ),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w400,
          color: Color(0xFFA0A0A0),
        ),
        filled: true,
        fillColor: Colors.white,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 14,
          vertical: 13,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: Color(0xFFE0E0E0), width: 1),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: Color(0xFFE53935), width: 1.5),
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: Color(0xFFE0E0E0), width: 1),
        ),
      ),
    );
  }

  // ── Factor Tile ──────────────────────────────────────────────────────────
  Widget _factorTile({
    required PerformanceFactorModel factor,
    required bool isSelected,
    required bool dimmed,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: isSelected
                ? const Color(0xFFE53935)
                : const Color(0xFFE0E0E0),
            width: isSelected ? 1.5 : 1,
          ),
        ),
        child: Row(
          children: [
            // Checkbox
            AnimatedContainer(
              duration: const Duration(milliseconds: 150),
              width: 20,
              height: 20,
              decoration: BoxDecoration(
                color: isSelected
                    ? const Color(0xFFE53935)
                    : Colors.white,
                borderRadius: BorderRadius.circular(4),
                border: Border.all(
                  color: isSelected
                      ? const Color(0xFFE53935)
                      : dimmed
                          ? const Color(0xFFDDDDDD)
                          : const Color(0xFFBBBBBB),
                  width: 1.5,
                ),
              ),
              child: isSelected
                  ? const Icon(Icons.check_rounded, size: 13, color: Colors.white)
                  : null,
            ),
            const SizedBox(width: 12),

            // Label
            Expanded(
              child: Text(
                factor.label,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w400,
                  color: dimmed
                      ? const Color(0xFFAAAAAA)
                      : const Color(0xFF2A2A2A),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
