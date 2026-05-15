import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:hamsatech_design_system/hamsatech_design_system.dart';

import '../../../../core/di/injection.dart';
import '../../../../core/services/storage_service.dart';
import '../../../polar/presentation/bloc/polar_bloc.dart';
import '../../../polar/presentation/bloc/polar_state.dart';

class BaselineResultScreen extends StatelessWidget {
  const BaselineResultScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: getIt<PolarBloc>(),
      child: const _BaselineResultView(),
    );
  }
}

class _BaselineResultView extends StatelessWidget {
  const _BaselineResultView();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<PolarBloc, PolarState>(
      builder: (context, state) {
        final bpm = state.latestReading?.bpm ?? 76;

        return Scaffold(
          backgroundColor: DSColors.white,
          body: SafeArea(
            child: Column(
              children: [
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.fromLTRB(24, 196, 24, 24),
                    child: Column(
                      children: [
                        const _SuccessMark(),
                        const SizedBox(height: 46),
                        Text(
                          'Your resting heart rate is',
                          textAlign: TextAlign.center,
                          style: DSTypography.headingLg.copyWith(
                            color: const Color(0xFF000F12),
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                            letterSpacing: 0,
                          ),
                        ),
                        const SizedBox(height: 36),
                        Text(
                          '$bpm',
                          textAlign: TextAlign.center,
                          style: DSTypography.scoreDisplay.copyWith(
                            color: const Color(0xFF15803D),
                            fontSize: 54,
                            fontWeight: FontWeight.w800,
                            height: 1,
                            letterSpacing: 0,
                          ),
                        ),
                        const SizedBox(height: 14),
                        Text(
                          'BPM',
                          style: DSTypography.bodyLarge.copyWith(
                            color: DSColors.textSecondary,
                            fontSize: 16,
                            letterSpacing: 0,
                          ),
                        ),
                        const SizedBox(height: 46),
                        const _SavedCard(),
                      ],
                    ),
                  ),
                ),
                _ResultFooter(
                  onPressed: () async {
                    await StorageService.setOnboardingComplete(true);
                    if (context.mounted) context.go('/alex-summary');
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _SuccessMark extends StatelessWidget {
  const _SuccessMark();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 62,
      height: 62,
      decoration: BoxDecoration(
        color: const Color(0xFFECFDF5),
        shape: BoxShape.circle,
        border: Border.all(color: const Color(0xFF15803D)),
      ),
      child: Center(
        child: Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(
              color: const Color(0xFF15803D),
              width: 2,
            ),
          ),
          child: const Icon(
            Icons.check_rounded,
            color: Color(0xFF15803D),
            size: 26,
          ),
        ),
      ),
    );
  }
}

class _SavedCard extends StatelessWidget {
  const _SavedCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(12, 12, 12, 14),
      decoration: BoxDecoration(
        color: const Color(0xFFF0FDF4),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: const Color(0xFF15803D)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Baseline saved',
            style: DSTypography.headingMd.copyWith(
              color: const Color(0xFF15803D),
              fontSize: 14,
              fontWeight: FontWeight.w700,
              letterSpacing: 0,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'This is your personal baseline. We\'ll use it to\n'
            'detect when stress affects your performance\n'
            'during competition and training.',
            style: DSTypography.bodyMedium.copyWith(
              color: const Color(0xFF166534),
              fontSize: 14,
              height: 1.35,
              letterSpacing: 0,
            ),
          ),
        ],
      ),
    );
  }
}

class _ResultFooter extends StatelessWidget {
  const _ResultFooter({required this.onPressed});

  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(24, 14, 24, 20),
      decoration: const BoxDecoration(
        color: DSColors.white,
        border: Border(top: BorderSide(color: DSColors.gray200)),
      ),
      child: SizedBox(
        height: 52,
        child: ElevatedButton(
          onPressed: onPressed,
          style: ElevatedButton.styleFrom(
            backgroundColor: DSColors.terracotta,
            foregroundColor: DSColors.white,
            elevation: 0,
            shadowColor: Colors.transparent,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(6),
            ),
          ),
          child: Text(
            'Continue',
            style: DSTypography.headingMd.copyWith(
              color: DSColors.white,
              fontWeight: FontWeight.w700,
              letterSpacing: 0,
            ),
          ),
        ),
      ),
    );
  }
}
