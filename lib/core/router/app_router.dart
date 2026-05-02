import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

// Permissions
import '../../features/permissions/presentation/view/permissions_screen.dart';

// Auth
import '../../features/auth/presentation/screens/basic_profile_screen.dart';
import '../../features/auth/presentation/screens/login_screen.dart';
import '../../features/auth/presentation/screens/otp_screen.dart';
import '../../features/auth/presentation/screens/sign_up_screen.dart';
import '../../features/auth/presentation/screens/splash_screen.dart';
import '../../features/auth/presentation/screens/welcome_screen.dart';

// Dashboard
import '../../features/dashboard/presentation/screens/dashboard_screen.dart';

// Onboarding (SCREENS)
import '../../features/onboarding/presentation/screens/onboarding_step1_screen.dart';
import '../../features/onboarding/presentation/screens/athlete_details_screen.dart';
import '../../features/onboarding/presentation/screens/background_context_screen.dart';
import '../../features/onboarding/presentation/screens/baseline_assessment_screen.dart';
import '../../features/onboarding/presentation/screens/onboarding_complete_screen.dart';

// Onboarding (VIEWS)
import '../../features/onboarding/presentation/view/onboarding_step2_screen.dart';
import '../../features/onboarding/presentation/view/onboarding_step3_screen.dart';
import '../../features/onboarding/presentation/view/onboarding_step4_screen.dart';

// Session
import '../../features/session/presentation/screens/sessions_list_screen.dart';
import '../../features/session/presentation/screens/pre_session_screen.dart';
import '../../features/session/presentation/screens/active_session_screen.dart';
import '../../features/session/presentation/screens/post_session_screen.dart';

// Shell
import '../../features/shell/presentation/screens/main_shell_screen.dart';

// Polar
import '../../features/polar/presentation/screens/polar_device_screen.dart';

// Profile
import '../../features/profile/presentation/screens/profile_screen.dart';

// Services
import '../services/storage_service.dart';

class AppRouter {
  AppRouter._();

  static final _rootNavigatorKey = GlobalKey<NavigatorState>();
  static final _shellNavigatorKey = GlobalKey<NavigatorState>();

  static final router = GoRouter(
    navigatorKey: _rootNavigatorKey,
    initialLocation: '/permissions',

    // Keep simple for now (testing)
    redirect: (context, state) => null,

    routes: [
      // Permissions
      GoRoute(
        path: '/permissions',
        builder: (_, __) => const PermissionsScreen(),
      ),

      // TEMP next screen
      GoRoute(
        path: '/next-screen',
        builder: (_, __) => const Scaffold(
          body: Center(child: Text('Next Screen — Placeholder')),
        ),
      ),

      // Auth
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
        builder: (_, state) => OtpScreen(
          phoneOrEmail: state.extra as String,
        ),
      ),

      // Onboarding Flow
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
        path: '/onboarding/step5',
        builder: (_, __) => const OnboardingStep4Screen(), // placeholder
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
        path: '/onboarding/complete',
        builder: (_, __) => const OnboardingCompleteScreen(),
      ),

      // Polar
      GoRoute(
        path: '/polar',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (_, __) => const PolarDeviceScreen(),
      ),

      // Session Flow
      GoRoute(
        path: '/session/pre',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (_, __) => const PreSessionScreen(),
      ),
      GoRoute(
        path: '/session/active',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (_, state) => ActiveSessionScreen(
          sessionId: state.extra as String,
        ),
      ),
      GoRoute(
        path: '/session/post',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (_, state) {
          final extra = state.extra as Map;
          return PostSessionScreen(
            sessionId: extra['sessionId'] as String,
            durationMinutes:
                (extra['durationMinutes'] as num?)?.toInt() ?? 0,
          );
        },
      ),

      // Main App Shell
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