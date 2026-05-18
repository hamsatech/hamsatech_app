import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:go_router/go_router.dart';
import 'package:hamsatech_design_system/hamsatech_design_system.dart';

import '../../data/repositories/sign_up_repository_impl.dart';
import '../bloc/sign_up_bloc.dart';
import '../bloc/sign_up_event.dart';
import '../bloc/sign_up_state.dart';
import '../viewmodels/sign_up_view_model.dart';

class SignUpScreen extends StatelessWidget {
  const SignUpScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => SignUpBloc(
        SignUpViewModel(const SignUpRepositoryImpl()),
      ),
      child: const _SignUpView(),
    );
  }
}

class _SignUpView extends StatelessWidget {
  const _SignUpView();

  static const _brand = DSColors.terracotta;

  void _handleState(BuildContext context, SignUpState state) {
    switch (state.status) {
      case SignUpStatus.navigateToPhone:
        context.go('/login');
      case SignUpStatus.comingSoon:
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Coming soon!',
              style: DSTypography.bodyMd.copyWith(color: Colors.white),
            ),
            backgroundColor: DSColors.gray700,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(DSRadius.md)),
          ),
        );
      case SignUpStatus.failure:
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              state.errorMessage ?? 'Something went wrong.',
              style: DSTypography.bodyMd.copyWith(color: Colors.white),
            ),
            backgroundColor: DSColors.error,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(DSRadius.md)),
          ),
        );
      default:
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<SignUpBloc, SignUpState>(
      listenWhen: (prev, curr) => curr.status != prev.status,
      listener: _handleState,
      child: Scaffold(
        backgroundColor: DSColors.appBackground,
        appBar: AppBar(
          backgroundColor: DSColors.appBackground,
          elevation: 0,
          scrolledUnderElevation: 0,
          leading: IconButton(
            onPressed: () => context.go('/welcome'),
            icon: const Icon(Icons.arrow_back_ios_new_rounded,
                size: 18, color: Color(0xFF000F12)),
          ),
          title: Text(
            SignUpViewModel.screenTitle,
            style:
                DSTypography.headingMd.copyWith(color: const Color(0xFF000F12)),
          ),
          centerTitle: true,
        ),
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SizedBox(height: MediaQuery.of(context).size.height * 0.17),
                Text(
                  SignUpViewModel.welcomeTitle,
                  style: DSTypography.onboardingCaption.copyWith(
                    color: const Color(0xFF000F12),
                    height: 1.25,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 12),
                Text(
                  SignUpViewModel.welcomeSubtitle,
                  style: DSTypography.bodyMedium.copyWith(
                    color: const Color(0x99000F12),
                    height: 1.5,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 40),
                BlocBuilder<SignUpBloc, SignUpState>(
                  buildWhen: (prev, curr) => curr.status != prev.status,
                  builder: (context, state) {
                    final isLoading = state.status == SignUpStatus.loading;
                    return DSPrimaryButton(
                      label: SignUpViewModel.continueLabel,
                      color: _brand,
                      isLoading: isLoading,
                      onPressed: isLoading
                          ? () {}
                          : () => context
                              .read<SignUpBloc>()
                              .add(const SignUpContinueTapped()),
                      textStyle: DSTypography.headingMd
                          .copyWith(color: Colors.white, letterSpacing: 0.2),
                    );
                  },
                ),
                const SizedBox(height: 24),
                _OrDivider(label: SignUpViewModel.orDividerLabel),
                const SizedBox(height: 24),
                BlocBuilder<SignUpBloc, SignUpState>(
                  buildWhen: (prev, curr) => curr.status != prev.status,
                  builder: (context, state) {
                    final isLoading = state.status == SignUpStatus.loading;
                    return Column(
                      children: [
                        _SocialAuthButton(
                          label: SignUpViewModel.googleLabel,
                          icon: SvgPicture.asset(
                            'assets/icons/google_logo.svg',
                            width: 20,
                            height: 20,
                          ),
                          onPressed: isLoading
                              ? null
                              : () => context
                                  .read<SignUpBloc>()
                                  .add(const SignUpGoogleTapped()),
                        ),
                        const SizedBox(height: 12),
                        _SocialAuthButton(
                          label: SignUpViewModel.appleLabel,
                          icon: const FaIcon(
                            FontAwesomeIcons.apple,
                            size: 22,
                            color: Color(0xFF000F12),
                          ),
                          onPressed: isLoading
                              ? null
                              : () => context
                                  .read<SignUpBloc>()
                                  .add(const SignUpAppleTapped()),
                        ),
                      ],
                    );
                  },
                ),
                const Spacer(),
                _PrivacyText(
                  prefix: SignUpViewModel.privacyPrefix,
                  linkLabel: SignUpViewModel.privacyLinkLabel,
                  linkColor: _brand,
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

// ── OR Divider ────────────────────────────────────────────────────────────────

class _OrDivider extends StatelessWidget {
  const _OrDivider({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const Expanded(child: Divider(color: Color(0xFFCAE8EE), thickness: 1)),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Text(
            label,
            style:
                DSTypography.labelMd.copyWith(color: const Color(0x99000F12)),
          ),
        ),
        const Expanded(child: Divider(color: Color(0xFFCAE8EE), thickness: 1)),
      ],
    );
  }
}

// ── Social Auth Button ────────────────────────────────────────────────────────

class _SocialAuthButton extends StatelessWidget {
  const _SocialAuthButton({
    required this.label,
    required this.icon,
    required this.onPressed,
  });

  final String label;
  final Widget icon;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 52,
      child: OutlinedButton(
        onPressed: onPressed,
        style: OutlinedButton.styleFrom(
          side: const BorderSide(color: Color(0xFFB0D8E0), width: 1.2),
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(DSRadius.xl)),
          backgroundColor: DSColors.appBackground,
          foregroundColor: const Color(0xFF000F12),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            icon,
            const SizedBox(width: 10),
            Text(
              label,
              style: DSTypography.headingSm
                  .copyWith(color: const Color(0xFF000F12)),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Privacy Text ──────────────────────────────────────────────────────────────

class _PrivacyText extends StatelessWidget {
  const _PrivacyText({
    required this.prefix,
    required this.linkLabel,
    required this.linkColor,
  });

  final String prefix;
  final String linkLabel;
  final Color linkColor;

  @override
  Widget build(BuildContext context) {
    return RichText(
      textAlign: TextAlign.center,
      text: TextSpan(
        style: DSTypography.bodySm.copyWith(
          color: const Color(0x99000F12),
          height: 1.6,
        ),
        children: [
          TextSpan(text: prefix),
          TextSpan(
            text: linkLabel,
            style: DSTypography.bodySm.copyWith(
              color: linkColor,
              fontWeight: FontWeight.w600,
              decoration: TextDecoration.underline,
              decorationColor: linkColor,
            ),
          ),
          const TextSpan(text: '.'),
        ],
      ),
    );
  }
}
