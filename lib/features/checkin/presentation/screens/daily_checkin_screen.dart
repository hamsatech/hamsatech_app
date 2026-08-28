import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:hamsatech_design_system/hamsatech_design_system.dart';

import '../../../../core/di/injection.dart';
import '../bloc/daily_checkin_bloc.dart';
import '../bloc/daily_checkin_event.dart';
import '../bloc/daily_checkin_state.dart';
import '../widgets/emotion_chip_group.dart';
import '../widgets/energy_slider.dart';
import '../widgets/mood_selector.dart';
import '../widgets/save_checkin_button.dart';
import '../widgets/sleep_selector.dart';

class DailyCheckinScreen extends StatelessWidget {
  const DailyCheckinScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) =>
          getIt<DailyCheckinBloc>()..add(const DailyCheckinLoadRequested()),
      child: const _DailyCheckinView(),
    );
  }
}

class _DailyCheckinView extends StatelessWidget {
  const _DailyCheckinView();

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<DailyCheckinBloc, DailyCheckinState>(
      listener: (context, state) {
        if (state is DailyCheckinSuccess) {
          context.pushReplacement('/session/setup');
        } else if (state is DailyCheckinError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.message),
              backgroundColor: DSColors.error,
            ),
          );
        }
      },
      builder: (context, state) {
        final editing =
            state is DailyCheckinEditing ? state : const DailyCheckinEditing();

        return Scaffold(
          backgroundColor: DSColors.appBackground,
          appBar: AppBar(
            backgroundColor: DSColors.appSurface,
            elevation: 0,
            centerTitle: true,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back_rounded),
              color: DSColors.textPrimary,
              onPressed: () => context.pop(),
            ),
            title: Text(
              'Daily Check-in',
              style: DSTypography.headingMd.copyWith(
                color: DSColors.textPrimary,
              ),
            ),
            bottom: PreferredSize(
              preferredSize: const Size.fromHeight(1),
              child: Container(
                height: 1,
                color: DSColors.appBorder,
              ),
            ),
          ),
          body: Column(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(20, 28, 20, 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // ── Mood ─────────────────────────────────────────────
                      _SectionTitle(label: 'How are you feeling?'),
                      const SizedBox(height: 14),
                      MoodSelector(
                        selected: editing.mood,
                        onSelected: (mood) => context
                            .read<DailyCheckinBloc>()
                            .add(DailyCheckinMoodChanged(mood)),
                      ),

                      const SizedBox(height: 32),

                      // ── Energy ───────────────────────────────────────────
                      _SectionTitle(label: 'Energy level'),
                      const SizedBox(height: 8),
                      EnergySlider(
                        value: editing.energy,
                        onChanged: (v) => context
                            .read<DailyCheckinBloc>()
                            .add(DailyCheckinEnergyChanged(v)),
                      ),

                      const SizedBox(height: 32),

                      // ── Sleep ─────────────────────────────────────────────
                      _SectionTitle(label: 'How did you sleep?'),
                      const SizedBox(height: 6),
                      _SleepSubtitle(estimate: editing.polarSleepEstimate),
                      const SizedBox(height: 14),
                      SleepSelector(
                        selected: editing.sleep,
                        onSelected: (sleep) => context
                            .read<DailyCheckinBloc>()
                            .add(DailyCheckinSleepChanged(sleep)),
                      ),

                      const SizedBox(height: 32),

                      // ── Emotions ─────────────────────────────────────────
                      Row(
                        children: [
                          _SectionTitle(label: 'Any of these apply?'),
                          const Spacer(),
                          Text(
                            '(optional)',
                            style: DSTypography.bodyXs.copyWith(
                              color: DSColors.textMuted,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 14),
                      EmotionChipGroup(
                        selected: editing.emotions,
                        onToggled: (tag) => context
                            .read<DailyCheckinBloc>()
                            .add(DailyCheckinEmotionToggled(tag)),
                      ),

                      const SizedBox(height: 16),
                    ],
                  ),
                ),
              ),

              // ── Sticky CTA ───────────────────────────────────────────────
              SaveCheckinButton(
                canSave: editing.canSubmit,
                isLoading: editing.isSubmitting,
                onSave: () => context
                    .read<DailyCheckinBloc>()
                    .add(const DailyCheckinSubmitRequested()),
              ),
            ],
          ),
        );
      },
    );
  }
}

// ─── Section title ────────────────────────────────────────────────────────────

class _SectionTitle extends StatelessWidget {
  const _SectionTitle({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Text(
      label,
      style: DSTypography.headingMd.copyWith(
        color: DSColors.textPrimary,
      ),
    );
  }
}

// ─── Sleep subtitle ───────────────────────────────────────────────────────────

class _SleepSubtitle extends StatelessWidget {
  const _SleepSubtitle({this.estimate});

  final String? estimate;

  @override
  Widget build(BuildContext context) {
    final text = estimate != null
        ? 'We saw $estimate from your Polar. Confirm or adjust:'
        : 'Select how many hours you slept last night:';
    return Text(
      text,
      style: DSTypography.bodyMd.copyWith(color: DSColors.textSecondary),
    );
  }
}
