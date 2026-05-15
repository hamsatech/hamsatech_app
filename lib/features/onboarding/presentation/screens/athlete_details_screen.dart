import 'package:flutter/material.dart';
import 'package:hamsatech_design_system/hamsatech_design_system.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/di/injection.dart';

import '../bloc/onboarding_bloc.dart';
import '../bloc/onboarding_event.dart';
import '../bloc/onboarding_state.dart';

class AthleteDetailsScreen extends StatelessWidget {
  const AthleteDetailsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: getIt<OnboardingBloc>(),
      child: const _AthleteDetailsView(),
    );
  }
}

class _AthleteDetailsView extends StatefulWidget {
  const _AthleteDetailsView();

  @override
  State<_AthleteDetailsView> createState() => _AthleteDetailsViewState();
}

class _AthleteDetailsViewState extends State<_AthleteDetailsView> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _ageController = TextEditingController();
  String _sportDomain = '10m Air Rifle';
  String _experienceLevel = 'Intermediate';

  final _sportDomains = [
    '10m Air Rifle',
    '10m Air Pistol',
    '50m Rifle 3 Positions',
    '25m Rapid Fire Pistol',
    '50m Pistol',
    'Trap',
    'Skeet',
    'Other',
  ];

  final _experienceLevels = [
    'Beginner',
    'Intermediate',
    'Advanced',
    'Elite',
  ];

  @override
  void dispose() {
    _nameController.dispose();
    _ageController.dispose();
    super.dispose();
  }

  void _submit(BuildContext context) {
    if (!_formKey.currentState!.validate()) return;
    context.read<OnboardingBloc>().add(
          OnboardingAthleteDetailsSubmitted(
            name: _nameController.text.trim(),
            age: int.parse(_ageController.text.trim()),
            sportDomain: _sportDomain,
            experienceLevel: _experienceLevel,
          ),
        );
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<OnboardingBloc, OnboardingState>(
      listener: (context, state) {
        if (state.step == OnboardingStep.backgroundContext) {
          context.go('/onboarding/background');
        }
      },
      child: Scaffold(
        body: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 16),
                  _StepIndicator(current: 1, total: 3),
                  const SizedBox(height: 32),
                  Text('Tell us about yourself',
                      style: DSTypography.displayMedium),
                  const SizedBox(height: 8),
                  Text(
                    'We\'ll use this to personalise your training insights',
                    style: DSTypography.bodyMedium
                        .copyWith(color: DSColors.textSecondary),
                  ),
                  const SizedBox(height: 36),
                  DSTextInput(
                    controller: _nameController,
                    label: 'Full Name',
                    placeholder: 'Enter your full name',
                    prefixIcon: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      child: Icon(Icons.person_outline_rounded,
                          size: 20, color: DSColors.textMuted),
                    ),
                    validator: (v) =>
                        v == null || v.trim().isEmpty ? 'Required' : null,
                  ),
                  const SizedBox(height: 16),
                  DSTextInput(
                    controller: _ageController,
                    label: 'Age',
                    placeholder: 'Enter your age',
                    prefixIcon: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      child: Icon(Icons.cake_outlined,
                          size: 20, color: DSColors.textMuted),
                    ),
                    keyboardType: TextInputType.number,
                    validator: (v) {
                      if (v == null || v.isEmpty) return 'Required';
                      final age = int.tryParse(v);
                      if (age == null || age < 10 || age > 80) {
                        return 'Enter a valid age';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  _DropdownField(
                    label: 'Sport Domain',
                    value: _sportDomain,
                    items: _sportDomains,
                    onChanged: (v) => setState(() => _sportDomain = v!),
                  ),
                  const SizedBox(height: 16),
                  _DropdownField(
                    label: 'Experience Level',
                    value: _experienceLevel,
                    items: _experienceLevels,
                    onChanged: (v) => setState(() => _experienceLevel = v!),
                  ),
                  const SizedBox(height: 40),
                  // Example navigation to the newly added route:
                  // context.go('/onboarding/step1');
                  DSButton(
                    label: 'Continue',
                    onPressed: () => _submit(context),
                    leadingIcon: const Icon(Icons.arrow_forward_rounded),
                    isFullWidth: true,
                  ),
                  const SizedBox(height: 24),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _DropdownField extends StatelessWidget {
  const _DropdownField({
    required this.label,
    required this.value,
    required this.items,
    required this.onChanged,
  });

  final String label;
  final String value;
  final List<String> items;
  final ValueChanged<String?> onChanged;

  @override
  Widget build(BuildContext context) {
    return DropdownButtonFormField<String>(
      key: ValueKey(value),
      initialValue: value,
      decoration: InputDecoration(labelText: label),
      dropdownColor: DSColors.appCard,
      style: DSTypography.bodyMedium,
      items:
          items.map((s) => DropdownMenuItem(value: s, child: Text(s))).toList(),
      onChanged: onChanged,
    );
  }
}

class _StepIndicator extends StatelessWidget {
  const _StepIndicator({required this.current, required this.total});

  final int current;
  final int total;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: List.generate(total, (i) {
        final active = i + 1 == current;
        final done = i + 1 < current;
        return Expanded(
          child: Container(
            height: 4,
            margin: EdgeInsets.only(right: i < total - 1 ? 6 : 0),
            decoration: BoxDecoration(
              color: done || active ? DSColors.brand : DSColors.appBorder,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
        );
      }),
    );
  }
}
