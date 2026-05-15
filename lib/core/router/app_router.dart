import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../features/auth/presentation/screens/splash_screen.dart';
import '../../features/auth/presentation/screens/welcome_screen.dart';
import '../../features/auth/presentation/screens/sign_up_screen.dart';
import '../../features/auth/presentation/screens/login_screen.dart';
import '../../features/auth/presentation/screens/otp_screen.dart';
import '../../features/onboarding/presentation/view/onboarding_step1_screen.dart';
import '../../features/onboarding/presentation/view/onboarding_step2_screen.dart';
import '../../features/onboarding/presentation/view/onboarding_step3_screen.dart';
import '../../features/onboarding/presentation/view/onboarding_step4_screen.dart';
import '../../features/onboarding/presentation/screens/alex_summary_screen.dart';
import '../../features/onboarding/presentation/screens/baseline_assessment_screen.dart';
import '../../features/onboarding/presentation/screens/baseline_result_screen.dart';
import '../../features/onboarding/presentation/screens/baseline_screen.dart';
import '../../features/dashboard/presentation/screens/dashboard_screen.dart';
import '../../features/session/presentation/screens/sessions_list_screen.dart';
import '../../features/session/presentation/screens/pre_session_screen.dart';
import '../../features/session/presentation/screens/active_session_screen.dart';
import '../../features/session/presentation/screens/post_session_screen.dart';
import '../../features/reflection/presentation/screens/reflection_screen.dart';
import '../../features/profile/presentation/screens/profile_screen.dart';
import '../../features/permissions/presentation/view/permissions_screen.dart';
import '../../features/shell/presentation/screens/main_shell_screen.dart';
import '../../features/checkin/presentation/screens/daily_checkin_screen.dart';
import '../../features/session_setup/presentation/screens/session_setup_screen.dart';
import '../../features/polar/presentation/screens/heartrate_screen.dart';
import '../../features/polar/presentation/screens/polar_device_screen.dart';
import '../../features/pre_session_ritual/presentation/screens/breathing_screen.dart';
import '../../features/pre_session_ritual/presentation/screens/body_scan_screen.dart';
import '../../features/pre_session_ritual/presentation/screens/intention_screen.dart';
import '../../features/pre_session_ritual/presentation/screens/visualization_screen.dart';
import '../../features/live_training/presentation/screens/live_session_screen.dart';
import '../../features/live_training/presentation/screens/reflect_screen.dart';
import '../../features/score_entry/presentation/screens/score_entry_screen.dart';
import '../../features/score_entry/presentation/screens/series_complete_screen.dart';
import '../../features/score_entry/presentation/screens/final_scores_summary_screen.dart';
import '../../features/session_summary/presentation/screens/session_summary_screen.dart';
import '../../features/session_summary/bloc/session_summary_bloc.dart';
import '../../features/session_report/presentation/screens/session_report_screen.dart';
import '../../features/session_report/bloc/session_report_bloc.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../di/injection.dart';
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
    initialLocation: '/splash',
    redirect: (context, state) {
      final loc = state.matchedLocation;
      if (_onboardingRoutes.contains(loc)) {
        StorageService.saveOnboardingStep(loc); // fire-and-forget
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
        builder: (_, state) => OtpScreen(phoneOrEmail: state.extra as String),
      ),
      GoRoute(
        path: '/permissions',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (_, __) => const PermissionsScreen(),
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
        path: '/questions',
        builder: (_, __) => const BaselineAssessmentScreen(),
      ),
      GoRoute(
        path: '/baseline',
        builder: (_, __) => const BaselineScreen(),
      ),
      GoRoute(
        path: '/baseline/result',
        builder: (_, __) => const BaselineResultScreen(),
      ),
      GoRoute(
        path: '/alex-summary',
        builder: (_, __) => const AlexSummaryScreen(),
      ),

      GoRoute(
        path: '/polar',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (_, __) => const PolarDeviceScreen(),
      ),
      GoRoute(
        path: '/heartrate',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (_, __) => const HeartRateScreen(),
      ),
      GoRoute(
        path: '/checkin',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (_, __) => const DailyCheckinScreen(),
      ),
      GoRoute(
        path: '/session/setup',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (_, __) => const SessionSetupScreen(),
      ),
      GoRoute(
        path: '/ritual/breathing',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (_, __) => const BreathingScreen(),
      ),
      GoRoute(
        path: '/ritual/body-scan',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (_, __) => const BodyScanScreen(),
      ),
      GoRoute(
        path: '/ritual/intention',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (_, __) => const IntentionScreen(),
      ),
      GoRoute(
        path: '/ritual/visualization',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (_, __) => const VisualizationScreen(),
      ),
      GoRoute(
        path: '/session/live',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (_, __) => const LiveSessionScreen(),
      ),
      GoRoute(
        path: '/session/reflect',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (_, __) => const ReflectScreen(),
      ),
      GoRoute(
        path: '/session/scores',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (_, __) => BlocProvider.value(
          value: getIt<ScoreEntryBloc>(),
          child: const ScoreEntryScreen(),
        ),
      ),
      GoRoute(
        path: '/session/scores/complete',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (_, __) => BlocProvider.value(
          value: getIt<ScoreEntryBloc>(),
          child: const SeriesCompleteScreen(),
        ),
      ),
      GoRoute(
        path: '/session/scores/summary',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (_, __) => BlocProvider.value(
          value: getIt<ScoreEntryBloc>(),
          child: const FinalScoresSummaryScreen(),
        ),
      ),
      GoRoute(
        path: '/session/summary',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (_, __) => BlocProvider(
          create: (_) => getIt<SessionSummaryBloc>(),
          child: const SessionSummaryScreen(),
        ),
      ),
      GoRoute(
        path: '/session/report',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (_, __) => BlocProvider(
          create: (_) => getIt<SessionReportBloc>(),
          child: const SessionReportScreen(),
        ),
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
                path: '/journal',
                builder: (_, __) => const ReflectionScreen(),
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
