import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/di/injection.dart';
import '../../bloc/ritual_bloc.dart';
import '../../bloc/ritual_event.dart';
import '../../bloc/ritual_state.dart';
import '../widgets/breathing_circle.dart';
import '../widgets/ritual_header.dart';
import '../widgets/ritual_progress_bar.dart';

class BreathingScreen extends StatelessWidget {
  const BreathingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: getIt<RitualBloc>(),
      child: const _BreathingView(),
    );
  }
}

class _BreathingView extends StatefulWidget {
  const _BreathingView();

  @override
  State<_BreathingView> createState() => _BreathingViewState();
}

class _BreathingViewState extends State<_BreathingView> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<RitualBloc>().add(const RitualStartBreathing());
    });
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<RitualBloc, RitualState>(
      listener: (context, state) {
        if (state is RitualBodyScanState) {
          context.pushReplacement('/ritual/body-scan');
        }
      },
      builder: (context, state) {
        final s = state is RitualBreathingState ? state : null;
        return Scaffold(
          backgroundColor: const Color(0xFFF5FDFF),
          body: SafeArea(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 28),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  RitualProgressBar(totalSteps: 4, currentStep: 0),
                  const SizedBox(height: 14),
                  RitualHeader(
                    title: 'Breathing',
                    onSkip: () => context
                        .read<RitualBloc>()
                        .add(const RitualSkipBreathing()),
                  ),
                  Expanded(
                    child: Center(
                      child: s != null
                          ? BreathingCircle(
                              phase: s.phase,
                              phaseSeconds: s.phaseSeconds,
                            )
                          : const _LoadingCircle(),
                    ),
                  ),
                  if (s != null) ...[
                    Text(
                      s.formattedRemaining,
                      style: const TextStyle(
                        fontSize: 14,
                        color: const Color(0x99000F12),
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      s.breathInstruction,
                      style: const TextStyle(
                        fontSize: 13,
                        color: const Color(0x66000F12),
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

class _LoadingCircle extends StatelessWidget {
  const _LoadingCircle();

  @override
  Widget build(BuildContext context) {
    return const SizedBox(
      width: 280,
      height: 280,
      child: Center(
        child: CircularProgressIndicator(
          color: Color(0xFF2F7E8F),
          strokeWidth: 2,
        ),
      ),
    );
  }
}
