import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_otp_text_field/flutter_otp_text_field.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';
import 'package:hamsatech_design_system/hamsatech_design_system.dart';

import '../../../../core/di/injection.dart';
import '../../../../core/services/storage_service.dart';
import '../bloc/auth_bloc.dart';
import '../bloc/auth_event.dart';
import '../bloc/auth_state.dart';
import '../viewmodels/otp_verification_view_model.dart';

class OtpScreen extends StatelessWidget {
  const OtpScreen({super.key, required this.phoneOrEmail});

  final String phoneOrEmail;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => getIt<AuthBloc>(),
      child: _OtpView(phoneOrEmail: phoneOrEmail),
    );
  }
}

// ── View ──────────────────────────────────────────────────────────────────────

class _OtpView extends StatefulWidget {
  const _OtpView({required this.phoneOrEmail});

  final String phoneOrEmail;

  @override
  State<_OtpView> createState() => _OtpViewState();
}

class _OtpViewState extends State<_OtpView> {
  String _otp = '';
  String? _errorText;
  bool _clearText = false;
  List<TextEditingController?> _otpControllers = [];

  void _onCodeChanged(String _) {
    final full = _otpControllers.map((c) => c?.text ?? '').join();
    setState(() {
      _otp = full;
      if (full.isNotEmpty) _errorText = null;
    });
  }

  void _onOtpCompleted(String value) {
    setState(() => _otp = value);
    Future.delayed(const Duration(milliseconds: 80), _submit);
  }

  void _submit() {
    if (_otp.length != OtpVerificationViewModel.otpLength) return;
    HapticFeedback.lightImpact();
    context.read<AuthBloc>().add(AuthVerifyOtpRequested(
          phoneOrEmail: widget.phoneOrEmail,
          otp: _otp,
        ));
  }

  void _resend() {
    context.read<AuthBloc>().add(AuthSendOtpRequested(widget.phoneOrEmail));
  }

  @override
  Widget build(BuildContext context) {
    final displayPhone =
        OtpVerificationViewModel.formatDisplayPhone(widget.phoneOrEmail);
    final isError = _errorText != null;

    return BlocListener<AuthBloc, AuthState>(
      listener: (context, state) {
        if (state is AuthAuthenticated) {
          if (StorageService.isOnboardingComplete()) {
            context.go('/home');
          } else {
            final step = StorageService.getOnboardingStep();
            context.go(step.isNotEmpty ? step : '/onboarding/step1');
          }
        } else if (state is AuthFailure) {
          setState(() {
            _otp = '';
            _errorText = state.message;
            _clearText = true;
          });
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (mounted) setState(() => _clearText = false);
          });
        }
      },
      child: Scaffold(
        backgroundColor: DSColors.appBackground,
        appBar: AppBar(
          backgroundColor: DSColors.appBackground,
          elevation: 0,
          scrolledUnderElevation: 0,
          leading: IconButton(
            onPressed: () => context.go('/login'),
            icon: const Icon(Icons.arrow_back_ios_new_rounded,
                size: 18, color: Color(0xFF000F12)),
          ),
          title: Text(
            OtpVerificationViewModel.screenTitle,
            style:
                DSTypography.headingMd.copyWith(color: const Color(0xFF000F12)),
          ),
          centerTitle: true,
        ),
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 32),
                const _EnvelopeIllustration(),
                const SizedBox(height: 32),
                Text(
                  OtpVerificationViewModel.heading,
                  textAlign: TextAlign.left,
                  style: DSTypography.onboardingCaption
                      .copyWith(color: const Color(0xFF000F12), height: 1.3),
                ),
                const SizedBox(height: 24),
                OtpTextField(
                  numberOfFields: OtpVerificationViewModel.otpLength,
                  showFieldAsBox: true,
                  fieldWidth: 44,
                  borderRadius: BorderRadius.circular(6),
                  borderWidth: 1.0,
                  borderColor: isError ? DSColors.error : DSColors.gray200,
                  enabledBorderColor:
                      isError ? DSColors.error : DSColors.gray200,
                  focusedBorderColor:
                      isError ? DSColors.error : DSColors.gray700,
                  disabledBorderColor: DSColors.gray200,
                  filled: true,
                  fillColor: Colors.white,
                  textStyle: DSTypography.headingMd
                      .copyWith(color: DSColors.textPrimary),
                  cursorColor: DSColors.brand,
                  // phone keyboard commits each char immediately — avoids
                  // Android IME composing-text artefacts that appear as symbols
                  keyboardType: TextInputType.phone,
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  contentPadding: EdgeInsets.zero,
                  autoFocus: false,
                  clearText: _clearText,
                  margin: const EdgeInsets.symmetric(horizontal: 3),
                  mainAxisAlignment: MainAxisAlignment.start,
                  handleControllers: (controllers) {
                    _otpControllers = controllers;
                  },
                  onCodeChanged: _onCodeChanged,
                  onSubmit: _onOtpCompleted,
                ),
                if (isError) ...[
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      const Icon(Icons.info_outline_rounded,
                          size: 12, color: DSColors.error),
                      const SizedBox(width: 3),
                      Flexible(
                        child: Text(
                          _errorText!,
                          style: DSTypography.bodySm
                              .copyWith(color: DSColors.error),
                        ),
                      ),
                    ],
                  ),
                ],
                const SizedBox(height: 16),
                RichText(
                  text: TextSpan(
                    style: DSTypography.bodySm
                        .copyWith(color: const Color(0x99000F12)),
                    children: [
                      TextSpan(
                        text: '${OtpVerificationViewModel.sentToPrefix}'
                            '$displayPhone. ',
                      ),
                      WidgetSpan(
                        alignment: PlaceholderAlignment.middle,
                        child: GestureDetector(
                          onTap: () => context.go('/login'),
                          child: Text(
                            OtpVerificationViewModel.editLabel,
                            style: DSTypography.bodySm.copyWith(
                              color: DSColors.terracotta,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                Center(
                  child: GestureDetector(
                    onTap: _resend,
                    child: Text(
                      OtpVerificationViewModel.resendText,
                      style: DSTypography.labelMd.copyWith(
                        color: DSColors.terracotta,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
                const Spacer(),
                BlocBuilder<AuthBloc, AuthState>(
                  builder: (context, state) {
                    final isLoading = state is AuthVerifying;
                    final isEnabled =
                        _otp.length == OtpVerificationViewModel.otpLength;
                    return AnimatedOpacity(
                      duration: const Duration(milliseconds: 200),
                      opacity: isEnabled ? 1.0 : 0.45,
                      child: DSPrimaryButton(
                        label: OtpVerificationViewModel.continueLabel,
                        color: DSColors.terracotta,
                        isLoading: isLoading,
                        onPressed: (isEnabled && !isLoading) ? _submit : () {},
                        textStyle: DSTypography.headingMd.copyWith(
                          color: Colors.white,
                          letterSpacing: 0.2,
                        ),
                      ),
                    );
                  },
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

// ── Envelope Illustration ─────────────────────────────────────────────────────

class _EnvelopeIllustration extends StatelessWidget {
  const _EnvelopeIllustration();

  @override
  Widget build(BuildContext context) {
    return SvgPicture.asset(
      'assets/icons/message_bird.svg',
      width: 80,
      height: 103,
    );
  }
}
