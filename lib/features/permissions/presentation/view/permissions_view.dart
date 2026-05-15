import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:hamsatech_design_system/hamsatech_design_system.dart';

import '../bloc/permissions_bloc.dart';
import '../bloc/permissions_event.dart';
import '../bloc/permissions_state.dart';

class PermissionsView extends StatelessWidget {
  const PermissionsView({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<PermissionsBloc, PermissionsState>(
      listener: (context, state) {
        if (state.status == PermissionsStatus.success) {
          context.go('/polar');
        }

        if (state.status == PermissionsStatus.error) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                state.message ?? 'Unable to continue',
              ),
              backgroundColor: DSColors.error,
            ),
          );
        }
      },
      builder: (context, state) {
        final bloc = context.read<PermissionsBloc>();

        return Scaffold(
          backgroundColor: DSColors.appBackground,
          body: SafeArea(
            child: Column(
              children: [
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.fromLTRB(
                      DSSpacing.xxl,
                      DSSpacing.huge,
                      DSSpacing.xxl,
                      DSSpacing.xxl,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const _HeroIcon(),

                        const SizedBox(height: DSSpacing.xxl),

                        Text(
                          'Your heart tells\nthe truth',
                          style: DSTypography.displayLarge.copyWith(
                            color: DSColors.black,
                          ),
                        ),

                        const SizedBox(height: DSSpacing.md),

                        Text(
                          'We use your Polar device to measure stress, '
                          'focus, and recovery - so we can show you exactly '
                          'when your mind affects your shot.',
                          style: DSTypography.bodyLarge.copyWith(
                            color: DSColors.textSecondary,
                          ),
                        ),

                        const SizedBox(height: DSSpacing.huge),

                        const _DividerLabel(),

                        const SizedBox(height: DSSpacing.xxl),

                        // Bluetooth
                        PermissionItemCard(
                          icon: Icons.bluetooth_rounded,
                          iconColor: DSColors.info,
                          iconBackgroundColor:
                              DSColors.info.withValues(alpha: 0.10),

                          title: 'Bluetooth',
                          subtitle: 'To connect to Polar',

                          isGranted: state.bluetoothGranted,
                          isLoading: state.bluetoothLoading,

                          onTap: () =>
                              bloc.add(const OnBluetoothTapped()),
                        ),

                        const SizedBox(height: DSSpacing.lg),

                        // Notifications
                        PermissionItemCard(
                          icon: Icons.notifications_none_rounded,
                          iconColor: DSColors.warning,
                          iconBackgroundColor:
                              DSColors.warning.withValues(alpha: 0.10),

                          title: 'Notifications',
                          subtitle: 'For session reminders',

                          isGranted: state.notificationsGranted,
                          isLoading: state.notificationsLoading,

                          onTap: () =>
                              bloc.add(const OnNotificationsTapped()),
                        ),

                        const SizedBox(height: DSSpacing.lg),

                        // Microphone
                        PermissionItemCard(
                          icon: Icons.mic_none_rounded,
                          iconColor: DSColors.success,
                          iconBackgroundColor:
                              DSColors.success.withValues(alpha: 0.10),

                          title: 'Microphone',
                          subtitle: 'For session reminders',

                          badgeLabel: 'Optional',

                          isGranted: state.microphoneGranted,
                          isLoading: state.microphoneLoading,

                          onTap: () =>
                              bloc.add(const OnMicrophoneTapped()),
                        ),
                      ],
                    ),
                  ),
                ),

                _BottomCta(
                  isLoading:
                      state.status == PermissionsStatus.loading,
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class PermissionItemCard extends StatelessWidget {
  const PermissionItemCard({
    super.key,
    required this.icon,
    required this.iconColor,
    required this.iconBackgroundColor,
    required this.title,
    required this.subtitle,
    required this.onTap,
    required this.isGranted,
    required this.isLoading,
    this.badgeLabel,
  });

  final IconData icon;
  final Color iconColor;
  final Color iconBackgroundColor;

  final String title;
  final String subtitle;

  final VoidCallback onTap;

  final bool isGranted;
  final bool isLoading;

  final String? badgeLabel;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: DSColors.white,
      borderRadius: DSRadius.borderLg,
      child: InkWell(
        onTap: isLoading ? null : onTap,
        borderRadius: DSRadius.borderLg,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 250),
          padding: const EdgeInsets.all(DSSpacing.lg),
          decoration: BoxDecoration(
            color: isGranted
                ? DSColors.success.withValues(alpha: 0.05)
                : DSColors.white,

            borderRadius: DSRadius.borderLg,

            border: Border.all(
              color: isGranted
                  ? DSColors.success
                  : DSColors.gray200,

              width: isGranted ? 1.5 : 1,
            ),
          ),
          child: Row(
            children: [
              Container(
                width: DSSpacing.huge,
                height: DSSpacing.huge,
                decoration: BoxDecoration(
                  color: iconBackgroundColor,
                  borderRadius: DSRadius.borderMd,
                ),
                child: Icon(
                  icon,
                  color: iconColor,
                  size: DSSpacing.xxl,
                ),
              ),

              const SizedBox(width: DSSpacing.lg),

              Expanded(
                child: Column(
                  crossAxisAlignment:
                      CrossAxisAlignment.start,

                  mainAxisSize: MainAxisSize.min,

                  children: [
                    Row(
                      children: [
                        Flexible(
                          child: Text(
                            title,
                            style: DSTypography.headingLarge
                                .copyWith(
                              color: DSColors.black,
                            ),
                          ),
                        ),

                        if (badgeLabel != null) ...[
                          const SizedBox(width: DSSpacing.sm),

                          _Badge(label: badgeLabel!),
                        ],
                      ],
                    ),

                    const SizedBox(height: DSSpacing.xs),

                    Text(
                      subtitle,
                      style:
                          DSTypography.bodyLarge.copyWith(
                        color: DSColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(width: DSSpacing.md),

              if (isLoading)
                const SizedBox(
                  width: 22,
                  height: 22,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                  ),
                )
              else if (isGranted)
                const Icon(
                  Icons.check_circle_rounded,
                  color: DSColors.success,
                  size: DSSpacing.xxxl,
                )
              else
                const Icon(
                  Icons.chevron_right_rounded,
                  color: DSColors.black,
                  size: DSSpacing.xxxl,
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _HeroIcon extends StatelessWidget {
  const _HeroIcon();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: DSSpacing.huge + DSSpacing.xxl,
      height: DSSpacing.huge + DSSpacing.xxl,
      decoration: BoxDecoration(
        color: DSColors.errorSurface,
        borderRadius: DSRadius.borderXl,
        border: Border.all(
          color: DSColors.error.withValues(alpha: 0.35),
        ),
      ),
      child: const Icon(
        Icons.favorite_rounded,
        color: DSColors.error,
        size: DSSpacing.huge,
      ),
    );
  }
}

class _DividerLabel extends StatelessWidget {
  const _DividerLabel();

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const Expanded(
          child: Divider(color: DSColors.gray300),
        ),

        Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: DSSpacing.lg,
          ),
          child: Text(
            'To continue, we need',
            style:
                DSTypography.headingMedium.copyWith(
              color: DSColors.textPrimary,
            ),
          ),
        ),

        const Expanded(
          child: Divider(color: DSColors.gray300),
        ),
      ],
    );
  }
}

class _Badge extends StatelessWidget {
  const _Badge({
    required this.label,
  });

  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: DSSpacing.sm,
        vertical: DSSpacing.xxs,
      ),
      decoration: BoxDecoration(
        borderRadius: DSRadius.borderFull,
        border: Border.all(
          color: DSColors.gray200,
        ),
        color: DSColors.white,
      ),
      child: Text(
        label,
        style: DSTypography.caption.copyWith(
          color: DSColors.textSecondary,
        ),
      ),
    );
  }
}

class _BottomCta extends StatelessWidget {
  const _BottomCta({
    required this.isLoading,
  });

  final bool isLoading;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,

      padding: const EdgeInsets.fromLTRB(
        DSSpacing.xxl,
        DSSpacing.xxl,
        DSSpacing.xxl,
        DSSpacing.xxl,
      ),

      decoration: const BoxDecoration(
        color: DSColors.white,
        border: Border(
          top: BorderSide(
            color: DSColors.gray200,
          ),
        ),
      ),

      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          DSButton(
            label: 'Continue & Allow',
            isFullWidth: true,
            size: DSButtonSize.lg,
            isLoading: isLoading,

            onPressed: () {
              context
                  .read<PermissionsBloc>()
                  .add(const OnContinuePressed());
            },
          ),

          const SizedBox(height: DSSpacing.lg),

          DSButton(
            label: 'I don\'t have a polar yet',
            variant: DSButtonVariant.linkSecondary,

            onPressed: () {
              context
                  .read<PermissionsBloc>()
                  .add(const OnContinuePressed());
            },
          ),
        ],
      ),
    );
  }
}