import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_text_styles.dart';
import '../../../../core/di/injection.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/app_text_field.dart';
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
          context.push('/onboarding/background',
              extra: context.read<OnboardingBloc>());
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
                  Text('Tell us about yourself', style: AppTextStyles.displayMedium),
                  const SizedBox(height: 8),
                  Text(
                    'We\'ll use this to personalise your training insights',
                    style: AppTextStyles.bodyMedium
                        .copyWith(color: AppColors.textSecondary),
                  ),
                  const SizedBox(height: 36),
                  AppTextField(
                    controller: _nameController,
                    label: 'Full Name',
                    hint: 'Enter your full name',
                    prefixIcon: Icons.person_outline_rounded,
                    validator: (v) =>
                        v == null || v.trim().isEmpty ? 'Required' : null,
                  ),
                  const SizedBox(height: 16),
                  AppTextField(
                    controller: _ageController,
                    label: 'Age',
                    hint: 'Enter your age',
                    prefixIcon: Icons.cake_outlined,
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
                    onChanged: (v) =>
                        setState(() => _experienceLevel = v!),
                  ),
                  const SizedBox(height: 40),
                  AppButton(
                    label: 'Continue',
                    onPressed: () => _submit(context),
                    icon: Icons.arrow_forward_rounded,
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
      dropdownColor: AppColors.card,
      style: AppTextStyles.bodyMedium,
      items: items
          .map((s) => DropdownMenuItem(value: s, child: Text(s)))
          .toList(),
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
              color: done || active ? AppColors.primary : AppColors.border,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
        );
      }),
    );
  }
}
