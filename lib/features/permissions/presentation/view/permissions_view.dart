import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:hamsatech_design_system/hamsatech_design_system.dart';

import '../bloc/permissions_bloc.dart';
import '../bloc/permissions_event.dart';
import '../bloc/permissions_state.dart';

// ── Public reusable card (3 states: initial → loading → granted) ────────────

class PermissionItemCard extends StatelessWidget {
  const PermissionItemCard({
    super.key,
    required this.iconData,
    required this.iconColor,
    required this.iconBgColor,
    required this.title,
    required this.subtitle,
    required this.status,
    required this.onTap,
    this.badge,
  });

  final IconData iconData;
  final Color iconColor;
  final Color iconBgColor;
  final String title;
  final String subtitle;
  final PermissionStatus status;
  final VoidCallback onTap;
  final String? badge;

  @override
  Widget build(BuildContext context) {
    final isGranted = status == PermissionStatus.granted;
    final isLoading = status == PermissionStatus.loading;

    return GestureDetector(
      // Block re-taps when loading or already granted
      onTap: (isLoading || isGranted) ? null : onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
        padding: const EdgeInsets.all(DSSpacing.lg),
        decoration: BoxDecoration(
          color: isGranted
              ? DSColors.success.withValues(alpha: 0.05)
              : Colors.white,
          border: Border.all(
            color: isGranted ? DSColors.success : DSColors.gray200,
            width: isGranted ? 1.5 : 1.0,
          ),
          borderRadius: DSRadius.borderLg,
        ),
        child: Row(
          children: [
            // ── Leading icon ───────────────────────────────────────────────
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: iconBgColor,
                borderRadius: DSRadius.borderMd,
              ),
              child: Icon(iconData, color: iconColor, size: 22),
            ),
            const SizedBox(width: DSSpacing.md),

            // ── Title + subtitle ────────────────────────────────────────────
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        title,
                        style: DSTypography.headingSm
                            .copyWith(color: DSColors.gray900),
                      ),
                      if (badge != null) ...[
                        const SizedBox(width: DSSpacing.sm),
                        _OptionalBadge(label: badge!),
                      ],
                    ],
                  ),
                  const SizedBox(height: DSSpacing.xxs),
                  Text(
                    subtitle,
                    style:
                        DSTypography.bodySm.copyWith(color: DSColors.gray500),
                  ),
                ],
              ),
            ),
            const SizedBox(width: DSSpacing.sm),

            // ── Trailing: arrow | spinner | check ──────────────────────────
            _TrailingIndicator(status: status),
          ],
        ),
      ),
    );
  }
}

// ── Trailing widget with animated switch between all 3 states ───────────────

class _TrailingIndicator extends StatelessWidget {
  const _TrailingIndicator({required this.status});

  final PermissionStatus status;

  @override
  Widget build(BuildContext context) {
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 250),
      switchInCurve: Curves.easeIn,
      switchOutCurve: Curves.easeOut,
      child: switch (status) {
        PermissionStatus.initial => const Icon(
            Icons.chevron_right,
            key: ValueKey('arrow'),
            color: DSColors.gray400,
            size: 20,
          ),
        PermissionStatus.loading => const SizedBox(
            key: ValueKey('spinner'),
            width: 20,
            height: 20,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              valueColor: AlwaysStoppedAnimation<Color>(DSColors.gray400),
            ),
          ),
        PermissionStatus.granted => const Icon(
            Icons.check_circle,
            key: ValueKey('check'),
            color: DSColors.success,
            size: 22,
          ),
      },
    );
  }
}

// ── Optional badge pill ─────────────────────────────────────────────────────

class _OptionalBadge extends StatelessWidget {
  const _OptionalBadge({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: DSSpacing.sm,
        vertical: DSSpacing.xxs,
      ),
      decoration: BoxDecoration(
        border: Border.all(color: DSColors.gray300),
        borderRadius: DSRadius.borderFull,
      ),
      child: Text(
        label,
        style: DSTypography.labelXs.copyWith(color: DSColors.gray500),
      ),
    );
  }
}

// ── Main view ────────────────────────────────────────────────────────────────

class PermissionsView extends StatelessWidget {
  const PermissionsView({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<PermissionsBloc, PermissionsState>(
      listenWhen: (prev, curr) =>
          prev.formStatus != curr.formStatus ||
          (curr.errorMessage != null &&
              prev.errorMessage != curr.errorMessage),
      listener: (context, state) {
        if (state.isContinueSuccess) {
          context.push('/next-screen');
        } else if (state.errorMessage != null) {
          ScaffoldMessenger.of(context)
            ..hideCurrentSnackBar()
            ..showSnackBar(
              SnackBar(
                content: Text(
                  state.errorMessage!,
                  style: DSTypography.bodySm.copyWith(color: DSColors.white),
                ),
                backgroundColor: DSColors.gray900,
                behavior: SnackBarBehavior.floating,
                shape: RoundedRectangleBorder(
                  borderRadius: DSRadius.borderMd,
                ),
              ),
            );
        }
      },
      builder: (context, state) {
        final bloc = context.read<PermissionsBloc>();
        return Scaffold(
          backgroundColor: Colors.white,
          body: SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(
                DSSpacing.lg,
                DSSpacing.xxxl,
                DSSpacing.lg,
                DSSpacing.lg,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _HeaderSection(state: state),
                  const SizedBox(height: DSSpacing.xxxl),
                  _DividerWithLabel(label: state.dividerLabel),
                  const SizedBox(height: DSSpacing.xxl),
                  _PermissionsList(bloc: bloc, state: state),
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

// ── Header ────────────────────────────────────────────────────────────────────

class _HeaderSection extends StatelessWidget {
  const _HeaderSection({required this.state});

  final PermissionsState state;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 60,
          height: 60,
          decoration: BoxDecoration(
            color: DSColors.coral.withValues(alpha: 0.15),
            borderRadius: DSRadius.borderXl,
          ),
          child: const Icon(Icons.favorite, color: DSColors.coral, size: 28),
        ),
        const SizedBox(height: DSSpacing.lg),
        Text(
          state.headerTitle,
          style: DSTypography.displaySm.copyWith(
            color: DSColors.gray900,
            letterSpacing: -0.5,
          ),
        ),
        const SizedBox(height: DSSpacing.sm),
        Text(
          state.headerSubtitle,
          style: DSTypography.bodyMd.copyWith(color: DSColors.gray500),
        ),
      ],
    );
  }
}

// ── Divider with centred label ────────────────────────────────────────────────

class _DividerWithLabel extends StatelessWidget {
  const _DividerWithLabel({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const Expanded(child: Divider(color: DSColors.gray200, thickness: 1)),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: DSSpacing.md),
          child: Text(
            label,
            style: DSTypography.labelSm.copyWith(color: DSColors.gray500),
          ),
        ),
        const Expanded(child: Divider(color: DSColors.gray200, thickness: 1)),
      ],
    );
  }
}

// ── Permission cards list ─────────────────────────────────────────────────────

class _PermissionsList extends StatelessWidget {
  const _PermissionsList({required this.bloc, required this.state});

  final PermissionsBloc bloc;
  final PermissionsState state;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        PermissionItemCard(
          iconData: Icons.bluetooth,
          iconColor: DSColors.info,
          iconBgColor: DSColors.info.withValues(alpha: 0.1),
          title: state.bluetoothTitle,
          subtitle: state.bluetoothSubtitle,
          status: state.bluetooth,
          onTap: () => bloc.add(const OnBluetoothTapped()),
        ),
        const SizedBox(height: DSSpacing.md),
        PermissionItemCard(
          iconData: Icons.notifications_outlined,
          iconColor: DSColors.warning,
          iconBgColor: DSColors.warning.withValues(alpha: 0.1),
          title: state.notificationsTitle,
          subtitle: state.notificationsSubtitle,
          status: state.notifications,
          onTap: () => bloc.add(const OnNotificationsTapped()),
        ),
        const SizedBox(height: DSSpacing.md),
        PermissionItemCard(
          iconData: Icons.mic_outlined,
          iconColor: DSColors.success,
          iconBgColor: DSColors.success.withValues(alpha: 0.1),
          title: state.microphoneTitle,
          subtitle: state.microphoneSubtitle,
          status: state.microphone,
          badge: state.microphoneOptionalBadge,
          onTap: () => bloc.add(const OnMicrophoneTapped()),
        ),
      ],
    );
  }
}

// ── Bottom CTA ────────────────────────────────────────────────────────────────

class _BottomSection extends StatelessWidget {
  const _BottomSection({required this.bloc, required this.state});

  final PermissionsBloc bloc;
  final PermissionsState state;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      minimum: const EdgeInsets.only(bottom: DSSpacing.md),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(
          DSSpacing.lg,
          DSSpacing.xs,
          DSSpacing.lg,
          DSSpacing.xxs,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            DSPrimaryButton(
              label: state.ctaLabel,
              color: DSColors.terracotta,
              isLoading: state.isContinueLoading,
              onPressed: state.isContinueLoading
                  ? null
                  : () => bloc.add(const OnContinuePressed()),
            ),
            const SizedBox(height: DSSpacing.xs),
            DSSecondaryTextButton(
              label: state.secondaryLabel,
              color: DSColors.gray500,
              onPressed: () {},
            ),
          ],
        ),
      ),
    );
  }
}
