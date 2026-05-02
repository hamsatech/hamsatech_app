import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../features/auth/presentation/screens/splash_screen.dart';
import '../../features/auth/presentation/screens/welcome_screen.dart';
import '../../features/auth/presentation/screens/sign_up_screen.dart';
import '../../features/auth/presentation/screens/login_screen.dart';
import '../../features/auth/presentation/screens/otp_screen.dart';
import '../../features/onboarding/presentation/screens/onboarding_step1_screen.dart';
import '../../features/onboarding/presentation/screens/athlete_details_screen.dart';
import '../../features/onboarding/presentation/view/onboarding_step1_screen.dart';
import '../../features/onboarding/presentation/view/onboarding_step2_screen.dart';
import '../../features/onboarding/presentation/view/onboarding_step3_screen.dart';
import '../../features/onboarding/presentation/view/onboarding_step4_screen.dart'; // TEMP TEST ROUTE
import '../../features/onboarding/presentation/screens/background_context_screen.dart';
import '../../features/onboarding/presentation/screens/baseline_assessment_screen.dart';
import '../../features/onboarding/presentation/view/onboarding_step2_screen.dart';
import '../../features/onboarding/presentation/view/onboarding_step3_screen.dart';
import '../../features/onboarding/presentation/view/onboarding_step4_screen.dart';
import '../../features/dashboard/presentation/screens/dashboard_screen.dart';
import '../../features/session/presentation/screens/sessions_list_screen.dart';
import '../../features/session/presentation/screens/pre_session_screen.dart';
import '../../features/session/presentation/screens/active_session_screen.dart';
import '../../features/session/presentation/screens/post_session_screen.dart';
import '../../features/profile/presentation/screens/profile_screen.dart';
import '../../features/shell/presentation/screens/main_shell_screen.dart';
<<<<<<< HEAD
import '../../features/polar/presentation/screens/polar_device_screen.dart';
import '../services/storage_service.dart';
=======
// import '../services/storage_service.dart'; // TEMP: restore with redirect
>>>>>>> b795bee (feat: onboarding steps 1–4 screens implemented)

class AppRouter {
  AppRouter._();

  static final _rootNavigatorKey = GlobalKey<NavigatorState>();
  static final _shellNavigatorKey = GlobalKey<NavigatorState>();

  static final router = GoRouter(
    navigatorKey: _rootNavigatorKey,
    initialLocation: '/onboarding/step4', // TEMP TEST ROUTE (revert to '/onboarding/step1')
    // TEMP: Force Step2 for UI testing — restore original redirect block to re-enable auth guards
    redirect: (context, state) => null,
    /* ORIGINAL REDIRECT — uncomment to restore:
    redirect: (context, state) {
      final path = state.fullPath ?? '';
      final isLoggedIn = StorageService.getAuthToken() != null;
      final isProfileSetupDone = StorageService.isProfileSetupComplete();
      final isOnboardingDone = StorageService.isOnboardingComplete();

final publicPaths = [
  '/splash',
  '/welcome',
  '/signup',
  '/login',
  '/otp',
];

final onboardingPaths = [
  '/onboarding/step1',
  '/onboarding/details',
  '/onboarding/background',
  '/onboarding/assessment',
  '/onboarding/complete',
];

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
      GoRoute(
        path: '/splash',
        builder: (_, __) => const SplashScreen(),
      ),
      GoRoute(
<<<<<<< HEAD
        path: '/welcome',
        builder: (_, __) => const WelcomeScreen(),
      ),
      GoRoute(
        path: '/signup',
        builder: (_, __) => const SignUpScreen(),
=======
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
      GoRoute( // TEMP TEST ROUTE
        path: '/onboarding/step4',
        builder: (_, __) => const OnboardingStep4Screen(),
      ),
      GoRoute( // stub — replace with real Step5Screen when implemented
        path: '/onboarding/step5',
        builder: (_, __) => const OnboardingStep4Screen(),
>>>>>>> b795bee (feat: onboarding steps 1–4 screens implemented)
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
