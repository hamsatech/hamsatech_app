import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:hamsatech_design_system/hamsatech_design_system.dart';
import '../../../../core/di/injection.dart';
import '../bloc/auth_bloc.dart';
import '../bloc/auth_event.dart';
import '../bloc/auth_state.dart';

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => getIt<AuthBloc>(),
      child: const _LoginView(),
    );
  }
}

class _LoginView extends StatefulWidget {
  const _LoginView();

  @override
  State<_LoginView> createState() => _LoginViewState();
}

class _LoginViewState extends State<_LoginView> {
  final _controller = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _submit(BuildContext context) {
    if (!_formKey.currentState!.validate()) return;
    context.read<AuthBloc>().add(AuthSendOtpRequested(_controller.text.trim()));
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthBloc, AuthState>(
      listener: (context, state) {
        if (state is AuthOtpSent) {
          context.push('/otp', extra: state.phoneOrEmail);
        } else if (state is AuthFailure) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(state.message), backgroundColor: DSColors.error),
          );
        }
      },
      child: Scaffold(
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Spacer(flex: 2),
                  Container(
                    width: 56,
                    height: 56,
                    decoration: BoxDecoration(
                      color: DSColors.brand,
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: const Icon(Icons.gps_fixed_rounded, color: Colors.white, size: 30),
                  ),
                  const SizedBox(height: 32),
                  Text('Welcome back,', style: DSTypography.displayMedium),
                  const SizedBox(height: 8),
                  Text(
                    'Sign in to your training account',
                    style: DSTypography.bodyMedium.copyWith(color: DSColors.textSecondary),
                  ),
                  const SizedBox(height: 40),
                  DSTextInput(
                    controller: _controller,
                    label: 'Phone number or Email',
                    placeholder: 'Enter your phone or email',
                    prefixIcon: const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 12),
                      child: Icon(Icons.person_outline_rounded, size: 20, color: DSColors.textMuted),
                    ),
                    keyboardType: TextInputType.emailAddress,
                    textInputAction: TextInputAction.done,
                    onSubmitted: (_) => _submit(context),
                    validator: (v) {
                      if (v == null || v.trim().isEmpty) {
                        return 'Please enter your phone or email';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Demo: any phone/email works. OTP is 1234.',
                    style: DSTypography.caption,
                  ),
                  const SizedBox(height: 32),
                  BlocBuilder<AuthBloc, AuthState>(
                    builder: (context, state) => DSButton(
                      label: 'Send OTP',
                      onPressed: () => _submit(context),
                      isLoading: state is AuthOtpSending,
                      isFullWidth: true,
                      leadingIcon: const Icon(Icons.send_rounded),
                    ),
                  ),
                  const Spacer(flex: 3),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
