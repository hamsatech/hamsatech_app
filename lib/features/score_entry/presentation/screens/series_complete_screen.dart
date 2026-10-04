import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:hamsatech_design_system/hamsatech_design_system.dart';

/// Legacy route — the new scoring flow never navigates here.
/// Redirects to the score entry screen if somehow accessed.
class SeriesCompleteScreen extends StatelessWidget {
  const SeriesCompleteScreen({super.key});

  @override
  Widget build(BuildContext context) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (context.mounted) context.go('/session/scores');
    });
    return const Scaffold(
      backgroundColor: DSColors.appBackground,
      body: Center(child: CircularProgressIndicator()),
    );
  }
}
