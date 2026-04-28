import 'package:flutter/material.dart';
import 'package:hamsatech_design_system/hamsatech_design_system.dart';
import 'package:go_router/go_router.dart';


import '../../../../core/services/storage_service.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );
    _fadeAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeIn),
    );
    _scaleAnimation = Tween<double>(begin: 0.8, end: 1).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOutBack),
    );
    _controller.forward();
    _navigate();
  }

  Future<void> _navigate() async {
    await Future.delayed(const Duration(milliseconds: 2000));
    if (!mounted) return;
    final isLoggedIn = StorageService.getAuthToken() != null;
    final isOnboardingDone = StorageService.isOnboardingComplete();

    if (!isLoggedIn) {
      context.go('/login');
    } else if (!isOnboardingDone) {
      context.go('/onboarding/details');
    } else {
      context.go('/home');
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: DSColors.appBackground,
      body: Center(
        child: FadeTransition(
          opacity: _fadeAnimation,
          child: ScaleTransition(
            scale: _scaleAnimation,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 96,
                  height: 96,
                  decoration: BoxDecoration(
                    color: DSColors.brand,
                    borderRadius: BorderRadius.circular(24),
                  ),
                  child: const Icon(
                    Icons.gps_fixed_rounded,
                    color: Colors.white,
                    size: 52,
                  ),
                ),
                const SizedBox(height: 24),
                Text(
                  'HAMSA',
                  style: DSTypography.displayLarge.copyWith(
                    color: DSColors.textPrimary,
                    letterSpacing: 6,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  'MENTAL PERFORMANCE',
                  style: DSTypography.labelMedium.copyWith(
                    color: DSColors.brand,
                    letterSpacing: 4,
                  ),
                ),
                const SizedBox(height: 48),
                const SizedBox(
                  width: 24,
                  height: 24,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: DSColors.brand,
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
