import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/di/injection.dart';
import '../bloc/auth_bloc.dart';
import '../bloc/auth_event.dart';
import '../bloc/auth_state.dart';
import '../widgets/auth_numpad.dart';

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
  String _phone = '';

  static const int _maxLength = 10;

  void _onDigit(String d) {
    if (_phone.length >= _maxLength) return;
    setState(() => _phone += d);
  }

  void _onDelete() {
    if (_phone.isEmpty) return;
    setState(() => _phone = _phone.substring(0, _phone.length - 1));
  }

  void _submit(BuildContext context) {
    if (_phone.isEmpty) return;
    HapticFeedback.lightImpact();
    context.read<AuthBloc>().add(AuthSendOtpRequested(_phone));
  }

  String get _displayPhone {
    if (_phone.isEmpty) return '123-456-7890';
    // format as XXX-XXX-XXXX
    final digits = _phone.padRight(_maxLength, '·');
    return '${digits.substring(0, 3)}-${digits.substring(3, 6)}-${digits.substring(6)}';
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthBloc, AuthState>(
      listener: (context, state) {
        if (state is AuthOtpSent) {
          context.push('/otp', extra: state.phoneOrEmail);
        } else if (state is AuthFailure) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.message),
              backgroundColor: const Color(0xFFEF4444),
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
            ),
          );
        }
      },
      child: Scaffold(
        backgroundColor: Colors.white,
        body: Column(
          children: [
            Expanded(
              child: SafeArea(
                bottom: false,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 28),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 16),
                      // Back button
                      GestureDetector(
                        onTap: () => context.canPop()
                            ? context.pop()
                            : context.go('/welcome'),
                        child: Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            color: const Color(0xFFF5F8FA),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                                color: const Color(0xFFE0E7EF)),
                          ),
                          child: const Icon(
                            Icons.arrow_back_ios_new_rounded,
                            size: 16,
                            color: Color(0xFF0D1F2D),
                          ),
                        ),
                      ),
                      const SizedBox(height: 32),
                      // Illustration
                      Center(child: _PhoneIllustration()),
                      const SizedBox(height: 28),
                      // Heading
                      const Center(
                        child: Text(
                          'Enter your phone number',
                          style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.w700,
                            color: Color(0xFF0D1F2D),
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),
                      // Country code + phone display
                      Container(
                        decoration: BoxDecoration(
                          border: Border.all(color: const Color(0xFFE0E7EF)),
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 14, vertical: 16),
                              decoration: BoxDecoration(
                                border: Border(
                                  right: BorderSide(
                                      color: const Color(0xFFE0E7EF)),
                                ),
                              ),
                              child: Row(
                                children: [
                                  Text(
                                    '🇮🇳',
                                    style: TextStyle(fontSize: 20),
                                  ),
                                  const SizedBox(width: 6),
                                  const Text(
                                    '+91',
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600,
                                      color: Color(0xFF0D1F2D),
                                    ),
                                  ),
                                  const SizedBox(width: 4),
                                  const Icon(
                                    Icons.keyboard_arrow_down_rounded,
                                    size: 18,
                                    color: Color(0xFF6B7C8D),
                                  ),
                                ],
                              ),
                            ),
                            Expanded(
                              child: Padding(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 16, vertical: 16),
                                child: Text(
                                  _phone.isEmpty ? '123-456-7890' : _displayPhone,
                                  style: TextStyle(
                                    fontSize: 17,
                                    fontWeight: FontWeight.w500,
                                    color: _phone.isEmpty
                                        ? const Color(0xFFB0BEC5)
                                        : const Color(0xFF0D1F2D),
                                    letterSpacing: 1,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        'HamsaTech will send you a text with a verification code.\nMessage and data rates may apply.',
                        style: TextStyle(
                          fontSize: 12,
                          color: const Color(0xFF6B7C8D),
                          height: 1.5,
                        ),
                      ),
                      const SizedBox(height: 4),
                      GestureDetector(
                        onTap: () {},
                        child: const Text(
                          'What if my number changes?',
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w500,
                            color: Color(0xFF14B8A6),
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),
                      // Continue button
                      BlocBuilder<AuthBloc, AuthState>(
                        builder: (context, state) => _ContinueButton(
                          enabled: _phone.isNotEmpty,
                          isLoading: state is AuthOtpSending,
                          onTap: () => _submit(context),
                        ),
                      ),
                      const SizedBox(height: 8),
                    ],
                  ),
                ),
              ),
            ),
            // Custom numpad pinned at bottom
            AuthNumpad(onDigit: _onDigit, onDelete: _onDelete),
          ],
        ),
      ),
    );
  }
}

// ── Phone Illustration ────────────────────────────────────────────────────────

class _PhoneIllustration extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 120,
      height: 100,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Phone body
          Container(
            width: 56,
            height: 90,
            decoration: BoxDecoration(
              border: Border.all(color: const Color(0xFF0D1F2D), width: 2.5),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              children: [
                Container(
                  height: 6,
                  margin: const EdgeInsets.fromLTRB(14, 6, 14, 0),
                  decoration: BoxDecoration(
                    color: const Color(0xFF0D1F2D),
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
                const Spacer(),
                Container(
                  width: 20,
                  height: 20,
                  margin: const EdgeInsets.only(bottom: 8),
                  decoration: BoxDecoration(
                    border: Border.all(color: const Color(0xFF0D1F2D), width: 2),
                    borderRadius: BorderRadius.circular(5),
                  ),
                  child: const Icon(Icons.chat_bubble_outline_rounded,
                      size: 10, color: Color(0xFF0D1F2D)),
                ),
              ],
            ),
          ),
          // Floating bubble top-right
          Positioned(
            top: 0,
            right: 0,
            child: Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: const Color(0xFF14B8A6),
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF14B8A6).withValues(alpha: 0.3),
                    blurRadius: 8,
                  ),
                ],
              ),
              child: const Icon(Icons.message_rounded,
                  size: 14, color: Colors.white),
            ),
          ),
          // Floating bubble top-left
          Positioned(
            top: 8,
            left: 4,
            child: Container(
              padding: const EdgeInsets.all(5),
              decoration: BoxDecoration(
                color: const Color(0xFFF0F4F7),
                shape: BoxShape.circle,
                border: Border.all(color: const Color(0xFFE0E7EF)),
              ),
              child: const Icon(Icons.lock_outline_rounded,
                  size: 12, color: Color(0xFF6B7C8D)),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Continue Button ───────────────────────────────────────────────────────────

class _ContinueButton extends StatelessWidget {
  const _ContinueButton({
    required this.enabled,
    required this.isLoading,
    required this.onTap,
  });

  final bool enabled;
  final bool isLoading;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 52,
      child: AnimatedOpacity(
        duration: const Duration(milliseconds: 200),
        opacity: enabled ? 1.0 : 0.5,
        child: ElevatedButton(
          onPressed: (enabled && !isLoading) ? onTap : null,
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF14B8A6),
            foregroundColor: Colors.white,
            disabledBackgroundColor: const Color(0xFF14B8A6),
            elevation: 0,
            shadowColor: Colors.transparent,
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14)),
          ),
          child: isLoading
              ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                      color: Colors.white, strokeWidth: 2))
              : const Text(
                  'Continue',
                  style: TextStyle(
                      fontSize: 16, fontWeight: FontWeight.w700),
                ),
        ),
      ),
    );
  }
}
