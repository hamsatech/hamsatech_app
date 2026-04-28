import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:hamsatech_design_system/hamsatech_design_system.dart';
import '../../../../core/di/injection.dart';
import '../bloc/auth_bloc.dart';
import '../bloc/auth_event.dart';
import '../bloc/auth_state.dart';

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

class _OtpView extends StatefulWidget {
  const _OtpView({required this.phoneOrEmail});

  final String phoneOrEmail;

  @override
  State<_OtpView> createState() => _OtpViewState();
}

class _OtpViewState extends State<_OtpView> {
  String _currentOtp = '';

  void _submit(BuildContext context) {
    if (_currentOtp.length != 4) return;
    context.read<AuthBloc>().add(AuthVerifyOtpRequested(
          phoneOrEmail: widget.phoneOrEmail,
          otp: _currentOtp,
        ));
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthBloc, AuthState>(
      listener: (context, state) {
        if (state is AuthAuthenticated) {
          context.go('/onboarding/details');
        } else if (state is AuthFailure) {
          setState(() => _currentOtp = '');
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(state.message), backgroundColor: DSColors.error),
          );
        }
      },
      child: Scaffold(
        appBar: AppBar(
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios_new_rounded),
            onPressed: () => context.pop(),
          ),
        ),
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 16),
                Text('Verify your identity', style: DSTypography.displayMedium),
                const SizedBox(height: 12),
                Text(
                  'Enter the 4-digit code sent to\n${widget.phoneOrEmail}',
                  style: DSTypography.bodyMedium.copyWith(color: DSColors.textSecondary),
                ),
                const SizedBox(height: 48),
                DSOtpInput(
                  length: 4,
                  onChanged: (otp) => setState(() => _currentOtp = otp),
                  onCompleted: (_) => _submit(context),
                ),
                const SizedBox(height: 48),
                BlocBuilder<AuthBloc, AuthState>(
                  builder: (context, state) => DSButton(
                    label: 'Verify & Continue',
                    onPressed: _currentOtp.length == 4 ? () => _submit(context) : null,
                    isLoading: state is AuthVerifying,
                    isFullWidth: true,
                  ),
                ),
                const SizedBox(height: 16),
                Center(
                  child: TextButton(
                    onPressed: () => context.read<AuthBloc>().add(
                          AuthSendOtpRequested(widget.phoneOrEmail),
                        ),
                    child: Text(
                      'Resend OTP',
                      style: DSTypography.labelMedium.copyWith(color: DSColors.brand),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
