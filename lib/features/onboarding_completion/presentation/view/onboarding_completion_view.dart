import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:hamsatech_design_system/hamsatech_design_system.dart';

import '../bloc/onboarding_completion_bloc.dart';
import '../bloc/onboarding_completion_event.dart';
import '../bloc/onboarding_completion_state.dart';

class OnboardingCompletionView extends StatelessWidget {
  const OnboardingCompletionView({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<OnboardingCompletionBloc, OnboardingCompletionState>(
      listenWhen: (prev, curr) => !prev.navigateToHome && curr.navigateToHome,
      listener: (context, _) => context.go('/home'),
      builder: (context, state) {
        final bloc = context.read<OnboardingCompletionBloc>();
        return Scaffold(
          backgroundColor: Colors.white,
          body: SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: DSSpacing.lg),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const Spacer(flex: 2),

                  // ── WiFi / connected icon ──────────────────────────────
                  const _ConnectedIcon(),
                  const SizedBox(height: DSSpacing.xxl),

                  // ── Title ─────────────────────────────────────────────
                  Text(
                    state.titleText,
                    style: DSTypography.headingXl.copyWith(
                      color: DSColors.gray900,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: DSSpacing.sm),

                  // ── Subtitle ──────────────────────────────────────────
                  Text(
                    state.subtitleText,
                    style: DSTypography.bodyMd.copyWith(
                      color: DSColors.gray500,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: DSSpacing.xxxl),

                  // ── Summary card ──────────────────────────────────────
                  _SummaryCard(items: state.summaryItems),

                  const Spacer(flex: 3),
                ],
              ),
            ),
          ),
          bottomNavigationBar: _BottomSection(bloc: bloc, state: state),
        );
      },
    );
  }
}

// ── WiFi icon with outer glow ring ────────────────────────────────────────────

class _ConnectedIcon extends StatelessWidget {
  const _ConnectedIcon();

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.center,
      children: [
        // Outer soft glow
        Container(
          width: 108,
          height: 108,
          decoration: BoxDecoration(
            color: DSColors.info.withValues(alpha: 0.12),
            shape: BoxShape.circle,
          ),
        ),
        // Solid icon circle
        Container(
          width: 76,
          height: 76,
          decoration: const BoxDecoration(
            color: DSColors.info,
            shape: BoxShape.circle,
          ),
          child: const Icon(Icons.wifi, color: Colors.white, size: 34),
        ),
      ],
    );
  }
}

// ── Summary card ──────────────────────────────────────────────────────────────

class _SummaryCard extends StatelessWidget {
  const _SummaryCard({required this.items});

  final List<SummaryItemModel> items;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: DSColors.gray200),
        borderRadius: DSRadius.borderLg,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          for (int i = 0; i < items.length; i++) ...[
            _SummaryRow(item: items[i]),
            if (i < items.length - 1)
              const Divider(
                height: 1,
                thickness: 1,
                color: DSColors.gray200,
                indent: DSSpacing.lg,
                endIndent: DSSpacing.lg,
              ),
          ],
        ],
      ),
    );
  }
}

// ── Single summary row ────────────────────────────────────────────────────────

class _SummaryRow extends StatelessWidget {
  const _SummaryRow({required this.item});

  final SummaryItemModel item;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: DSSpacing.lg,
        vertical: DSSpacing.lg,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            item.label,
            style: DSTypography.bodyMd.copyWith(color: DSColors.gray500),
          ),
          Text(
            item.value,
            style: DSTypography.headingSm.copyWith(
              color: item.isValueHighlighted
                  ? DSColors.terracotta
                  : DSColors.gray900,
            ),
          ),
        ],
      ),
    );
  }
}

// ── Fixed bottom section ──────────────────────────────────────────────────────

class _BottomSection extends StatelessWidget {
  const _BottomSection({required this.bloc, required this.state});

  final OnboardingCompletionBloc bloc;
  final OnboardingCompletionState state;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        border: Border(
          top: BorderSide(color: DSColors.gray200),
        ),
      ),
      child: SafeArea(
        minimum: const EdgeInsets.only(bottom: DSSpacing.md),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(
            DSSpacing.lg,
            DSSpacing.lg,
            DSSpacing.lg,
            DSSpacing.xxs,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                state.readyLabel,
                style: DSTypography.headingMd.copyWith(color: DSColors.gray900),
              ),
              const SizedBox(height: DSSpacing.md),
              DSPrimaryButton(
                label: state.goHomeCta,
                color: DSColors.terracotta,
                onPressed: () => bloc.add(const OnGoHomePressed()),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
