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
}
