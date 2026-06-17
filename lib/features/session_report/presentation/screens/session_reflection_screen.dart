import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:hamsatech_design_system/hamsatech_design_system.dart';

const _kTeal = Color(0xFF2F7E8F);

class SessionReflectionScreen extends StatefulWidget {
  const SessionReflectionScreen({super.key});

  @override
  State<SessionReflectionScreen> createState() =>
      _SessionReflectionScreenState();
}

class _SessionReflectionScreenState extends State<SessionReflectionScreen> {
  int? _selectedMood;

  final _whatWorkedController = TextEditingController();
  final _whatDidntController = TextEditingController();
  final _wentWellController = TextEditingController();
  final _improveController = TextEditingController();
  final _observationsController = TextEditingController();

  @override
  void dispose() {
    _whatWorkedController.dispose();
    _whatDidntController.dispose();
    _wentWellController.dispose();
    _improveController.dispose();
    _observationsController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: DSColors.appBackground,
      appBar: AppBar(
        backgroundColor: DSColors.appBackground,
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: DSColors.black),
          onPressed: () => context.pop(),
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(
                  DSSpacing.xl, DSSpacing.xs, DSSpacing.xl, DSSpacing.xxl),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ── Header ────────────────────────────────────────────────
                  Text(
                    'Reflect',
                    style: DSTypography.headingXl.copyWith(
                      color: DSColors.textPrimary,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: DSSpacing.xxs),
                  Text(
                    'A few quick questions to choose the loop',
                    style: DSTypography.bodySm
                        .copyWith(color: DSColors.textSecondary),
                  ),

                  // ── Mood ──────────────────────────────────────────────────
                  const SizedBox(height: DSSpacing.xxl),
                  Text(
                    'How did it feel?',
                    style: DSTypography.bodyLg.copyWith(
                      color: DSColors.textPrimary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: DSSpacing.md),
                  _MoodSelector(
                    selectedIndex: _selectedMood,
                    onSelected: (i) => setState(() => _selectedMood = i),
                  ),

                  // ── Text areas ────────────────────────────────────────────
                  const SizedBox(height: DSSpacing.xxl),
                  _ReflectionField(
                    label: 'What Worked',
                    hint: 'Write your message here...',
                    controller: _whatWorkedController,
                  ),
                  const SizedBox(height: DSSpacing.xl),
                  _ReflectionField(
                    label: "What Didn't",
                    hint: 'Write your message here...',
                    controller: _whatDidntController,
                  ),
                  const SizedBox(height: DSSpacing.xl),
                  _ReflectionField(
                    label: 'What went well today?',
                    hint: 'Text area for athlete input',
                    controller: _wentWellController,
                  ),
                  const SizedBox(height: DSSpacing.xl),
                  _ReflectionField(
                    label: 'What to improve next time?',
                    hint: 'Text area for athlete input',
                    controller: _improveController,
                  ),
                  const SizedBox(height: DSSpacing.xl),
                  _ReflectionField(
                    label: 'Any observations?',
                    hint: 'Text area for athlete input',
                    controller: _observationsController,
                  ),

                  // ── Voice note ────────────────────────────────────────────
                  const SizedBox(height: DSSpacing.xl),
                  const _VoiceNoteButton(),
                ],
              ),
            ),
          ),

          // ── Fixed bottom CTA ──────────────────────────────────────────────
          const Divider(height: 1, thickness: 1, color: DSColors.gray200),
          SafeArea(
            top: false,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(
                  DSSpacing.xl, DSSpacing.lg, DSSpacing.xl, DSSpacing.xxl),
              child: DSPrimaryButton(
                label: 'Save & View Summary',
                color: _kTeal,
                onPressed: () => context.go('/session/summary'),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Mood selector
// ─────────────────────────────────────────────────────────────────────────────

class _MoodData {
  const _MoodData(this.emoji, this.label);
  final String emoji;
  final String label;
}

class _MoodSelector extends StatelessWidget {
  const _MoodSelector({
    required this.selectedIndex,
    required this.onSelected,
  });

  final int? selectedIndex;
  final ValueChanged<int> onSelected;

  static const _moods = [
    _MoodData('😫', 'Trouble'),
    _MoodData('🥺', 'Poor'),
    _MoodData('😐', 'Okay'),
    _MoodData('🙂', 'Good'),
    _MoodData('😄', 'Great'),
  ];

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: List.generate(
        _moods.length,
        (i) => _MoodItem(
          mood: _moods[i],
          isSelected: selectedIndex == i,
          onTap: () => onSelected(i),
        ),
      ),
    );
  }
}

class _MoodItem extends StatelessWidget {
  const _MoodItem({
    required this.mood,
    required this.isSelected,
    required this.onTap,
  });

  final _MoodData mood;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              color: isSelected
                  ? _kTeal.withValues(alpha: 0.10)
                  : Colors.transparent,
              shape: BoxShape.circle,
              border: Border.all(
                color: isSelected ? _kTeal : Colors.transparent,
                width: 1.5,
              ),
            ),
            child: Center(
              child: Text(
                mood.emoji,
                style: const TextStyle(fontSize: 26),
              ),
            ),
          ),
          const SizedBox(height: 5),
          Text(
            mood.label,
            style: DSTypography.labelXs.copyWith(
              color: isSelected ? _kTeal : DSColors.textSecondary,
              fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Reflection text field
// ─────────────────────────────────────────────────────────────────────────────

class _ReflectionField extends StatelessWidget {
  const _ReflectionField({
    required this.label,
    required this.hint,
    required this.controller,
  });

  final String label;
  final String hint;
  final TextEditingController controller;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: DSTypography.bodyLg.copyWith(
            color: DSColors.textPrimary,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: DSSpacing.sm),
        TextField(
          controller: controller,
          minLines: 4,
          maxLines: 7,
          textCapitalization: TextCapitalization.sentences,
          style: DSTypography.bodyMd.copyWith(color: DSColors.textPrimary),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle:
                DSTypography.bodyMd.copyWith(color: DSColors.textPlaceholder),
            filled: true,
            fillColor: DSColors.white,
            contentPadding: const EdgeInsets.all(DSSpacing.lg),
            border: OutlineInputBorder(
              borderRadius: DSRadius.borderMd,
              borderSide: const BorderSide(color: DSColors.gray200),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: DSRadius.borderMd,
              borderSide: const BorderSide(color: DSColors.gray200),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: DSRadius.borderMd,
              borderSide: const BorderSide(color: _kTeal, width: 1.5),
            ),
          ),
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Voice note button
// ─────────────────────────────────────────────────────────────────────────────

class _VoiceNoteButton extends StatelessWidget {
  const _VoiceNoteButton();

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {},
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          color: DSColors.white,
          borderRadius: DSRadius.borderMd,
          border: Border.all(color: DSColors.gray200),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.mic_none_rounded, color: _kTeal, size: 20),
            const SizedBox(width: DSSpacing.sm),
            Text(
              'Add Voice note',
              style: DSTypography.bodyMd.copyWith(
                color: _kTeal,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
