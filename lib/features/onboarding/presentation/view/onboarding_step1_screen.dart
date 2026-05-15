import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../bloc/onboarding_step1_bloc.dart';
import '../bloc/onboarding_step1_event.dart';
import '../bloc/onboarding_step1_state.dart';

class OnboardingStep1Screen extends StatelessWidget {
  const OnboardingStep1Screen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => OnboardingStep1Bloc(),
      child: const _OnboardingStep1View(),
    );
  }
}

class _OnboardingStep1View extends StatefulWidget {
  const _OnboardingStep1View();

  @override
  State<_OnboardingStep1View> createState() => _OnboardingStep1ViewState();
}

class _OnboardingStep1ViewState extends State<_OnboardingStep1View> {
  late final TextEditingController _nameController;
  late final TextEditingController _ageController;
  late final TextEditingController _cityController;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController();
    _ageController = TextEditingController();
    _cityController = TextEditingController();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _ageController.dispose();
    _cityController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<OnboardingStep1Bloc, OnboardingStep1State>(
      listenWhen: (previous, current) =>
          previous.submissionSuccess != current.submissionSuccess ||
          previous.errorMessage != current.errorMessage ||
          previous.name != current.name ||
          previous.age != current.age ||
          previous.city != current.city ||
          previous.gender != current.gender,
      listener: (context, state) {
        if (_nameController.text != state.name) {
          _nameController.text = state.name;
        }
        if (_ageController.text != state.age) {
          _ageController.text = state.age;
        }
        if (_cityController.text != state.city) {
          _cityController.text = state.city;
        }

        if (state.submissionSuccess) {
          context.go('/onboarding/step2');
        }
      },
      builder: (context, state) {
        final bloc = context.read<OnboardingStep1Bloc>();

        return Scaffold(
          backgroundColor: const Color(0xFFF5FDFF),

          // ── AppBar + Progress Bar ──────────────────────────────────────
          appBar: PreferredSize(
            preferredSize: const Size.fromHeight(60),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // AppBar Row
                Container(
                  color: Colors.white,
                  child: SafeArea(
                    bottom: false,
                    child: SizedBox(
                      height: 52,
                      child: Row(
                        children: [
                          // ── Back Arrow ──────────────────────────────
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
                              onPressed: () => context.go('/questions'),
                            ),
                          ),

                          // ── Step Title (truly centered) ──────────────
                          Expanded(
                            child: Center(
                              child: Text(
                                state.stepTitle,
                                style: const TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                  color: const Color(0x99000F12),
                                ),
                              ),
                            ),
                          ),

                          // ── Ghost spacer to keep title centered ───────
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
            padding: const EdgeInsets.fromLTRB(20, 28, 20, 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ── Heading ─────────────────────────────────────────────
                Text(
                  state.heading,
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.w700,
                    color: Colors.black,
                    height: 1.3,
                  ),
                ),
                const SizedBox(height: 8),

                // ── Subtitle ────────────────────────────────────────────
                Text(
                  state.subtitle,
                  style: const TextStyle(
                    fontSize: 16.5,
                    fontWeight: FontWeight.w400,
                    color: const Color(0x99000F12),
                    height: 1.5,
                  ),
                ),
                const SizedBox(height: 24),

                // ── Full Name ───────────────────────────────────────────
                _fieldLabel(state.nameLabel),
                const SizedBox(height: 7),
                _inputField(
                  controller: _nameController,
                  hint: state.nameHint,
                  keyboardType: TextInputType.text,
                  isInvalid: _isNameInvalid(state),
                  onChanged: (v) => bloc.add(OnNameChanged(v)),
                ),
                const SizedBox(height: 18),

                // ── Age ─────────────────────────────────────────────────
                _fieldLabel(state.ageLabel),
                const SizedBox(height: 7),
                _inputField(
                  controller: _ageController,
                  hint: state.ageHint,
                  keyboardType: TextInputType.number,
                  isInvalid: _isAgeInvalid(state),
                  onChanged: (v) => bloc.add(OnAgeChanged(v)),
                ),
                const SizedBox(height: 18),

                // ── Gender ──────────────────────────────────────────────
                _fieldLabel(state.genderLabel),
                const SizedBox(height: 12),
                _genderRow(
                  options: state.genderOptions,
                  selected: _genderToString(state.gender),
                  isInvalid: _isGenderInvalid(state),
                  onSelect: (v) => bloc.add(OnGenderSelected(v)),
                ),
                const SizedBox(height: 18),

                // ── City ────────────────────────────────────────────────
                _fieldLabel(state.cityLabel),
                const SizedBox(height: 7),
                _inputField(
                  controller: _cityController,
                  hint: state.cityHint,
                  keyboardType: TextInputType.text,
                  isInvalid: _isCityInvalid(state),
                  onChanged: (v) => bloc.add(OnCityChanged(v)),
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
                      ? () => bloc.add(const OnSubmit())
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

  bool _isNameInvalid(OnboardingStep1State state) {
    final message = state.errorMessage;
    return message == 'Please enter your full name' ||
        message == 'Name is too short';
  }

  bool _isAgeInvalid(OnboardingStep1State state) {
    final message = state.errorMessage;
    return message == 'Please enter a valid age' ||
        message == 'Please enter a realistic age';
  }

  bool _isGenderInvalid(OnboardingStep1State state) {
    return state.errorMessage == 'Please select a gender';
  }

  bool _isCityInvalid(OnboardingStep1State state) {
    return state.errorMessage == 'Please enter your city';
  }

  // ── Field Label ──────────────────────────────────────────────────────────
  Widget _fieldLabel(String label) {
    return Text(
      label,
      style: const TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w500,
        color: const Color(0x99000F12),
      ),
    );
  }

  // ── Input Field ──────────────────────────────────────────────────────────
  Widget _inputField({
    required TextEditingController controller,
    required String hint,
    required TextInputType keyboardType,
    required bool isInvalid,
    required ValueChanged<String> onChanged,
  }) {
    final borderColor =
        isInvalid ? const Color(0xFF2F7E8F) : const Color(0xFFCAE8EE);

    return TextField(
      controller: controller,
      keyboardType: keyboardType,
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
          color: const Color(0x66000F12),
        ),
        filled: true,
        fillColor: Colors.white,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 14,
          vertical: 13,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(
            color: borderColor,
            width: 1,
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(
            color: Color(0xFF2F7E8F),
            width: 1.5,
          ),
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(
            color: borderColor,
            width: 1,
          ),
        ),
      ),
    );
  }

  // ── Gender Row ───────────────────────────────────────────────────────────
  Widget _genderRow({
    required List<String> options,
    required String selected,
    required bool isInvalid,
    required ValueChanged<String> onSelect,
  }) {
    return Row(
      children: List.generate(options.length, (i) {
        final opt = options[i];
        final isSelected = selected == opt;
        final label = opt[0].toUpperCase() + opt.substring(1);

        return Padding(
          padding: EdgeInsets.only(right: i < options.length - 1 ? 20 : 0),
          child: GestureDetector(
            onTap: () => onSelect(opt),
            behavior: HitTestBehavior.opaque,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Rounded-square checkbox
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
                          : isInvalid
                              ? const Color(0xFF2F7E8F)
                              : const Color(0xFF7FB8C4),
                      width: 1.5,
                    ),
                  ),
                  child: isSelected
                      ? const Icon(
                          Icons.check_rounded,
                          size: 13,
                          color: Colors.white,
                        )
                      : null,
                ),
                const SizedBox(width: 8),
                Text(
                  label,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w400,
                    color: Color(0xFF000F12),
                  ),
                ),
              ],
            ),
          ),
        );
      }),
    );
  }

  // ── Enum → String ────────────────────────────────────────────────────────
  String _genderToString(OnboardingGender gender) {
    switch (gender) {
      case OnboardingGender.male:
        return 'male';
      case OnboardingGender.female:
        return 'female';
      case OnboardingGender.other:
        return 'other';
      default:
        return '';
    }
  }
}
