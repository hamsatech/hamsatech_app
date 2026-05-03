import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../bloc/onboarding_completion_bloc.dart';
import 'onboarding_completion_view.dart';

class OnboardingCompletionScreen extends StatelessWidget {
  const OnboardingCompletionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => OnboardingCompletionBloc(),
      child: const OnboardingCompletionView(),
    );
  }
}
