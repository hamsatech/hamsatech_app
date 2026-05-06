import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:hamsatech_design_system/hamsatech_design_system.dart';

import '../../features/auth/presentation/screens/splash_screen.dart';
import '../../features/auth/presentation/screens/welcome_screen.dart';
import '../../features/auth/presentation/screens/sign_up_screen.dart';
import '../../features/auth/presentation/screens/login_screen.dart';
import '../../features/auth/presentation/screens/otp_screen.dart';
import '../../features/auth/presentation/screens/basic_profile_screen.dart';
import '../../features/onboarding/presentation/view/onboarding_step1_screen.dart';
import '../../features/onboarding/presentation/view/onboarding_step2_screen.dart';
import '../../features/onboarding/presentation/view/onboarding_step3_screen.dart';
import '../../features/onboarding/presentation/screens/athlete_details_screen.dart';
import '../../features/onboarding/presentation/view/onboarding_step4_screen.dart';
import '../../features/onboarding/presentation/screens/background_context_screen.dart';
import '../../features/onboarding/presentation/screens/baseline_assessment_screen.dart';
import '../../features/dashboard/presentation/screens/dashboard_screen.dart';
import '../../features/session/presentation/screens/sessions_list_screen.dart';
import '../../features/session/presentation/screens/pre_session_screen.dart';
import '../../features/session/presentation/screens/active_session_screen.dart';
import '../../features/session/presentation/screens/post_session_screen.dart';
import '../../features/profile/presentation/screens/profile_screen.dart';
import '../../features/permissions/presentation/view/permissions_screen.dart';
import '../../features/shell/presentation/screens/main_shell_screen.dart';
import '../../features/polar/presentation/screens/polar_device_screen.dart';

// ─────────────────────────────────────────────────────────────────────────────
// REQUIRED FLOW
//
// AUTH
//   /splash → /welcome → /signup or /login → /otp
//
// ONBOARDING (after OTP success)
//   /permissions → /onboarding/step1 → /onboarding/step2 → /onboarding/step3
//   → /onboarding/step3b → /onboarding/step4 → /polar → /polar/connect
//   → /baseline → /baseline/result → /onboarding/complete → /home
//
// NAVIGATION CALLS — use context.go() everywhere (replaces stack, no back-stack leak)
//
//   SplashScreen        → context.go('/welcome')
//   WelcomeScreen       → context.go('/signup') or context.go('/login')
//   SignUpScreen/Login  → context.go('/otp', extra: phoneOrEmail)
//   OtpScreen           → context.go('/permissions')
//   PermissionsScreen   → context.go('/onboarding/step1')
//   Step1               → context.go('/onboarding/step2')
//   Step2               → context.go('/onboarding/step3')
//   Step3               → context.go('/onboarding/step3b')
//   Step3b              → context.go('/onboarding/step4')
//   Step4               → context.go('/polar')
//   PolarDeviceScreen   → context.go('/polar/connect')
//   PolarConnectScreen  → context.go('/baseline')
//   BaselineScreen      → context.go('/baseline/result')
//   BaselineResult      → context.go('/onboarding/complete')
//   OnboardingComplete  → context.go('/home')
// ─────────────────────────────────────────────────────────────────────────────

class AppRouter {
  AppRouter._();

  static final _rootNavigatorKey = GlobalKey<NavigatorState>();
  static final _shellNavigatorKey = GlobalKey<NavigatorState>();

  static final router = GoRouter(
    navigatorKey: _rootNavigatorKey,
    initialLocation: '/permissions',
    redirect: (context, state) => null,
    /* ORIGINAL REDIRECT — restore once StorageService is wired up:
    redirect: (context, state) {
      final path = state.fullPath ?? '';
      final isLoggedIn = StorageService.getAuthToken() != null;
      final isProfileSetupDone = StorageService.isProfileSetupComplete();
      final isOnboardingDone = StorageService.isOnboardingComplete();

<<<<<<< HEAD
      final publicPaths = [
        '/splash',
        '/login',
        '/otp',
        '/permissions',
        '/permissions/next',
      ];
      final onboardingPaths = [
        '/onboarding/details',
        '/onboarding/background',
        '/onboarding/assessment',
        '/onboarding/complete',
      ];
=======
      const publicPaths = ['/splash', '/welcome', '/signup', '/login', '/otp'];
>>>>>>> 063f8990560ca136db22b7f3be4686b33feb3797

      if (path == '/splash') return null;

      if (!isLoggedIn && !publicPaths.contains(path)) {
        return '/welcome';
      }

      if (isLoggedIn) {
        if (!isProfileSetupDone) {
          if (path.startsWith('/onboarding/')) return null;
          return '/onboarding/step1';
        }

        if (!isOnboardingDone) {
          if (path == '/onboarding/assessment') return null;
          return '/onboarding/assessment';
        }

        if (publicPaths.contains(path) ||
            path == '/onboarding/step1' ||
            path == '/onboarding/assessment') {
          return '/home';
        }
      }

      return null;
    },
    */
    routes: [
      // ── AUTH ──────────────────────────────────────────────────────────────
      GoRoute(
        path: '/splash',
        builder: (_, __) => const SplashScreen(),
      ),
      GoRoute(
        path: '/welcome',
        builder: (_, __) => const WelcomeScreen(),
      ),
      GoRoute(
        path: '/signup',
        builder: (_, __) => const SignUpScreen(),
      ),
      GoRoute(
        path: '/login',
        builder: (_, __) => const LoginScreen(),
      ),
      GoRoute(
        path: '/otp',
        builder: (_, state) => OtpScreen(phoneOrEmail: state.extra as String),
      ),
      GoRoute(
        path: '/permissions',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (_, __) => const PermissionsScreen(),
      ),

      GoRoute(
        path: '/permissions/next',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (_, __) => const _PermissionsNextScreen(),
      ),

GoRoute(
  path: '/profile/setup',
  builder: (_, __) => const BasicProfileScreen(),
),

GoRoute(
  path: '/onboarding/assessment',
  builder: (_, __) => const BaselineAssessmentScreen(),
),
      
      GoRoute(
        path: '/onboarding/step1',
        builder: (_, __) => const OnboardingStep1Screen(),
      ),
      GoRoute(
        path: '/onboarding/step2',
        builder: (_, __) => const OnboardingStep2Screen(),
      ),
      GoRoute(
        path: '/onboarding/step3',
        builder: (_, __) => const OnboardingStep3Screen(),
      ),
      GoRoute(
        path: '/onboarding/step4',
        builder: (_, __) => const OnboardingStep4Screen(),
      ),

      // ── BASELINE ──────────────────────────────────────────────────────────
      GoRoute(
        path: '/baseline',
        builder: (_, __) => const BaselineAssessmentScreen(),
      ),
      // TODO: replace builder with BaselineResultScreen once built
      GoRoute(
        path: '/baseline/result',
        builder: (_, __) => const _PlaceholderScreen(title: 'Baseline Result'),
      ),

      // ── ONBOARDING COMPLETE ───────────────────────────────────────────────
      GoRoute(
        path: '/onboarding/complete',
        builder: (_, __) => const _PlaceholderScreen(title: 'Onboarding Complete'),
      ),

      // ── PROFILE SETUP (post-auth, pre-onboarding) ─────────────────────────
      GoRoute(
        path: '/profile/setup',
        builder: (_, __) => const BasicProfileScreen(),
      ),

      // ── LEGACY ROUTES — kept for backward compatibility ───────────────────
      GoRoute(
        path: '/onboarding/details',
        builder: (_, __) => const AthleteDetailsScreen(),
      ),
      GoRoute(
        path: '/onboarding/background',
        builder: (_, __) => const BackgroundContextScreen(),
      ),
      GoRoute(
        path: '/onboarding/assessment',
        builder: (_, __) => const BaselineAssessmentScreen(),
      ),
      GoRoute(
        path: '/polar',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (_, __) => const PolarDeviceScreen(),
      ),
      GoRoute(
        path: '/session/pre',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (_, __) => const PreSessionScreen(),
      ),
      GoRoute(
        path: '/session/active',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (_, state) =>
            ActiveSessionScreen(sessionId: state.extra as String),
      ),
      GoRoute(
        path: '/session/post',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (_, state) {
          final extra = state.extra as Map;
          return PostSessionScreen(
            sessionId: extra['sessionId'] as String,
            durationMinutes: (extra['durationMinutes'] as num?)?.toInt() ?? 0,
          );
        },
      ),

      // ── SHELL (bottom nav) ────────────────────────────────────────────────
      StatefulShellRoute.indexedStack(
        parentNavigatorKey: _rootNavigatorKey,
        builder: (_, __, shell) => MainShellScreen(shell: shell),
        branches: [
          StatefulShellBranch(
            navigatorKey: _shellNavigatorKey,
            routes: [
              GoRoute(
                path: '/home',
                builder: (_, __) => const DashboardScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/sessions',
                builder: (_, __) => const SessionsListScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/profile',
                builder: (_, __) => const ProfileScreen(),
              ),
            ],
          ),
        ],
      ),
    ],
  );
}

class _PermissionsNextScreen extends StatelessWidget {
  const _PermissionsNextScreen();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: DSColors.white,
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(DSSpacing.xxl),
            child: Text(
              'Next screen placeholder',
              style: DSTypography.headingLarge.copyWith(
                color: DSColors.black,
              ),
              textAlign: TextAlign.center,
            ),
          ),
        ),
      ),
    );
  }
}

// Temporary stand-in for screens not yet built.
// Replace each usage with the real screen class once implemented.
class _PlaceholderScreen extends StatelessWidget {
  const _PlaceholderScreen({required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(title)),
      body: Center(
        child: Text(
          '$title — coming soon',
          style: const TextStyle(fontSize: 16, color: Colors.grey),
        ),
      ),
    );
  }
}
