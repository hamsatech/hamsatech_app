import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/di/injection.dart';
import '../../../../core/services/storage_service.dart';
import '../bloc/auth_bloc.dart';
import '../bloc/auth_event.dart';
import '../bloc/auth_state.dart';
import '../widgets/auth_numpad.dart';

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
  String _otp = '';
  static const int _length = 4;

  void _onDigit(String d) {
    if (_otp.length >= _length) return;
    setState(() => _otp += d);
    if (_otp.length == _length) {
      Future.delayed(const Duration(milliseconds: 80), () => _submit());
    }
  }

  void _onDelete() {
    if (_otp.isEmpty) return;
    setState(() => _otp = _otp.substring(0, _otp.length - 1));
  }

  void _submit() {
    if (_otp.length != _length) return;
    HapticFeedback.lightImpact();
    context.read<AuthBloc>().add(AuthVerifyOtpRequested(
          phoneOrEmail: widget.phoneOrEmail,
          otp: _otp,
        ));
  }

  String get _maskedContact {
    final s = widget.phoneOrEmail;
    if (s.length <= 5) return s;
    return '${s.substring(0, 3)}-${'•' * 3}-${s.substring(s.length - 4)}';
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthBloc, AuthState>(
      listener: (context, state) {
        if (state is AuthAuthenticated) {
          final isProfileDone = StorageService.isOnboardingComplete();
          context.go(isProfileDone ? '/home' : '/profile/setup');
        } else if (state is AuthFailure) {
          setState(() => _otp = '');
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
                        onTap: () => context.pop(),
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
                      Center(child: _EnvelopeIllustration()),
                      const SizedBox(height: 28),
                      // Heading
                      const Center(
                        child: Text(
                          'Enter your verification\ncode',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.w700,
                            color: Color(0xFF0D1F2D),
                            height: 1.3,
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),
                      // Sent to
                      Center(
                        child: RichText(
                          text: TextSpan(
                            style: TextStyle(
                                fontSize: 13, color: const Color(0xFF6B7C8D)),
                            children: [
                              TextSpan(text: 'Sent to $_maskedContact. '),
                              WidgetSpan(
                                child: GestureDetector(
                                  onTap: () => context.pop(),
                                  child: const Text(
                                    'Edit',
                                    style: TextStyle(
                                      fontSize: 13,
                                      fontWeight: FontWeight.w600,
                                      color: Color(0xFF14B8A6),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 32),
                      // OTP Boxes
                      Center(child: _OtpBoxRow(otp: _otp, length: _length)),
                      const SizedBox(height: 20),
                      // Didn't get code
                      Center(
                        child: GestureDetector(
                          onTap: () => context.read<AuthBloc>().add(
                                AuthSendOtpRequested(widget.phoneOrEmail),
                              ),
                          child: const Text(
                            "Didn't get a code?",
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                              color: Color(0xFF14B8A6),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),
                      // Continue button
                      BlocBuilder<AuthBloc, AuthState>(
                        builder: (context, state) => _ContinueButton(
                          enabled: _otp.length == _length,
                          isLoading: state is AuthVerifying,
                          onTap: _submit,
                        ),
                      ),
                      const SizedBox(height: 8),
                    ],
                  ),
                ),
              ),
            ),
            // Custom numpad
            AuthNumpad(onDigit: _onDigit, onDelete: _onDelete),
          ],
        ),
      ),
    );
  }
}

// ── OTP Box Row ───────────────────────────────────────────────────────────────

class _OtpBoxRow extends StatelessWidget {
  const _OtpBoxRow({required this.otp, required this.length});

  final String otp;
  final int length;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(length, (i) {
        final filled = i < otp.length;
        final active = i == otp.length;
        return AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          width: 60,
          height: 68,
          margin: const EdgeInsets.symmetric(horizontal: 6),
          decoration: BoxDecoration(
            color: filled
                ? const Color(0xFF14B8A6).withValues(alpha: 0.08)
                : const Color(0xFFF5F8FA),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: filled
                  ? const Color(0xFF14B8A6)
                  : active
                      ? const Color(0xFF0D1F2D)
                      : const Color(0xFFE0E7EF),
              width: (filled || active) ? 2 : 1.5,
            ),
          ),
          child: Center(
            child: filled
                ? Text(
                    otp[i],
                    style: const TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF0D1F2D),
                    ),
                  )
                : active
                    ? _BlinkingCursor()
                    : null,
          ),
        );
      }),
    );
  }
}

class _BlinkingCursor extends StatefulWidget {
  @override
  State<_BlinkingCursor> createState() => _BlinkingCursorState();
}

class _BlinkingCursorState extends State<_BlinkingCursor>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _ctrl,
      child: Container(
        width: 2,
        height: 28,
        decoration: BoxDecoration(
          color: const Color(0xFF14B8A6),
          borderRadius: BorderRadius.circular(2),
        ),
      ),
    );
  }
}

// ── Envelope Illustration ─────────────────────────────────────────────────────

class _EnvelopeIllustration extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 120,
      height: 100,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Envelope body
          Container(
            width: 80,
            height: 58,
            decoration: BoxDecoration(
              border: Border.all(color: const Color(0xFF0D1F2D), width: 2.5),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Column(
              children: [
                // envelope flap lines
                const SizedBox(height: 6),
                Container(
                  height: 2,
                  margin: const EdgeInsets.symmetric(horizontal: 12),
                  color: const Color(0xFF0D1F2D).withValues(alpha: 0.2),
                ),
                const SizedBox(height: 5),
                Container(
                  height: 2,
                  margin: const EdgeInsets.symmetric(horizontal: 12),
                  color: const Color(0xFF0D1F2D).withValues(alpha: 0.2),
                ),
              ],
            ),
          ),
          // Envelope flap (V shape using a triangle)
          Positioned(
            top: 12,
            child: CustomPaint(
              size: const Size(76, 26),
              painter: _EnvelopeFlapPainter(),
            ),
          ),
          // Floating star badge
          Positioned(
            top: 2,
            right: 8,
            child: Container(
              width: 28,
              height: 28,
              decoration: BoxDecoration(
                color: const Color(0xFF14B8A6),
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF14B8A6).withValues(alpha: 0.35),
                    blurRadius: 8,
                  ),
                ],
              ),
              child: const Icon(Icons.check_rounded,
                  size: 14, color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }
}

class _EnvelopeFlapPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFF0D1F2D)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.5
      ..strokeCap = StrokeCap.round;

    final path = Path()
      ..moveTo(0, 0)
      ..lineTo(size.width / 2, size.height)
      ..lineTo(size.width, 0);

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(_) => false;
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
        opacity: enabled ? 1.0 : 0.45,
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
