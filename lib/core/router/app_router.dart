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
import '../../features/onboarding/presentation/view/academic_profile_screen.dart';
import '../../features/onboarding/presentation/view/lifestyle_wellness_screen.dart';
import '../../features/onboarding/presentation/view/mental_social_profile_screen.dart';
import '../../features/onboarding/presentation/screens/alex_summary_screen.dart';
import '../../features/onboarding/presentation/screens/assessment_result_screen.dart';
import '../../features/onboarding/presentation/screens/baseline_assessment_screen.dart';
import '../../features/onboarding/presentation/screens/baseline_result_screen.dart';
import '../../features/onboarding/presentation/screens/baseline_screen.dart';
import '../../features/dashboard/presentation/screens/dashboard_screen.dart';
import '../../features/profile/presentation/screens/profile_screen.dart';
import '../../features/permissions/presentation/view/permissions_screen.dart';
import '../../features/shell/presentation/screens/main_shell_screen.dart';
import '../../features/checkin/presentation/screens/daily_checkin_screen.dart';
import '../../features/session_setup/presentation/screens/session_setup_screen.dart';
import '../../features/polar/presentation/screens/heartrate_screen.dart';
import '../../features/polar/presentation/screens/polar_device_screen.dart';
import '../../features/live_training/presentation/screens/live_session_screen.dart';
import '../../features/live_training/presentation/screens/reflect_screen.dart';
import '../../features/score_entry/presentation/screens/score_entry_screen.dart';
import '../../features/score_entry/presentation/screens/series_complete_screen.dart';
import '../../features/score_entry/presentation/screens/final_scores_summary_screen.dart';
import '../../features/session_summary/presentation/screens/session_summary_screen.dart';
import '../../features/session_summary/presentation/screens/shooting_analytics_screen.dart';
import '../../features/session_summary/bloc/session_summary_bloc.dart';
import '../../features/session_report/presentation/screens/session_report_screen.dart';
import '../../features/session_report/presentation/screens/session_reflection_screen.dart';
import '../../features/session_report/bloc/session_report_bloc.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../di/injection.dart';
import '../services/storage_service.dart';
import '../../features/score_entry/bloc/score_entry_bloc.dart';
import '../../features/saarthi/presentation/screens/saarthi_chat_screen.dart';

// ─────────────────────────────────────────────────────────────────────────────
// REQUIRED FLOW
//
// AUTH
//   /splash → /welcome → /signup or /login → /otp
//
// ONBOARDING (after OTP success)
//   /onboarding/step1 → /onboarding/step2 → /onboarding/step3 (scores,
//   blockers, and Goals — Goals UI reuses OnboardingStep4Bloc/API unchanged)
//   → /onboarding/step4 (Academic Profile) → /onboarding/step5 (Lifestyle &
//   Wellness) → /onboarding/step6 (Mental & Social Profile) → /questions
//   → /assessment-result (Psychology Assessment category scores/insights)
//   → /permissions → /polar → /heartrate → /baseline → /baseline/result
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
//   Step3               → context.go('/onboarding/step4') (also fires the
//                          reused Goals submit — see onboarding_step3_screen.dart)
//   Step4 (Academic)    → context.go('/onboarding/step5')
//   Step5 (Lifestyle)   → context.go('/onboarding/step6')
//   Step6 (Mental)      → context.go('/questions')
//   Questions           → context.go('/assessment-result')
//   AssessmentResult    → context.go('/home') if onboarding already complete
//                          locally, else context.go('/permissions')
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
    '/onboarding/step5',
    '/onboarding/step6',
    '/questions',
    '/assessment-result',
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
      StorageService.saveLastRoute(loc); // noop for non-shell routes
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
        builder: (_, __) => const AcademicProfileScreen(),
      ),
      GoRoute(
        path: '/onboarding/step5',
        builder: (_, __) => const LifestyleWellnessScreen(),
      ),
      GoRoute(
        path: '/onboarding/step6',
        builder: (_, __) => const MentalSocialProfileScreen(),
      ),

      // ── BASELINE ──────────────────────────────────────────────────────────
      GoRoute(
        path: '/questions',
        builder: (_, __) => const BaselineAssessmentScreen(),
      ),
      GoRoute(
        path: '/assessment-result',
        builder: (_, state) => AssessmentResultScreen(
          extra: state.extra as Map<String, dynamic>?,
        ),
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
        path: '/session/analytics',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (_, __) => BlocProvider(
          create: (_) => getIt<SessionSummaryBloc>(),
          child: const ShootingAnalyticsScreen(),
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
        path: '/session/reflection',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (_, __) => const SessionReflectionScreen(),
      ),
      GoRoute(
        path: '/saarthi',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (_, __) => const SaarthiChatScreen(),
      ),
      // ── SHELL (bottom nav) ────────────────────────────────────────────────
      StatefulShellRoute.indexedStack(
        parentNavigatorKey: _rootNavigatorKey,
        pageBuilder: (_, state, shell) => CustomTransitionPage(
          key: state.pageKey,
          child: MainShellScreen(shell: shell),
          transitionsBuilder: (_, animation, __, child) => FadeTransition(
            opacity: CurvedAnimation(
              parent: animation,
              curve: Curves.easeOut,
            ),
            child: child,
          ),
          transitionDuration: const Duration(milliseconds: 380),
          reverseTransitionDuration: const Duration(milliseconds: 200),
        ),
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
                builder: (_, __) => BlocProvider(
                  create: (_) => getIt<SessionSummaryBloc>(),
                  child: const SessionSummaryScreen(),
                ),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/insight',
                builder: (_, __) => BlocProvider(
                  create: (_) => getIt<SessionReportBloc>(),
                  child: const SessionReportScreen(),
                ),
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
