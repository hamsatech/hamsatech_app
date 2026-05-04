import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:hamsatech_design_system/hamsatech_design_system.dart';

import '../../features/auth/presentation/screens/splash_screen.dart';
import '../../features/auth/presentation/screens/welcome_screen.dart';
import '../../features/auth/presentation/screens/sign_up_screen.dart';
import '../../features/auth/presentation/screens/login_screen.dart';
import '../../features/auth/presentation/screens/otp_screen.dart';
import '../../features/auth/presentation/screens/basic_profile_screen.dart';
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
import '../services/storage_service.dart';

class AppRouter {
  AppRouter._();

  static final _rootNavigatorKey = GlobalKey<NavigatorState>();
  static final _shellNavigatorKey = GlobalKey<NavigatorState>();

  static final router = GoRouter(
    navigatorKey: _rootNavigatorKey,
    initialLocation: '/permissions',
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

      // Not logged in → send to welcome
      if (!isLoggedIn && !publicPaths.contains(path)) {
        return '/welcome';
      }

      if (isLoggedIn) {
        // Step 1 incomplete → basic profile
        if (!isProfileSetupDone) {
          if (path == '/profile/setup') return null;
          return '/profile/setup';
        }

        // Step 2 incomplete → questionnaire
        if (!isOnboardingDone) {
          if (path == '/onboarding/assessment') return null;
          return '/onboarding/assessment';
        }

        // Fully done → home (kick off public/setup paths)
        if (publicPaths.contains(path) ||
            path == '/profile/setup' ||
            path == '/onboarding/assessment') {
          return '/home';
        }
      }

      return null;
    },
    routes: [
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
GoRoute(
  path: '/permissions',
  parentNavigatorKey: _rootNavigatorKey,
  builder: (_, __) => const PermissionsScreen(),
),

GoRoute(
  path: '/permissions/next',
  parentNavigatorKey: _rootNavigatorKey,
  builder: (_, __) => const PermissionsNextScreen(),
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
        path: '/profile/setup',
        builder: (_, __) => const BasicProfileScreen(),
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
