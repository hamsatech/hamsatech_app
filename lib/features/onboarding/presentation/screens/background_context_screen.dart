import 'package:flutter/material.dart';
import 'package:hamsatech_design_system/hamsatech_design_system.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/di/injection.dart';

import '../bloc/onboarding_bloc.dart';
import '../bloc/onboarding_event.dart';
import '../bloc/onboarding_state.dart';

class BackgroundContextScreen extends StatelessWidget {
  const BackgroundContextScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: getIt<OnboardingBloc>(),
      child: const _BackgroundContextView(),
    );
  }
}

class _BackgroundContextView extends StatefulWidget {
  const _BackgroundContextView();

  @override
  State<_BackgroundContextView> createState() => _BackgroundContextViewState();
}

class _BackgroundContextViewState extends State<_BackgroundContextView> {
  String _familySupport = 'Moderate';

  final _pressureSourceOptions = [
    'Coach expectations',
    'Family expectations',
    'Selection pressure',
    'Financial pressure',
    'Peer competition',
    'Social media',
    'Self-imposed standards',
    'Academic/work balance',
  ];

  final Set<String> _selectedPressureSources = {};

  void _submit(BuildContext context) {
    if (_selectedPressureSources.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select at least one pressure source'),
        ),
      );
      return;
    }
    context.read<OnboardingBloc>().add(
          OnboardingBackgroundContextSubmitted(
            familySupport: _familySupport,
            pressureSources: _selectedPressureSources.toList(),
          ),
        );
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<OnboardingBloc, OnboardingState>(
      listener: (context, state) {
        if (state.step == OnboardingStep.assessment) {
          context.go('/questions');
        }
      },
      child: Scaffold(
        appBar: AppBar(
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios_new_rounded),
            onPressed: () => context.go('/onboarding/details'),
          ),
        ),
        body: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _StepIndicator(current: 2, total: 3),
                const SizedBox(height: 32),
                Text('Your environment', style: DSTypography.displayMedium),
                const SizedBox(height: 8),
                Text(
                  'Understanding your background helps us provide more accurate insights',
                  style: DSTypography.bodyMedium
                      .copyWith(color: DSColors.textSecondary),
                ),
                const SizedBox(height: 36),
                Text('Family support level', style: DSTypography.headingSmall),
                const SizedBox(height: 12),
                _SupportSelector(
                  selected: _familySupport,
                  onChanged: (v) => setState(() => _familySupport = v),
                ),
                const SizedBox(height: 28),
                Text(
                  'What pressures do you typically face?',
                  style: DSTypography.headingSmall,
                ),
                const SizedBox(height: 4),
                Text(
                  'Select all that apply',
                  style: DSTypography.bodySmall,
                ),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: _pressureSourceOptions.map((option) {
                    final selected = _selectedPressureSources.contains(option);
                    return FilterChip(
                      label: Text(option, style: DSTypography.labelMedium),
                      selected: selected,
                      onSelected: (v) {
                        setState(() {
                          if (v) {
                            _selectedPressureSources.add(option);
                          } else {
                            _selectedPressureSources.remove(option);
                          }
                        });
                      },
                      selectedColor: DSColors.brand.withValues(alpha: 0.2),
                      checkmarkColor: DSColors.brand,
                      backgroundColor: DSColors.appCard,
                      side: BorderSide(
                        color: selected ? DSColors.brand : DSColors.appBorder,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    );
                  }).toList(),
                ),
                const SizedBox(height: 40),
                DSButton(
                  label: 'Continue to Assessment',
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
    );
  }
}

class _SupportSelector extends StatelessWidget {
  const _SupportSelector({
    required this.selected,
    required this.onChanged,
  });

  final String selected;
  final ValueChanged<String> onChanged;

  static const _options = [
    ('Low', Icons.sentiment_dissatisfied_rounded, DSColors.error),
    ('Moderate', Icons.sentiment_neutral_rounded, DSColors.warning),
    ('High', Icons.sentiment_satisfied_rounded, DSColors.success),
  ];

  @override
  Widget build(BuildContext context) {
    return Row(
      children: _options.map((opt) {
        final (label, icon, color) = opt;
        final isSelected = selected == label;
        return Expanded(
          child: GestureDetector(
            onTap: () => onChanged(label),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 150),
              margin: const EdgeInsets.only(right: 8),
              padding: const EdgeInsets.symmetric(vertical: 16),
              decoration: BoxDecoration(
                color: isSelected
                    ? color.withValues(alpha: 0.15)
                    : DSColors.appCard,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: isSelected ? color : DSColors.appBorder,
                  width: isSelected ? 2 : 1,
                ),
              ),
              child: Column(
                children: [
                  Icon(icon,
                      color: isSelected ? color : DSColors.textMuted, size: 28),
                  const SizedBox(height: 6),
                  Text(
                    label,
                    style: DSTypography.labelMedium.copyWith(
                      color: isSelected ? color : DSColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      }).toList(),
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
