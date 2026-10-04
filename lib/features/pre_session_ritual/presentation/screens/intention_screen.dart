import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/di/injection.dart';
import '../../bloc/ritual_bloc.dart';
import '../../bloc/ritual_event.dart';
import '../../bloc/ritual_state.dart';
import '../widgets/ritual_header.dart';
import '../widgets/ritual_progress_bar.dart';

class IntentionScreen extends StatelessWidget {
  const IntentionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: getIt<RitualBloc>(),
      child: const _IntentionView(),
    );
  }
}

class _IntentionView extends StatefulWidget {
  const _IntentionView();

  @override
  State<_IntentionView> createState() => _IntentionViewState();
}

class _IntentionViewState extends State<_IntentionView> {
  late final TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    final current = context.read<RitualBloc>().state;
    final initial = current is RitualIntentionState ? current.intention : '';
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
        if (state is RitualVisualizationState) {
          context.pushReplacement('/ritual/visualization');
        }
      },
      builder: (context, state) {
        return Scaffold(
          backgroundColor: const Color(0xFFF5FDFF),
          body: SafeArea(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 28),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  RitualProgressBar(totalSteps: 4, currentStep: 2),
                  const SizedBox(height: 14),
                  RitualHeader(
                    title: 'Intention',
                    onSkip: () => context
                        .read<RitualBloc>()
                        .add(const RitualProceedToVisualization()),
                  ),
                  Expanded(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.only(top: 32),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Set your intention',
                            style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.w700,
                              color: const Color(0xFF000F12),
                              letterSpacing: -0.4,
                            ),
                          ),
                          const SizedBox(height: 8),
                          const Text(
                            'What do you want to focus on in this session?',
                            style: TextStyle(
                              fontSize: 14,
                              color: const Color(0x99000F12),
                              height: 1.5,
                            ),
                          ),
                          const SizedBox(height: 24),
                          _IntentionTextField(controller: _controller),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  _ContinueButton(
                    onTap: () {
                      context.read<RitualBloc>().add(
                            RitualIntentionChanged(_controller.text.trim()),
                          );
                      context
                          .read<RitualBloc>()
                          .add(const RitualProceedToVisualization());
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

// ─── Text field ───────────────────────────────────────────────────────────────

class _IntentionTextField extends StatelessWidget {
  const _IntentionTextField({required this.controller});

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
          hintText: 'e.g. Stay composed on the trigger, trust my hold…',
          hintStyle: TextStyle(
            fontSize: 15,
            color: Color(0xFFB0D8E0),
            height: 1.6,
          ),
          contentPadding: EdgeInsets.all(16),
          border: InputBorder.none,
        ),
        onChanged: (v) =>
            context.read<RitualBloc>().add(RitualIntentionChanged(v)),
      ),
    );
  }
}

// ─── Continue button ──────────────────────────────────────────────────────────

class _ContinueButton extends StatelessWidget {
  const _ContinueButton({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 56,
      child: ElevatedButton(
        onPressed: onTap,
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF2F7E8F),
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
          elevation: 0,
        ),
        child: const Text(
          'Continue',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            letterSpacing: -0.2,
          ),
        ),
      ),
    );
  }
}
