import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:hamsatech_design_system/hamsatech_design_system.dart';

import '../../../../core/di/injection.dart';
import '../../../../core/services/storage_service.dart';
import '../../../dashboard/presentation/bloc/dashboard_bloc.dart';
import '../../../dashboard/presentation/bloc/dashboard_event.dart';
import '../../domain/entities/alex_summary_entity.dart';
import '../bloc/alex_summary_bloc.dart';
import '../bloc/alex_summary_event.dart';
import '../bloc/alex_summary_state.dart';

class AlexSummaryScreen extends StatelessWidget {
  const AlexSummaryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => AlexSummaryBloc()..add(const AlexSummaryLoadRequested()),
      child: const _AlexSummaryView(),
    );
  }
}

class _AlexSummaryView extends StatelessWidget {
  const _AlexSummaryView();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AlexSummaryBloc, AlexSummaryState>(
      builder: (context, state) {
        return Scaffold(
          backgroundColor: DSColors.white,
          body: SafeArea(
            child: switch (state.status) {
              AlexSummaryStatus.initial ||
              AlexSummaryStatus.loading =>
                const Center(
                  child: CircularProgressIndicator(color: Color(0xFF2F7E8F)),
                ),
              AlexSummaryStatus.error => _ErrorState(
                  message: state.errorMessage ?? 'Unable to load summary',
                ),
              AlexSummaryStatus.loaded => _LoadedState(
                  summary: state.summary!,
                ),
            },
          ),
        );
      },
    );
  }
}

class _LoadedState extends StatelessWidget {
  const _LoadedState({required this.summary});

  final AlexSummaryEntity summary;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: DSSpacing.xxl),
            child: ConstrainedBox(
              constraints: BoxConstraints(
                minHeight: MediaQuery.sizeOf(context).height * 0.72,
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const _TopIcon(),
                  const SizedBox(height: DSSpacing.xxl),
                  Text(
                    'You’re all set, Alex',
                    textAlign: TextAlign.center,
                    style: DSTypography.headingXl.copyWith(
                      color: DSColors.textPrimary,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: DSSpacing.sm),
                  Text(
                    'Here\'s your starting point:',
                    textAlign: TextAlign.center,
                    style: DSTypography.headingLg.copyWith(
                      color: DSColors.textSecondary,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                  const SizedBox(height: 54),
                  _SummaryCard(summary: summary),
                ],
              ),
            ),
          ),
        ),
        const _Footer(),
      ],
    );
  }
}

class _TopIcon extends StatelessWidget {
  const _TopIcon();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 86,
      height: 86,
      decoration: const BoxDecoration(
        color: Color(0xFF2F7E8F),
        shape: BoxShape.circle,
      ),
      child: const Icon(
        Icons.wifi_rounded,
        color: DSColors.white,
        size: 48,
      ),
    );
  }
}

class _SummaryCard extends StatelessWidget {
  const _SummaryCard({required this.summary});

  final AlexSummaryEntity summary;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: DSColors.white,
        borderRadius: DSRadius.borderMd,
        border: Border.all(color: DSColors.gray200),
      ),
      child: Column(
        children: [
          _SummaryRow(label: 'Discipline', value: summary.discipline),
          const _Divider(),
          _SummaryRow(label: 'Goal', value: summary.goal),
          const _Divider(),
          _SummaryRow(label: 'Resting HR', value: summary.restingHr),
        ],
      ),
    );
  }
}

class _SummaryRow extends StatelessWidget {
  const _SummaryRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: DSSpacing.xxl,
        vertical: 17,
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(
              label,
              style: DSTypography.headingLg.copyWith(
                color: DSColors.textSecondary,
                fontWeight: FontWeight.w400,
              ),
            ),
          ),
          Text(
            value,
            style: DSTypography.headingLg.copyWith(
              color: DSColors.gray900,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

class _Divider extends StatelessWidget {
  const _Divider();

  @override
  Widget build(BuildContext context) {
    return const Divider(
      height: 1,
      thickness: 1,
      indent: DSSpacing.xxl,
      endIndent: DSSpacing.xxl,
      color: Color(0xFFE2F4F7),
    );
  }
}

class _Footer extends StatelessWidget {
  const _Footer();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(
        DSSpacing.xxl,
        27,
        DSSpacing.xxl,
        DSSpacing.xxl,
      ),
      decoration: const BoxDecoration(
        color: DSColors.white,
        border: Border(
          top: BorderSide(color: DSColors.gray300),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            'Ready to train',
            style: DSTypography.headingLg.copyWith(
              color: DSColors.textPrimary,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: DSSpacing.xxl),
          DSPrimaryButton(
            label: 'Go to Home',
            color: DSColors.terracotta,
            onPressed: () async {
              await StorageService.setOnboardingComplete(true);
              getIt<DashboardBloc>().add(const DashboardRefreshRequested());
              if (context.mounted) context.go('/home');
            },
          ),
        ],
      ),
    );
  }
}

class _ErrorState extends StatelessWidget {
  const _ErrorState({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(DSSpacing.xxl),
        child: Text(
          message,
          textAlign: TextAlign.center,
          style: DSTypography.bodyLarge.copyWith(color: DSColors.error),
        ),
      ),
    );
  }
}
