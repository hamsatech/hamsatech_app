import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/di/injection.dart';
import '../../bloc/ritual_bloc.dart';
import '../../bloc/ritual_event.dart';
import '../../bloc/ritual_state.dart';
import '../widgets/ritual_header.dart';
import '../widgets/ritual_progress_bar.dart';

class VisualizationScreen extends StatelessWidget {
  const VisualizationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: getIt<RitualBloc>(),
      child: const _VisualizationView(),
    );
  }
}

class _VisualizationView extends StatefulWidget {
  const _VisualizationView();

  @override
  State<_VisualizationView> createState() => _VisualizationViewState();
}

class _VisualizationViewState extends State<_VisualizationView> {
  late final TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    final current = context.read<RitualBloc>().state;
    final initial =
        current is RitualVisualizationState ? current.visualization : '';
    _controller = TextEditingController(text: initial);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<RitualBloc, RitualState>(
      listener: (context, state) {
        if (state is RitualCompleteState) {
          context.pushReplacement('/session/live');
        }
      },
      builder: (context, state) {
        final isLoading = state is! RitualVisualizationState &&
            state is! RitualCompleteState;
        return Scaffold(
          backgroundColor: const Color(0xFFF5FDFF),
          body: SafeArea(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 28),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  RitualProgressBar(totalSteps: 4, currentStep: 3),
                  const SizedBox(height: 14),
                  RitualHeader(
                    title: 'Visualization',
                    onSkip: () {
                      context
                          .read<RitualBloc>()
                          .add(const RitualComplete());
                    },
                  ),
                  Expanded(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.only(top: 32),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Visualize your perfect shot',
                            style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.w700,
                              color: const Color(0xFF000F12),
                              letterSpacing: -0.4,
                            ),
                          ),
                          const SizedBox(height: 8),
                          const Text(
                            'Close your eyes. Picture the shot in detail — stance, aim, release.',
                            style: TextStyle(
                              fontSize: 14,
                              color: const Color(0x99000F12),
                              height: 1.5,
                            ),
                          ),
                          const SizedBox(height: 24),
                          _VisualizationTextField(controller: _controller),
                          if (state is RitualVisualizationState &&
                              state.intention.isNotEmpty) ...[
                            const SizedBox(height: 20),
                            _IntentionCallout(intention: state.intention),
                          ],
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  _CompleteButton(
                    isLoading: isLoading,
                    onTap: () {
                      context.read<RitualBloc>().add(
                            RitualVisualizationChanged(
                              _controller.text.trim(),
                            ),
                          );
                      context
                          .read<RitualBloc>()
                          .add(const RitualComplete());
                    },
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

// ─── Visualization text field ─────────────────────────────────────────────────

class _VisualizationTextField extends StatelessWidget {
  const _VisualizationTextField({required this.controller});

  final TextEditingController controller;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFF0FAFC),
        border: Border.all(color: const Color(0xFFCAE8EE)),
        borderRadius: BorderRadius.circular(12),
      ),
      child: TextField(
        controller: controller,
        maxLines: 5,
        minLines: 5,
        textCapitalization: TextCapitalization.sentences,
        style: const TextStyle(
          fontSize: 15,
          color: const Color(0xFF000F12),
          height: 1.6,
        ),
        decoration: const InputDecoration(
          hintText: 'e.g. I see a clean 10, breath is steady, finger pressure is smooth…',
          hintStyle: TextStyle(
            fontSize: 15,
            color: Color(0xFFB0D8E0),
            height: 1.6,
          ),
          contentPadding: EdgeInsets.all(16),
          border: InputBorder.none,
        ),
        onChanged: (v) => context
            .read<RitualBloc>()
            .add(RitualVisualizationChanged(v)),
      ),
    );
  }
}

// ─── Intention callout ────────────────────────────────────────────────────────

class _IntentionCallout extends StatelessWidget {
  const _IntentionCallout({required this.intention});

  final String intention;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFFECFDF5),
        border: Border.all(color: const Color(0xFFD1FAE5)),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Your intention',
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: Color(0xFF065F46),
              letterSpacing: 0.4,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            intention,
            style: const TextStyle(
              fontSize: 13,
              color: Color(0xFF064E3B),
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Complete button ──────────────────────────────────────────────────────────

class _CompleteButton extends StatelessWidget {
  const _CompleteButton({
    required this.isLoading,
    required this.onTap,
  });

  final bool isLoading;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return AnimatedOpacity(
      opacity: isLoading ? 0.45 : 1.0,
      duration: const Duration(milliseconds: 200),
      child: SizedBox(
        width: double.infinity,
        height: 56,
        child: ElevatedButton.icon(
          onPressed: isLoading ? null : onTap,
          icon: const Icon(Icons.check_circle_outline_rounded, size: 20),
          label: const Text(
            'Begin Session',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              letterSpacing: -0.2,
            ),
          ),
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF2F7E8F),
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14),
            ),
            elevation: 0,
          ),
        ),
      ),
    );
  }
}
