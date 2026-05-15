import 'package:get_it/get_it.dart';

import '../../features/auth/data/repositories/auth_repository_impl.dart';
import '../../features/auth/domain/repositories/auth_repository.dart';
import '../../features/auth/presentation/bloc/auth_bloc.dart';

import '../../features/onboarding/data/repositories/onboarding_repository_impl.dart';
import '../../features/onboarding/domain/repositories/onboarding_repository.dart';
import '../../features/onboarding/presentation/bloc/onboarding_bloc.dart';

import '../../features/dashboard/data/repositories/dashboard_repository_impl.dart';
import '../../features/dashboard/domain/repositories/dashboard_repository.dart';
import '../../features/dashboard/presentation/bloc/dashboard_bloc.dart';

import '../../features/session/data/repositories/session_repository_impl.dart';
import '../../features/session/domain/repositories/session_repository.dart';
import '../../features/session/presentation/bloc/session_bloc.dart';

import '../../features/reflection/data/repositories/reflection_repository_impl.dart';
import '../../features/reflection/domain/repositories/reflection_repository.dart';
import '../../features/reflection/presentation/bloc/reflection_bloc.dart';

import '../../features/checkin/data/repositories/daily_checkin_repository_impl.dart';
import '../../features/checkin/domain/repositories/daily_checkin_repository.dart';
import '../../features/checkin/presentation/bloc/daily_checkin_bloc.dart';

import '../../features/session_setup/data/repositories/session_setup_repository_impl.dart';
import '../../features/session_setup/domain/repositories/session_setup_repository.dart';
import '../../features/session_setup/presentation/bloc/session_setup_bloc.dart';

import '../../features/pre_session_ritual/data/repositories/ritual_repository_impl.dart';
import '../../features/pre_session_ritual/domain/repositories/ritual_repository.dart';
import '../../features/pre_session_ritual/bloc/ritual_bloc.dart';

import '../../features/live_training/data/repositories/live_training_repository_impl.dart';
import '../../features/live_training/domain/repositories/live_training_repository.dart';
import '../../features/live_training/bloc/live_training_bloc.dart';

import '../../features/score_entry/data/repositories/score_entry_repository_impl.dart';
import '../../features/score_entry/domain/repositories/score_entry_repository.dart';
import '../../features/score_entry/bloc/score_entry_bloc.dart';

import '../../features/session_summary/data/repositories/session_summary_repository_impl.dart';
import '../../features/session_summary/domain/repositories/session_summary_repository.dart';
import '../../features/session_summary/bloc/session_summary_bloc.dart';

import '../../features/session_report/data/repositories/session_report_repository_impl.dart';
import '../../features/session_report/domain/repositories/session_report_repository.dart';
import '../../features/session_report/bloc/session_report_bloc.dart';

import '../../features/polar/data/services/polar_ble_service.dart';
import '../../features/polar/presentation/bloc/polar_bloc.dart';

final getIt = GetIt.instance;

void setupDI() {
  // Repositories – singletons so data is shared across BLoC instances
  getIt.registerLazySingleton<AuthRepository>(() => AuthRepositoryImpl());
  getIt.registerLazySingleton<OnboardingRepository>(
      () => OnboardingRepositoryImpl());
  getIt.registerLazySingleton<DashboardRepository>(
      () => DashboardRepositoryImpl());
  getIt.registerLazySingleton<SessionRepository>(() => SessionRepositoryImpl());
  getIt.registerLazySingleton<ReflectionRepository>(
      () => ReflectionRepositoryImpl());

  // BLoC – factories for per-screen lifecycle, singleton for multi-screen flows
  getIt.registerFactory<AuthBloc>(() => AuthBloc(getIt()));
  // OnboardingBloc is a singleton so all onboarding steps share the same state
  getIt.registerLazySingleton<OnboardingBloc>(() => OnboardingBloc(getIt()));
  getIt.registerFactory<DashboardBloc>(() => DashboardBloc(getIt()));
  getIt.registerFactory<SessionBloc>(() => SessionBloc(getIt()));
  getIt.registerFactory<ReflectionBloc>(() => ReflectionBloc(getIt()));

  getIt.registerLazySingleton<DailyCheckinRepository>(
      () => DailyCheckinRepositoryImpl());
  getIt.registerFactory<DailyCheckinBloc>(() => DailyCheckinBloc(getIt()));

  getIt.registerLazySingleton<SessionSetupRepository>(
      () => SessionSetupRepositoryImpl());
  getIt.registerFactory<SessionSetupBloc>(() => SessionSetupBloc(getIt()));

  getIt.registerLazySingleton<RitualRepository>(() => RitualRepositoryImpl());
  getIt.registerLazySingleton<RitualBloc>(() => RitualBloc(getIt()));

  getIt.registerLazySingleton<LiveTrainingRepository>(
      () => LiveTrainingRepositoryImpl());
  getIt.registerLazySingleton<LiveTrainingBloc>(
      () => LiveTrainingBloc(getIt()));

  getIt.registerLazySingleton<ScoreEntryRepository>(
      () => ScoreEntryRepositoryImpl());
  getIt.registerLazySingleton<ScoreEntryBloc>(
      () => ScoreEntryBloc(repository: getIt()));

  getIt.registerLazySingleton<SessionSummaryRepository>(
      () => SessionSummaryRepositoryImpl());
  getIt.registerFactory<SessionSummaryBloc>(
      () => SessionSummaryBloc(repository: getIt()));

  getIt.registerLazySingleton<SessionReportRepository>(
      () => SessionReportRepositoryImpl());
  getIt.registerFactory<SessionReportBloc>(
      () => SessionReportBloc(repository: getIt()));

  getIt.registerLazySingleton<PolarBleService>(() => PolarBleService());
  getIt.registerLazySingleton<PolarBloc>(() => PolarBloc(getIt()));
}
