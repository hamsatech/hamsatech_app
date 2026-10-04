import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../bloc/onboarding_step2_bloc.dart';
import '../bloc/onboarding_step2_event.dart';
import '../bloc/onboarding_step2_state.dart';

class OnboardingStep2Screen extends StatelessWidget {
  const OnboardingStep2Screen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => OnboardingStep2Bloc(),
      child: const _OnboardingStep2View(),
    );
  }
}

class _OnboardingStep2View extends StatefulWidget {
  const _OnboardingStep2View();

  @override
  State<_OnboardingStep2View> createState() => _OnboardingStep2ViewState();
}

class _OnboardingStep2ViewState extends State<_OnboardingStep2View> {
  @override
  void initState() {
    super.initState();
    context.read<OnboardingStep2Bloc>().add(const OnLoadAcademies());
    context.read<OnboardingStep2Bloc>().add(const OnLoadOnboarding());
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<OnboardingStep2Bloc, OnboardingStep2State>(
      listenWhen: (previous, current) =>
          previous.submissionSuccess != current.submissionSuccess ||
          previous.errorMessage != current.errorMessage,
      listener: (context, state) {
        if (state.submissionSuccess) {
          context.go('/onboarding/step3');
        }
      },
      builder: (context, state) {
        final bloc = context.read<OnboardingStep2Bloc>();

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
                              onPressed: () => context.go('/onboarding/step1'),
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

                // ── Progress Bar ─────────────────────────────────────
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

          // ── Body ────────────────────────────────────────────────────────
          body: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(16, 28, 16, 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ── Heading ─────────────────────────────────────────────
                Text(
                  state.heading,
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF000F12),
                    height: 1.3,
                  ),
                ),
                const SizedBox(height: 8),

                // ── Subtitle ────────────────────────────────────────────
                Text(
                  state.subtitle,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w400,
                    color: const Color(0x99000F12),
                    height: 1.5,
                  ),
                ),
                const SizedBox(height: 24),

                // ── Discipline ──────────────────────────────────────────
                _fieldLabel(state.disciplineLabel),
                const SizedBox(height: 8),
                _disciplineDropdown(
                  context: context,
                  state: state,
                  bloc: bloc,
                  isInvalid: _isDisciplineInvalid(state),
                ),
                const SizedBox(height: 6),
                Text(
                  state.disciplineHelperText,
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w400,
                    color: const Color(0x66000F12),
                  ),
                ),
                const SizedBox(height: 20),

                // ── Experience Level ────────────────────────────────────
                _fieldLabel(state.experienceLabel),
                const SizedBox(height: 8),
                _experienceDropdown(
                  context: context,
                  state: state,
                  bloc: bloc,
                  isInvalid: _isExperienceInvalid(state),
                ),
                const SizedBox(height: 20),

                // ── Years Shooting ──────────────────────────────────────
                _fieldLabel(state.yearsLabel),
                const SizedBox(height: 10),
                _yearsStepper(
                  value: state.yearsShoot,
                  onDecrement: () => bloc.add(const OnYearsDecrement()),
                  onIncrement: () => bloc.add(const OnYearsIncrement()),
                ),
                const SizedBox(height: 20),

                // ── Academy / Club ──────────────────────────────────────
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text(
                      state.academyLabel,
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                        color: const Color(0x99000F12),
                      ),
                    ),
                    const Spacer(),
                    Text(
                      state.academyOptionalText,
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w400,
                        color: const Color(0x66000F12),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                _academyDropdown(
                  context: context,
                  state: state,
                  bloc: bloc,
                  isInvalid: _isAcademyInvalid(state),
                ),
                const SizedBox(height: 32),
              ],
            ),
          ),

          // ── CTA Button ──────────────────────────────────────────────────
          bottomNavigationBar: SafeArea(
            minimum: const EdgeInsets.only(bottom: 16),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: SizedBox(
                height: 52,
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: state.isValid && !state.isSubmitting
                      ? () => bloc.add(const OnStep2Submit())
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
    );
  }

  bool _isDisciplineInvalid(OnboardingStep2State state) {
    return state.errorMessage == 'Please select a discipline';
  }

  bool _isExperienceInvalid(OnboardingStep2State state) {
    return state.errorMessage == 'Please select your experience level';
  }

  bool _isAcademyInvalid(OnboardingStep2State state) {
    return state.errorMessage == 'Please select an academy';
  }

  // ── Field Label ──────────────────────────────────────────────────────────
  Widget _fieldLabel(String label) {
    return Text(
      label,
      style: const TextStyle(
        fontSize: 13,
        fontWeight: FontWeight.w500,
        color: const Color(0x99000F12),
      ),
    );
  }

  // ── Discipline Dropdown ──────────────────────────────────────────────────
  Widget _disciplineDropdown({
    required BuildContext context,
    required OnboardingStep2State state,
    required OnboardingStep2Bloc bloc,
    required bool isInvalid,
  }) {
    final hasValue = state.discipline.isNotEmpty;
    final borderColor =
        isInvalid ? const Color(0xFF2F7E8F) : const Color(0xFFCAE8EE);

    return GestureDetector(
      onTap: () => _showDisciplinePicker(context, state, bloc),
      behavior: HitTestBehavior.opaque,
      child: Container(
        height: 48,
        padding: const EdgeInsets.symmetric(horizontal: 14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: borderColor, width: 1),
        ),
        child: Row(
          children: [
            Expanded(
              child: Text(
                hasValue ? state.discipline : state.disciplineHint,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w400,
                  color: hasValue
                      ? const Color(0xFF000F12)
                      : const Color(0xFF7FB8C4),
                ),
              ),
            ),
            const Icon(
              Icons.keyboard_arrow_down_rounded,
              size: 20,
              color: const Color(0x66000F12),
            ),
          ],
        ),
      ),
    );
  }

  void _showDisciplinePicker(
    BuildContext context,
    OnboardingStep2State state,
    OnboardingStep2Bloc bloc,
  ) {
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: const Color(0xFFF5FDFF),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (sheetCtx) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Handle
              Container(
                width: 36,
                height: 4,
                margin: const EdgeInsets.only(top: 12, bottom: 12),
                decoration: BoxDecoration(
                  color: const Color(0xFFCAE8EE),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 12),
                child: Text(
                  state.disciplineLabel,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF000F12),
                  ),
                ),
              ),
              const Divider(height: 1, color: Color(0xFFCAE8EE)),
              Flexible(
                child: ListView.builder(
                  shrinkWrap: true,
                  itemCount: state.disciplineOptions.length,
                  itemBuilder: (_, i) {
                    final opt = state.disciplineOptions[i];
                    final isSelected = state.discipline == opt;
                    return InkWell(
                      onTap: () {
                        bloc.add(OnDisciplineChanged(opt));
                        sheetCtx.pop();
                      },
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 14,
                        ),
                        child: Row(
                          children: [
                            Expanded(
                              child: Text(
                                opt,
                                style: TextStyle(
                                  fontSize: 15,
                                  fontWeight: isSelected
                                      ? FontWeight.w600
                                      : FontWeight.w400,
                                  color: isSelected
                                      ? const Color(0xFF2F7E8F)
                                      : const Color(0xFF000F12),
                                ),
                              ),
                            ),
                            if (isSelected)
                              const Icon(
                                Icons.check_rounded,
                                size: 18,
                                color: Color(0xFF2F7E8F),
                              ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 8),
            ],
          ),
        );
      },
    );
  }

  // ── Experience Dropdown ──────────────────────────────────────────────────
  Widget _experienceDropdown({
    required BuildContext context,
    required OnboardingStep2State state,
    required OnboardingStep2Bloc bloc,
    required bool isInvalid,
  }) {
    final hasValue = state.experience.isNotEmpty;
    final borderColor =
        isInvalid ? const Color(0xFF2F7E8F) : const Color(0xFFCAE8EE);

    return GestureDetector(
      onTap: () => _showExperiencePicker(context, state, bloc),
      behavior: HitTestBehavior.opaque,
      child: Container(
        height: 48,
        padding: const EdgeInsets.symmetric(horizontal: 14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: borderColor, width: 1),
        ),
        child: Row(
          children: [
            Expanded(
              child: Text(
                hasValue ? state.experience : 'Select level',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w400,
                  color: hasValue
                      ? const Color(0xFF000F12)
                      : const Color(0xFF7FB8C4),
                ),
              ),
            ),
            const Icon(
              Icons.keyboard_arrow_down_rounded,
              size: 20,
              color: Color(0x66000F12),
            ),
          ],
        ),
      ),
    );
  }

  void _showExperiencePicker(
    BuildContext context,
    OnboardingStep2State state,
    OnboardingStep2Bloc bloc,
  ) {
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: const Color(0xFFF5FDFF),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (sheetCtx) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 36,
                height: 4,
                margin: const EdgeInsets.only(top: 12, bottom: 12),
                decoration: BoxDecoration(
                  color: const Color(0xFFCAE8EE),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 12),
                child: Text(
                  state.experienceLabel,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF000F12),
                  ),
                ),
              ),
              const Divider(height: 1, color: Color(0xFFCAE8EE)),
              Flexible(
                child: ListView.builder(
                  shrinkWrap: true,
                  itemCount: state.experienceOptions.length,
                  itemBuilder: (_, i) {
                    final opt = state.experienceOptions[i];
                    final isSelected = state.experience == opt;
                    return InkWell(
                      onTap: () {
                        bloc.add(OnExperienceChanged(opt));
                        sheetCtx.pop();
                      },
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 14,
                        ),
                        child: Row(
                          children: [
                            Expanded(
                              child: Text(
                                opt,
                                style: TextStyle(
                                  fontSize: 15,
                                  fontWeight: isSelected
                                      ? FontWeight.w600
                                      : FontWeight.w400,
                                  color: isSelected
                                      ? const Color(0xFF2F7E8F)
                                      : const Color(0xFF000F12),
                                ),
                              ),
                            ),
                            if (isSelected)
                              const Icon(
                                Icons.check_rounded,
                                size: 18,
                                color: Color(0xFF2F7E8F),
                              ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 8),
            ],
          ),
        );
      },
    );
  }

  // ── Academy Dropdown ─────────────────────────────────────────────────────
  Widget _academyDropdown({
    required BuildContext context,
    required OnboardingStep2State state,
    required OnboardingStep2Bloc bloc,
    required bool isInvalid,
  }) {
    final hasValue = state.academy.isNotEmpty;
    final borderColor =
        isInvalid ? const Color(0xFF2F7E8F) : const Color(0xFFCAE8EE);

    return GestureDetector(
      onTap: () => _showAcademyPicker(context, state, bloc),
      behavior: HitTestBehavior.opaque,
      child: Container(
        height: 48,
        padding: const EdgeInsets.symmetric(horizontal: 14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: borderColor, width: 1),
        ),
        child: Row(
          children: [
            Expanded(
              child: Text(
                hasValue ? state.academy : state.academyHint,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w400,
                  color: hasValue
                      ? const Color(0xFF000F12)
                      : const Color(0xFF7FB8C4),
                ),
              ),
            ),
            const Icon(
              Icons.keyboard_arrow_down_rounded,
              size: 20,
              color: Color(0x66000F12),
            ),
          ],
        ),
      ),
    );
  }

  void _showAcademyPicker(
    BuildContext context,
    OnboardingStep2State state,
    OnboardingStep2Bloc bloc,
  ) {
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: const Color(0xFFF5FDFF),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (sheetCtx) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 36,
                height: 4,
                margin: const EdgeInsets.only(top: 12, bottom: 12),
                decoration: BoxDecoration(
                  color: const Color(0xFFCAE8EE),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 12),
                child: Text(
                  state.academyLabel,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF000F12),
                  ),
                ),
              ),
              const Divider(height: 1, color: Color(0xFFCAE8EE)),
              Flexible(
                child: ListView.builder(
                  shrinkWrap: true,
                  itemCount: state.academies.length,
                  itemBuilder: (_, i) {
                    final opt = state.academies[i];
                    final isSelected = state.academyId == opt.id;
                    return InkWell(
                      onTap: () {
                        bloc.add(OnAcademySelected(opt));
                        sheetCtx.pop();
                      },
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 14,
                        ),
                        child: Row(
                          children: [
                            Expanded(
                              child: Text(
                                opt.name,
                                style: TextStyle(
                                  fontSize: 15,
                                  fontWeight: isSelected
                                      ? FontWeight.w600
                                      : FontWeight.w400,
                                  color: isSelected
                                      ? const Color(0xFF2F7E8F)
                                      : const Color(0xFF000F12),
                                ),
                              ),
                            ),
                            if (isSelected)
                              const Icon(
                                Icons.check_rounded,
                                size: 18,
                                color: Color(0xFF2F7E8F),
                              ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 8),
            ],
          ),
        );
      },
    );
  }

  // ── Years Shooting Spinner ────────────────────────────────────────────────
  Widget _yearsStepper({
    required int value,
    required VoidCallback onDecrement,
    required VoidCallback onIncrement,
  }) {
    return Container(
      height: 48,
      padding: const EdgeInsets.only(left: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: const Color(0xFFCAE8EE), width: 1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(
              value > 0 ? '$value' : 'e.g. 3',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w400,
                color: value > 0
                    ? const Color(0xFF000F12)
                    : const Color(0xFF7FB8C4),
              ),
            ),
          ),
          Container(width: 1, color: const Color(0xFFCAE8EE)),
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _spinnerChevron(
                icon: Icons.keyboard_arrow_up_rounded,
                onTap: onIncrement,
                enabled: true,
              ),
              Container(height: 1, width: 20, color: const Color(0xFFCAE8EE)),
              _spinnerChevron(
                icon: Icons.keyboard_arrow_down_rounded,
                onTap: onDecrement,
                enabled: value > 0,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _spinnerChevron({
    required IconData icon,
    required VoidCallback onTap,
    required bool enabled,
  }) {
    return GestureDetector(
      onTap: enabled ? onTap : null,
      behavior: HitTestBehavior.opaque,
      child: SizedBox(
        width: 32,
        height: 22,
        child: Icon(
          icon,
          size: 18,
          color: enabled ? const Color(0xFF000F12) : const Color(0xFFCAE8EE),
        ),
      ),
    );
  }
}
