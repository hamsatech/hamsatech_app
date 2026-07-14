import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../bloc/mental_social_profile_bloc.dart';
import '../bloc/mental_social_profile_event.dart';
import '../bloc/mental_social_profile_state.dart';

class MentalSocialProfileScreen extends StatelessWidget {
  const MentalSocialProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => MentalSocialProfileBloc(),
      child: const _MentalSocialProfileView(),
    );
  }
}

class _MentalSocialProfileView extends StatefulWidget {
  const _MentalSocialProfileView();

  @override
  State<_MentalSocialProfileView> createState() =>
      _MentalSocialProfileViewState();
}

class _MentalSocialProfileViewState extends State<_MentalSocialProfileView> {
  late final TextEditingController _friendCircleController;
  late final TextEditingController _angerPatternController;
  late final TextEditingController _sadnessPatternController;
  late final TextEditingController _reasonForShootingController;
  late final TextEditingController _athleteGoalController;

  @override
  void initState() {
    super.initState();
    _friendCircleController = TextEditingController();
    _angerPatternController = TextEditingController();
    _sadnessPatternController = TextEditingController();
    _reasonForShootingController = TextEditingController();
    _athleteGoalController = TextEditingController();
  }

  @override
  void dispose() {
    _friendCircleController.dispose();
    _angerPatternController.dispose();
    _sadnessPatternController.dispose();
    _reasonForShootingController.dispose();
    _athleteGoalController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<MentalSocialProfileBloc, MentalSocialProfileState>(
      listenWhen: (previous, current) =>
          previous.submissionSuccess != current.submissionSuccess ||
          previous.errorMessage != current.errorMessage ||
          previous.friendCircle != current.friendCircle ||
          previous.angerPattern != current.angerPattern ||
          previous.sadnessPattern != current.sadnessPattern ||
          previous.reasonForShooting != current.reasonForShooting ||
          previous.athleteGoal != current.athleteGoal,
      listener: (context, state) {
        if (_friendCircleController.text != state.friendCircle) {
          _friendCircleController.text = state.friendCircle;
        }
        if (_angerPatternController.text != state.angerPattern) {
          _angerPatternController.text = state.angerPattern;
        }
        if (_sadnessPatternController.text != state.sadnessPattern) {
          _sadnessPatternController.text = state.sadnessPattern;
        }
        if (_reasonForShootingController.text != state.reasonForShooting) {
          _reasonForShootingController.text = state.reasonForShooting;
        }
        if (_athleteGoalController.text != state.athleteGoal) {
          _athleteGoalController.text = state.athleteGoal;
        }

        if (state.submissionSuccess) {
          context.go('/questions');
        }
      },
      builder: (context, state) {
        final bloc = context.read<MentalSocialProfileBloc>();

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
                              onPressed: () => context.go('/onboarding/step5'),
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

                _fieldLabel(state.friendCircleLabel),
                const SizedBox(height: 7),
                _inputField(
                  controller: _friendCircleController,
                  hint: state.friendCircleHint,
                  isInvalid:
                      state.errorMessage == 'Please describe your friend circle',
                  onChanged: (v) => bloc.add(OnFriendCircleChanged(v)),
                ),
                const SizedBox(height: 18),

                _fieldLabel(state.angerPatternLabel),
                const SizedBox(height: 7),
                _inputField(
                  controller: _angerPatternController,
                  hint: state.angerPatternHint,
                  isInvalid:
                      state.errorMessage == 'Please describe your anger pattern',
                  onChanged: (v) => bloc.add(OnAngerPatternChanged(v)),
                ),
                const SizedBox(height: 18),

                _fieldLabel(state.sadnessPatternLabel),
                const SizedBox(height: 7),
                _inputField(
                  controller: _sadnessPatternController,
                  hint: state.sadnessPatternHint,
                  isInvalid: state.errorMessage ==
                      'Please describe your sadness pattern',
                  onChanged: (v) => bloc.add(OnSadnessPatternChanged(v)),
                ),
                const SizedBox(height: 18),

                _fieldLabel(state.reasonForShootingLabel),
                const SizedBox(height: 7),
                _inputField(
                  controller: _reasonForShootingController,
                  hint: state.reasonForShootingHint,
                  isInvalid: state.errorMessage ==
                      'Please share your reason for shooting',
                  onChanged: (v) => bloc.add(OnReasonForShootingChanged(v)),
                ),
                const SizedBox(height: 18),

                _fieldLabel(state.athleteGoalLabel),
                const SizedBox(height: 7),
                _inputField(
                  controller: _athleteGoalController,
                  hint: state.athleteGoalHint,
                  isInvalid:
                      state.errorMessage == 'Please enter your athlete goal',
                  onChanged: (v) => bloc.add(OnAthleteGoalChanged(v)),
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
                      ? () => bloc.add(const OnMentalSocialProfileSubmit())
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
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                      letterSpacing: 0.2,
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
