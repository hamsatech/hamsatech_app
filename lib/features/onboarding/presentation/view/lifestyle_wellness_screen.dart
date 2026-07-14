import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../bloc/lifestyle_wellness_bloc.dart';
import '../bloc/lifestyle_wellness_event.dart';
import '../bloc/lifestyle_wellness_state.dart';

class LifestyleWellnessScreen extends StatelessWidget {
  const LifestyleWellnessScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => LifestyleWellnessBloc(),
      child: const _LifestyleWellnessView(),
    );
  }
}

class _LifestyleWellnessView extends StatefulWidget {
  const _LifestyleWellnessView();

  @override
  State<_LifestyleWellnessView> createState() =>
      _LifestyleWellnessViewState();
}

class _LifestyleWellnessViewState extends State<_LifestyleWellnessView> {
  late final TextEditingController _dietTypeController;
  late final TextEditingController _outsideFoodFrequencyController;
  late final TextEditingController _sleepTimeController;
  late final TextEditingController _wakeTimeController;

  @override
  void initState() {
    super.initState();
    _dietTypeController = TextEditingController();
    _outsideFoodFrequencyController = TextEditingController();
    _sleepTimeController = TextEditingController();
    _wakeTimeController = TextEditingController();
  }

  @override
  void dispose() {
    _dietTypeController.dispose();
    _outsideFoodFrequencyController.dispose();
    _sleepTimeController.dispose();
    _wakeTimeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<LifestyleWellnessBloc, LifestyleWellnessState>(
      listenWhen: (previous, current) =>
          previous.submissionSuccess != current.submissionSuccess ||
          previous.errorMessage != current.errorMessage ||
          previous.dietType != current.dietType ||
          previous.outsideFoodFrequency != current.outsideFoodFrequency ||
          previous.sleepTime != current.sleepTime ||
          previous.wakeTime != current.wakeTime,
      listener: (context, state) {
        if (_dietTypeController.text != state.dietType) {
          _dietTypeController.text = state.dietType;
        }
        if (_outsideFoodFrequencyController.text !=
            state.outsideFoodFrequency) {
          _outsideFoodFrequencyController.text = state.outsideFoodFrequency;
        }
        if (_sleepTimeController.text != state.sleepTime) {
          _sleepTimeController.text = state.sleepTime;
        }
        if (_wakeTimeController.text != state.wakeTime) {
          _wakeTimeController.text = state.wakeTime;
        }

        if (state.submissionSuccess) {
          context.go('/onboarding/step6');
        }
      },
      builder: (context, state) {
        final bloc = context.read<LifestyleWellnessBloc>();

        return Scaffold(
          backgroundColor: const Color(0xFFF5FDFF),
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
                              onPressed: () => context.go('/onboarding/step4'),
                            ),
                          ),
                          Expanded(
                            child: Center(
                              child: Text(
                                state.stepTitle,
                                style: const TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                  color: Color(0x99000F12),
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
          body: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(16, 28, 16, 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
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
                Text(
                  state.subtitle,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w400,
                    color: Color(0x99000F12),
                    height: 1.5,
                  ),
                ),
                const SizedBox(height: 24),

                // ── Diet Type ───────────────────────────────────────────
                _fieldLabel(state.dietTypeLabel),
                const SizedBox(height: 7),
                _inputField(
                  controller: _dietTypeController,
                  hint: state.dietTypeHint,
                  isInvalid: state.errorMessage == 'Please enter your diet type',
                  onChanged: (v) => bloc.add(OnDietTypeChanged(v)),
                ),
                const SizedBox(height: 18),

                // ── Outside Food Frequency ──────────────────────────────
                _fieldLabel(state.outsideFoodFrequencyLabel),
                const SizedBox(height: 7),
                _inputField(
                  controller: _outsideFoodFrequencyController,
                  hint: state.outsideFoodFrequencyHint,
                  isInvalid: state.errorMessage ==
                      'Please enter your outside food frequency',
                  onChanged: (v) =>
                      bloc.add(OnOutsideFoodFrequencyChanged(v)),
                ),
                const SizedBox(height: 18),

                // ── Sleep Time + Wake Time (side by side) ───────────────
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _fieldLabel(state.sleepTimeLabel),
                          const SizedBox(height: 7),
                          _inputField(
                            controller: _sleepTimeController,
                            hint: state.sleepTimeHint,
                            isInvalid: state.errorMessage ==
                                'Please enter your sleep time',
                            onChanged: (v) =>
                                bloc.add(OnSleepTimeChanged(v)),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _fieldLabel(state.wakeTimeLabel),
                          const SizedBox(height: 7),
                          _inputField(
                            controller: _wakeTimeController,
                            hint: state.wakeTimeHint,
                            isInvalid: state.errorMessage ==
                                'Please enter your wake time',
                            onChanged: (v) => bloc.add(OnWakeTimeChanged(v)),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 32),
              ],
            ),
          ),
          bottomNavigationBar: SafeArea(
            minimum: const EdgeInsets.only(bottom: 16),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: SizedBox(
                height: 52,
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: state.isValid
                      ? () => bloc.add(const OnLifestyleWellnessSubmit())
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

  Widget _inputField({
    required TextEditingController controller,
    required String hint,
    required bool isInvalid,
    required ValueChanged<String> onChanged,
  }) {
    final borderColor =
        isInvalid ? const Color(0xFF2F7E8F) : const Color(0xFFCAE8EE);

    return TextField(
      controller: controller,
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
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
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
}
