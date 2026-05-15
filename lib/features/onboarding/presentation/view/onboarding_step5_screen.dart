import 'package:flutter/widgets.dart';
import 'package:go_router/go_router.dart';

class OnboardingStep5Screen extends StatefulWidget {
  const OnboardingStep5Screen({super.key});

  @override
  State<OnboardingStep5Screen> createState() => _OnboardingStep5ScreenState();
}

class _OnboardingStep5ScreenState extends State<OnboardingStep5Screen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) context.go('/questions');
    });
  }

  @override
  Widget build(BuildContext context) => const SizedBox.shrink();
}
