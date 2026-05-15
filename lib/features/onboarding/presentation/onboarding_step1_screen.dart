import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'bloc/onboarding_step1_bloc.dart';
import 'bloc/onboarding_step1_event.dart';
import 'bloc/onboarding_step1_state.dart';

// Assumed design system import — adjust if your project uses a different path
import 'package:hamsatech_design_system/hamsatech_design_system.dart';

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

class _GenderOption extends StatelessWidget {
  const _GenderOption({
    required this.label,
    required this.value,
    required this.selected,
    required this.isInvalid,
    required this.onTap,
  });

  final String label;
  final String value;
  final bool selected;
  final bool isInvalid;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: selected ? DSColors.brand : DSColors.gray50,
          border: Border.all(
            color: selected
                ? DSColors.brand
                : isInvalid
                    ? DSColors.error
                    : DSColors.gray200,
          ),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              selected ? Icons.check_circle : Icons.radio_button_unchecked,
              size: 16,
              color: selected ? DSColors.white : DSColors.gray500,
            ),
            const SizedBox(width: 8),
            Text(label,
                style: DSTypography.bodyMd.copyWith(
                    color: selected ? DSColors.white : DSColors.gray900)),
          ],
        ),
      ),
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
          previous.city != current.city,
      listener: (context, state) {
        // keep controllers in sync with state
        if (_nameController.text != state.name) {
          _nameController.text = state.name;
        }
        if (_ageController.text != state.age) _ageController.text = state.age;
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
          // Using Material Scaffold because DS may not provide page shell.
          appBar: AppBar(
            leading: IconButton(
              icon: const Icon(Icons.arrow_back),
              onPressed: () => context.go('/questions'),
            ),
            title: Text(state.stepTitle),
            bottom: PreferredSize(
              preferredSize: const Size.fromHeight(4),
              child: LinearProgressIndicator(
                value: state.progress,
                // fallback colors — design system colors may be different
                backgroundColor: Theme.of(context).colorScheme.surface,
                valueColor: AlwaysStoppedAnimation<Color>(
                    Theme.of(context).colorScheme.primary),
                minHeight: 4,
              ),
            ),
          ),
          body: SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Heading & subtitle come from state (no hardcoded UI strings)
                  Text(state.heading,
                      style: Theme.of(context).textTheme.titleLarge),
                  const SizedBox(height: 8),
                  Text(state.subtitle,
                      style: Theme.of(context).textTheme.bodyMedium),
                  const SizedBox(height: 24),

                  // Form fields
                  // Labels and hints come from state
                  Text(state.nameLabel,
                      style: Theme.of(context).textTheme.labelSmall),
                  const SizedBox(height: 8),
                  DSTextInput(
                    key: const ValueKey('nameField'),
                    controller: _nameController,
                    placeholder: state.nameHint,
                    state: _isNameInvalid(state)
                        ? DSInputState.error
                        : DSInputState.normal,
                    onChanged: (v) => bloc.add(OnNameChanged(v)),
                  ),
                  const SizedBox(height: 16),

                  Text(state.ageLabel,
                      style: Theme.of(context).textTheme.labelSmall),
                  const SizedBox(height: 8),
                  DSTextInput(
                    key: const ValueKey('ageField'),
                    controller: _ageController,
                    placeholder: state.ageHint,
                    keyboardType: TextInputType.number,
                    state: _isAgeInvalid(state)
                        ? DSInputState.error
                        : DSInputState.normal,
                    onChanged: (v) => bloc.add(OnAgeChanged(v)),
                  ),
                  const SizedBox(height: 16),

                  Text(state.genderLabel,
                      style: Theme.of(context).textTheme.labelSmall),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      for (var i = 0; i < state.genderOptions.length; i++) ...[
                        _GenderOption(
                          label: state.genderOptions[i][0].toUpperCase() +
                              state.genderOptions[i].substring(1),
                          value: state.genderOptions[i],
                          selected: _genderToString(state.gender) ==
                              state.genderOptions[i],
                          isInvalid: _isGenderInvalid(state),
                          onTap: () => bloc
                              .add(OnGenderSelected(state.genderOptions[i])),
                        ),
                        if (i != state.genderOptions.length - 1)
                          const SizedBox(width: 12),
                      ],
                    ],
                  ),
                  const SizedBox(height: 16),

                  Text(state.cityLabel,
                      style: Theme.of(context).textTheme.labelSmall),
                  const SizedBox(height: 8),
                  DSTextInput(
                    key: const ValueKey('cityField'),
                    controller: _cityController,
                    placeholder: state.cityHint,
                    state: _isCityInvalid(state)
                        ? DSInputState.error
                        : DSInputState.normal,
                    onChanged: (v) => bloc.add(OnCityChanged(v)),
                  ),

                  const Spacer(),

                  DSButton(
                    label: state.ctaLabel,
                    onPressed:
                        state.isValid ? () => bloc.add(const OnSubmit()) : null,
                  ),
                ],
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
}
