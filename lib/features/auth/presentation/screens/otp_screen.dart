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
          context.go('/onboarding/details');
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
        appBar: AppBar(
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios_new_rounded),
            onPressed: () => context.pop(),
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
                  'Enter the 4-digit code sent to\n${widget.phoneOrEmail}',
                  style: AppTextStyles.bodyMedium
                      .copyWith(color: AppColors.textSecondary),
                ),
                const SizedBox(height: 48),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: List.generate(4, (i) => _OtpBox(
                    controller: _controllers[i],
                    focusNode: _focusNodes[i],
                    autofocus: i == 0,
                    onChanged: (v) => _onDigitEntered(i, v),
                    onKeyEvent: (e) => _onKeyEvent(i, e),
                  )),
                ),
                const SizedBox(height: 48),
                BlocBuilder<AuthBloc, AuthState>(
                  builder: (context, state) => AppButton(
                    label: 'Verify & Continue',
                    onPressed: () => _submit(context),
                    isLoading: state is AuthVerifying,
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
