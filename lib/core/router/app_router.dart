import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:hamsatech_design_system/hamsatech_design_system.dart';

import '../../features/auth/presentation/screens/splash_screen.dart';
import '../../features/auth/presentation/screens/welcome_screen.dart';
import '../../features/auth/presentation/screens/sign_up_screen.dart';
import '../../features/auth/presentation/screens/login_screen.dart';
import '../../features/auth/presentation/screens/otp_screen.dart';
import '../../features/onboarding/presentation/screens/athlete_details_screen.dart';
import '../../features/onboarding/presentation/screens/background_context_screen.dart';
import '../../features/onboarding/presentation/screens/baseline_assessment_screen.dart';
import '../../features/onboarding/presentation/screens/onboarding_complete_screen.dart';
import '../../features/dashboard/presentation/screens/dashboard_screen.dart';
import '../../features/session/presentation/screens/sessions_list_screen.dart';
import '../../features/session/presentation/screens/pre_session_screen.dart';
import '../../features/session/presentation/screens/active_session_screen.dart';
import '../../features/session/presentation/screens/post_session_screen.dart';
import '../../features/profile/presentation/screens/profile_screen.dart';
import '../../features/permissions/presentation/view/permissions_screen.dart';
import '../../features/shell/presentation/screens/main_shell_screen.dart';
import '../services/storage_service.dart';
import '../../features/score_entry/bloc/score_entry_bloc.dart';

// ─────────────────────────────────────────────────────────────────────────────
// REQUIRED FLOW
//
// AUTH
//   /splash → /welcome → /signup or /login → /otp
//
// ONBOARDING (after OTP success)
//   /onboarding/step1 → /onboarding/step2 → /onboarding/step3
//   → /onboarding/step4 → /questions → /permissions
//   → /polar → /heartrate → /baseline → /baseline/result
//   → /alex-summary → /home
//
// NAVIGATION CALLS — use context.go() everywhere (replaces stack, no back-stack leak)
//
//   SplashScreen        → context.go('/welcome')
//   WelcomeScreen       → context.go('/signup') or context.go('/login')
//   SignUpScreen/Login  → context.go('/otp', extra: phoneOrEmail)
//   OtpScreen           → context.go('/onboarding/step1')
//   Step1               → context.go('/onboarding/step2')
//   Step2               → context.go('/onboarding/step3')
//   Step3               → context.go('/onboarding/step4')
//   Step4               → context.go('/questions')
//   Questions           → context.go('/permissions')
//   PermissionsScreen   → context.go('/polar')
//   PolarDeviceScreen   → context.go('/heartrate')
//   HeartRateScreen     → context.go('/baseline')
//   BaselineScreen      → context.go('/baseline/result')
//   BaselineResult      → context.go('/alex-summary')
//   AlexSummaryScreen   → context.go('/home')
// ─────────────────────────────────────────────────────────────────────────────

class AppRouter {
  AppRouter._();

  static final _rootNavigatorKey = GlobalKey<NavigatorState>();
  static final _shellNavigatorKey = GlobalKey<NavigatorState>();

  // Routes that mark onboarding progress — tracked for cold-start resume.
  static const _onboardingRoutes = {
    '/onboarding/step1',
    '/onboarding/step2',
    '/onboarding/step3',
    '/onboarding/step4',
    '/questions',
    '/permissions',
    '/polar',
    '/heartrate',
    '/baseline',
    '/baseline/result',
    '/alex-summary',
  };

  static final router = GoRouter(
    navigatorKey: _rootNavigatorKey,
    initialLocation: '/permissions',
    redirect: (context, state) {
      final path = state.fullPath ?? '';
      final isLoggedIn = StorageService.getAuthToken() != null;
      final isOnboardingDone = StorageService.isOnboardingComplete();

      final publicPaths = ['/splash', '/login', '/otp'];
      final onboardingPaths = [
        '/onboarding/details',
        '/onboarding/background',
        '/onboarding/assessment',
        '/onboarding/complete',
      ];

      if (path == '/splash') return null;

      if (!isLoggedIn && !publicPaths.contains(path)) {
        return '/login';
      }

      if (isLoggedIn && !isOnboardingDone && !onboardingPaths.contains(path)) {
        return '/onboarding/details';
      }

      if (isLoggedIn &&
          isOnboardingDone &&
          (publicPaths.contains(path) || onboardingPaths.contains(path))) {
        return '/home';
      }

      return null;
    },
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
        builder: (_, state) =>
            OtpScreen(phoneOrEmail: state.extra as String),
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
        path: '/questions',
        builder: (_, __) => const BaselineAssessmentScreen(),
      ),
      GoRoute(
        path: '/onboarding/complete',
        builder: (_, __) => const OnboardingCompleteScreen(),
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
