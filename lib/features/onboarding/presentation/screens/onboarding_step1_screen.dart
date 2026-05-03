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
      child: const _Step1View(),
    );
  }
}

class _Step1View extends StatefulWidget {
  const _Step1View();

  @override
  State<_Step1View> createState() => _Step1ViewState();
}

class _Step1ViewState extends State<_Step1View> {
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
      listenWhen: (prev, curr) =>
          prev.submissionSuccess != curr.submissionSuccess ||
          prev.errorMessage != curr.errorMessage ||
          prev.name != curr.name ||
          prev.age != curr.age ||
          prev.city != curr.city,
      listener: (context, state) {
        if (_nameController.text != state.name) _nameController.text = state.name;
        if (_ageController.text != state.age) _ageController.text = state.age;
        if (_cityController.text != state.city) _cityController.text = state.city;

        if (state.submissionSuccess) {
          GoRouter.of(context).go('/onboarding/step2');
        } else if (state.errorMessage != null) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.errorMessage!),
              behavior: SnackBarBehavior.floating,
              backgroundColor: const Color(0xFFE53935),
            ),
          );
        }
      },
      builder: (context, state) {
        final bloc = context.read<OnboardingStep1Bloc>();

        return Scaffold(
          backgroundColor: Colors.white,
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
                                  minWidth: 40, minHeight: 40),
                              icon: const Icon(
                                Icons.arrow_back_ios_new_rounded,
                                color: Colors.black,
                                size: 20,
                              ),
                              onPressed: () => Navigator.of(context).maybePop(),
                            ),
                          ),
                          Expanded(
                            child: Center(
                              child: Text(
                                state.stepTitle,
                                style: const TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                  color: Color(0xFF666666),
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
                  child: LayoutBuilder(
                    builder: (context, constraints) => Stack(
                      children: [
                        Container(
                          width: double.infinity,
                          height: 3,
                          decoration: BoxDecoration(
                            color: const Color(0xFFE6E6E6),
                            borderRadius: BorderRadius.circular(2),
                          ),
                        ),
                        AnimatedContainer(
                          duration: const Duration(milliseconds: 300),
                          curve: Curves.easeInOut,
                          width: constraints.maxWidth *
                              state.progress.clamp(0.0, 1.0),
                          height: 3,
                          decoration: BoxDecoration(
                            color: const Color(0xFFE53935),
                            borderRadius: BorderRadius.circular(2),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          body: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(20, 28, 20, 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
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
                Text(
                  state.subtitle,
                  style: const TextStyle(
                    fontSize: 15,
                    color: Color(0xFF777777),
                    height: 1.5,
                  ),
                ),
                const SizedBox(height: 28),
                _FieldLabel(state.nameLabel),
                const SizedBox(height: 7),
                _InputField(
                  controller: _nameController,
                  hint: state.nameHint,
                  onChanged: (v) => bloc.add(OnNameChanged(v)),
                ),
                const SizedBox(height: 18),
                _FieldLabel(state.ageLabel),
                const SizedBox(height: 7),
                _InputField(
                  controller: _ageController,
                  hint: state.ageHint,
                  keyboardType: TextInputType.number,
                  onChanged: (v) => bloc.add(OnAgeChanged(v)),
                ),
                const SizedBox(height: 18),
                _FieldLabel(state.genderLabel),
                const SizedBox(height: 12),
                _GenderRow(
                  options: state.genderOptions,
                  selected: _genderToString(state.gender),
                  onSelect: (v) => bloc.add(OnGenderSelected(v)),
                ),
                const SizedBox(height: 18),
                _FieldLabel(state.cityLabel),
                const SizedBox(height: 7),
                _InputField(
                  controller: _cityController,
                  hint: state.cityHint,
                  onChanged: (v) => bloc.add(OnCityChanged(v)),
                ),
              ],
            ),
          ),
          bottomNavigationBar: SafeArea(
            minimum: const EdgeInsets.only(bottom: 16),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: SizedBox(
                height: 52,
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: state.isSubmitting
                      ? null
                      : () => bloc.add(const OnSubmit()),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFE53935),
                    disabledBackgroundColor:
                        const Color(0xFFE53935).withValues(alpha: 0.6),
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10)),
                  ),
                  child: state.isSubmitting
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                              color: Colors.white, strokeWidth: 2),
                        )
                      : Text(
                          state.ctaLabel,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
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

  String _genderToString(OnboardingGender g) {
    switch (g) {
      case OnboardingGender.male:
        return 'male';
      case OnboardingGender.female:
        return 'female';
      case OnboardingGender.other:
        return 'other';
      case OnboardingGender.unknown:
        return '';
    }
  }
}

// ── Shared sub-widgets ────────────────────────────────────────────────────────

class _FieldLabel extends StatelessWidget {
  const _FieldLabel(this.label);
  final String label;

  @override
  Widget build(BuildContext context) {
    return Text(
      label,
      style: const TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w500,
        color: Color(0xFF555555),
      ),
    );
  }
}

class _InputField extends StatelessWidget {
  const _InputField({
    required this.controller,
    required this.hint,
    required this.onChanged,
    this.keyboardType = TextInputType.text,
  });

  final TextEditingController controller;
  final String hint;
  final ValueChanged<String> onChanged;
  final TextInputType keyboardType;

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      keyboardType: keyboardType,
      onChanged: onChanged,
      style: const TextStyle(
          fontSize: 14, fontWeight: FontWeight.w400, color: Color(0xFF111111)),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w400,
            color: Color(0xFFBBBBBB)),
        filled: true,
        fillColor: Colors.white,
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: Color(0xFFE0E0E0)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide:
              const BorderSide(color: Color(0xFFE53935), width: 1.5),
        ),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
      ),
    );
  }
}

class _GenderRow extends StatelessWidget {
  const _GenderRow({
    required this.options,
    required this.selected,
    required this.onSelect,
  });

  final List<String> options;
  final String selected;
  final ValueChanged<String> onSelect;

  @override
  Widget build(BuildContext context) {
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
                          : const Color(0xFFBBBBBB),
                      width: 1.5,
                    ),
                  ),
                  child: isSelected
                      ? const Icon(Icons.check_rounded,
                          size: 13, color: Colors.white)
                      : null,
                ),
                const SizedBox(width: 8),
                Text(label,
                    style: const TextStyle(
                        fontSize: 14, color: Color(0xFF333333))),
              ],
            ),
          ),
        );
      }),
    );
  }
}
