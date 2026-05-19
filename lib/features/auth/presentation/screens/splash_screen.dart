import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/services/api_service.dart';
import '../../../../core/services/storage_service.dart';
import '../../../../core/widgets/astra_logo.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _fade;
  late Animation<double> _scale;
  late Animation<double> _glowPulse;

  @override
  void initState() {
    super.initState();

    // Force dark status bar icons on the dark splash background.
    SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
      statusBarBrightness: Brightness.dark,
    ));

    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1600),
    );

    _fade = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _ctrl, curve: const Interval(0, 0.45)),
    );

    _scale = Tween<double>(begin: 0.82, end: 1).animate(
      CurvedAnimation(
        parent: _ctrl,
        curve: const Interval(0, 0.55, curve: Curves.easeOutCubic),
      ),
    );

    _glowPulse = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(
        parent: _ctrl,
        curve: const Interval(0.4, 1, curve: Curves.easeOut),
      ),
    );

    _ctrl.forward();
    _navigate();

    // TODO: remove after confirming Supabase connection
    ApiService.instance.getAthletes().then((res) {
      debugPrint('[API TEST] athletes response: ${res.data}');
    }).catchError((Object e) {
      debugPrint('[API TEST] error: $e');
    });
  }

  Future<void> _navigate() async {
    await Future.delayed(const Duration(milliseconds: 2400));
    if (!mounted) return;

    // Restore app-default status bar style before leaving.
    SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
      statusBarBrightness: Brightness.light,
    ));

    if (StorageService.getAuthToken() == null) {
      context.go('/welcome');
      return;
    }
    if (StorageService.isOnboardingComplete()) {
      // Restore the last active shell tab; defaults to /home if none saved.
      context.go(StorageService.getLastRoute());
      return;
    }
    final step = StorageService.getOnboardingStep();
    context.go(step.isNotEmpty ? step : '/onboarding/step1');
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: const Color(0xFF020E13),
      body: AstraSplashBackground(
        child: SafeArea(
          child: Stack(
            children: [
              // ── Ambient glow behind the logo ──────────────────────────
              Positioned(
                left: size.width / 2 - 160,
                top: size.height * 0.22,
                child: AnimatedBuilder(
                  animation: _glowPulse,
                  builder: (_, __) => Opacity(
                    opacity: _glowPulse.value * 0.7,
                    child: const AstraGlow(radius: 160),
                  ),
                ),
              ),

              // ── Centered logo lockup ───────────────────────────────────
              Center(
                child: FadeTransition(
                  opacity: _fade,
                  child: ScaleTransition(
                    scale: _scale,
                    child: const AstraLogo(
                      size: 130,
                      wordmarkColor: Colors.white,
                    ),
                  ),
                ),
              ),

              // ── Tagline ───────────────────────────────────────────────
              Positioned(
                bottom: size.height * 0.10,
                left: 0,
                right: 0,
                child: FadeTransition(
                  opacity: _fade,
                  child: const Column(
                    children: [
                      Text(
                        'YOUR PERSONAL INTELLIGENCE PLATFORM',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w500,
                          letterSpacing: 3.5,
                          color: Color(0x994FD8EC),
                        ),
                      ),
                      SizedBox(height: 28),
                      SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(
                          strokeWidth: 1.2,
                          color: Color(0x664FD8EC),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
