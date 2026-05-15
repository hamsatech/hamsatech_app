import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/di/injection.dart';
import '../../bloc/ritual_bloc.dart';
import '../../bloc/ritual_event.dart';
import '../../bloc/ritual_state.dart';
import '../widgets/body_scan_dots.dart';
import '../widgets/ritual_header.dart';
import '../widgets/ritual_progress_bar.dart';

class BodyScanScreen extends StatelessWidget {
  const BodyScanScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: getIt<RitualBloc>(),
      child: const _BodyScanView(),
    );
  }
}

class _BodyScanView extends StatelessWidget {
  const _BodyScanView();

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<RitualBloc, RitualState>(
      listener: (context, state) {
        if (state is RitualIntentionState) {
          context.pushReplacement('/ritual/intention');
        }
      },
      builder: (context, state) {
        final s = state is RitualBodyScanState ? state : null;
        return Scaffold(
          backgroundColor: const Color(0xFFF5FDFF),
          body: SafeArea(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 28),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  RitualProgressBar(totalSteps: 4, currentStep: 1),
                  const SizedBox(height: 14),
                  RitualHeader(
                    title: 'Body Scan',
                    onSkip: () =>
                        context.read<RitualBloc>().add(const RitualSkipBodyScan()),
                  ),
                  Expanded(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text(
                          'Bring awareness to...',
                          style: TextStyle(
                            fontSize: 14,
                            color: const Color(0x66000F12),
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                        const SizedBox(height: 16),
                        AnimatedSwitcher(
                          duration: const Duration(milliseconds: 400),
                          transitionBuilder: (child, anim) => FadeTransition(
                            opacity: anim,
                            child: SlideTransition(
                              position: Tween<Offset>(
                                begin: const Offset(0, 0.08),
                                end: Offset.zero,
                              ).animate(anim),
                              child: child,
                            ),
                          ),
                          child: Text(
                            s?.currentArea ?? '',
                            key: ValueKey(s?.currentArea),
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              fontSize: 28,
                              fontWeight: FontWeight.w700,
                              color: const Color(0xFF000F12),
                              letterSpacing: -0.5,
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),
                        const Text(
                          'Notice any tension. Breathe into it. Let it soften.',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 14,
                            color: const Color(0x99000F12),
                            fontWeight: FontWeight.w400,
                            height: 1.5,
                          ),
                        ),
                        const SizedBox(height: 28),
                        if (s != null) ...[
                          BodyScanDots(
                            currentIndex: s.areaIndex,
                            total: s.totalAreas,
                          ),
                          const SizedBox(height: 16),
                          Text(
                            s.formattedRemaining,
                            style: const TextStyle(
                              fontSize: 14,
                              color: const Color(0x66000F12),
                              fontWeight: FontWeight.w400,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
