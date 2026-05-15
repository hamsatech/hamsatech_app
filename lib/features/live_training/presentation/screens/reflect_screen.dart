import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/di/injection.dart';
import '../../bloc/live_training_bloc.dart';
import '../../bloc/live_training_event.dart';
import '../../bloc/live_training_state.dart';
import '../widgets/emotion_selector.dart';

class ReflectScreen extends StatelessWidget {
  const ReflectScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: getIt<LiveTrainingBloc>(),
      child: const _ReflectView(),
    );
  }
}

class _ReflectView extends StatefulWidget {
  const _ReflectView();

  @override
  State<_ReflectView> createState() => _ReflectViewState();
}

class _ReflectViewState extends State<_ReflectView> {
  late final TextEditingController _workedController;
  late final TextEditingController _didntController;

  @override
  void initState() {
    super.initState();
    final s = context.read<LiveTrainingBloc>().state;
    final r = s is ReflectingState ? s : null;
    _workedController = TextEditingController(text: r?.whatWorked ?? '');
    _didntController = TextEditingController(text: r?.whatDidnt ?? '');
  }

  @override
  void dispose() {
    _workedController.dispose();
    _didntController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<LiveTrainingBloc, LiveTrainingState>(
      listener: (context, state) {
        if (state is ReflectionSavedState) {
          context.go('/session/scores');
        }
      },
      builder: (context, state) {
        final s = state is ReflectingState ? state : null;
        return Scaffold(
          backgroundColor: const Color(0xFFF5FDFF),
          body: SafeArea(
            child: Column(
              children: [
                // ── Scrollable content ────────────────────────────────
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.fromLTRB(20, 28, 20, 16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Heading
                        const Text(
                          'Reflect',
                          style: TextStyle(
                            fontSize: 26,
                            fontWeight: FontWeight.w700,
                            color: const Color(0xFF000F12),
                            letterSpacing: -0.5,
                          ),
                        ),
                        const SizedBox(height: 4),
                        const Text(
                          'A few quick questions to close the loop',
                          style: TextStyle(
                            fontSize: 14,
                            color: const Color(0x99000F12),
                          ),
                        ),

                        const SizedBox(height: 28),

                        // Emotion section
                        const Text(
                          'How did it feel?',
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                            color: const Color(0xFF000F12),
                          ),
                        ),
                        const SizedBox(height: 12),
                        EmotionSelector(
                          selected: s?.mood,
                          onSelected: (mood) => context
                              .read<LiveTrainingBloc>()
                              .add(ReflectMoodChanged(mood)),
                        ),

                        const SizedBox(height: 28),

                        // What worked
                        const _FieldLabel(label: 'What Worked'),
                        const SizedBox(height: 8),
                        _ReflectTextField(
                          controller: _workedController,
                          hint: 'Write your message here...',
                          onChanged: (v) => context
                              .read<LiveTrainingBloc>()
                              .add(ReflectWhatWorkedChanged(v)),
                        ),

                        const SizedBox(height: 20),

                        // What didn't
                        const _FieldLabel(label: "What Didn't"),
                        const SizedBox(height: 8),
                        _ReflectTextField(
                          controller: _didntController,
                          hint: 'Write your message here...',
                          onChanged: (v) => context
                              .read<LiveTrainingBloc>()
                              .add(ReflectWhatDidntChanged(v)),
                        ),

                        const SizedBox(height: 20),

                        // Voice note
                        _VoiceNoteButton(
                          onTap: () => context
                              .read<LiveTrainingBloc>()
                              .add(const ReflectVoiceNoteRequested()),
                        ),
                      ],
                    ),
                  ),
                ),

                // ── Sticky CTA ────────────────────────────────────────
                _SaveButton(
                  isLoading: s?.isSubmitting ?? false,
                  onTap: () {
                    context.read<LiveTrainingBloc>().add(
                          ReflectWhatWorkedChanged(
                              _workedController.text.trim()),
                        );
                    context.read<LiveTrainingBloc>().add(
                          ReflectWhatDidntChanged(
                              _didntController.text.trim()),
                        );
                    context
                        .read<LiveTrainingBloc>()
                        .add(const ReflectSaveRequested());
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

// ─── Field label ──────────────────────────────────────────────────────────────

class _FieldLabel extends StatelessWidget {
  const _FieldLabel({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Text(
      label,
      style: const TextStyle(
        fontSize: 15,
        fontWeight: FontWeight.w600,
        color: const Color(0xFF000F12),
      ),
    );
  }
}

// ─── Text field ───────────────────────────────────────────────────────────────

class _ReflectTextField extends StatelessWidget {
  const _ReflectTextField({
    required this.controller,
    required this.hint,
    required this.onChanged,
  });

  final TextEditingController controller;
  final String hint;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: const Color(0xFFB0D8E0)),
        borderRadius: BorderRadius.circular(10),
      ),
      child: TextField(
        controller: controller,
        minLines: 4,
        maxLines: 6,
        textCapitalization: TextCapitalization.sentences,
        style: const TextStyle(
          fontSize: 14,
          color: const Color(0xFF000F12),
          height: 1.55,
        ),
        decoration: InputDecoration(
          filled: true,
          fillColor: Colors.white,
          hintText: hint,
          hintStyle: const TextStyle(
            fontSize: 14,
            color: Color(0xFFB0D8E0),
          ),
          contentPadding: const EdgeInsets.all(14),
          border: InputBorder.none,
          enabledBorder: InputBorder.none,
          focusedBorder: InputBorder.none,
        ),
        onChanged: onChanged,
      ),
    );
  }
}

// ─── Voice note button ────────────────────────────────────────────────────────

class _VoiceNoteButton extends StatelessWidget {
  const _VoiceNoteButton({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        height: 52,
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border.all(color: const Color(0xFFB0D8E0)),
          borderRadius: BorderRadius.circular(10),
        ),
        child: const Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.mic_none_rounded,
              size: 18,
              color: Color(0xFF2F7E8F),
            ),
            SizedBox(width: 8),
            Text(
              'Add Voice note',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: Color(0xFF2F7E8F),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Save button ──────────────────────────────────────────────────────────────

class _SaveButton extends StatelessWidget {
  const _SaveButton({required this.isLoading, required this.onTap});

  final bool isLoading;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: Color(0xFFCAE8EE))),
      ),
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 28),
      child: SizedBox(
        width: double.infinity,
        height: 54,
        child: ElevatedButton(
          onPressed: isLoading ? null : onTap,
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF2F7E8F),
            foregroundColor: Colors.white,
            disabledBackgroundColor:
                const Color(0xFF2F7E8F).withValues(alpha: 0.45),
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14),
            ),
          ),
          child: isLoading
              ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: Colors.white,
                  ),
                )
              : const Text(
                  'Save & View Summary',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
        ),
      ),
    );
  }
}
