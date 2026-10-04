import 'package:flutter/material.dart';
import 'package:hamsatech_design_system/hamsatech_design_system.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/di/injection.dart';

import '../../domain/entities/session_entity.dart';
import '../bloc/session_bloc.dart';
import '../bloc/session_event.dart';
import '../bloc/session_state.dart';

class PreSessionScreen extends StatelessWidget {
  const PreSessionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => getIt<SessionBloc>(),
      child: const _PreSessionView(),
    );
  }
}

class _PreSessionView extends StatefulWidget {
  const _PreSessionView();

  @override
  State<_PreSessionView> createState() => _PreSessionViewState();
}

class _PreSessionViewState extends State<_PreSessionView> {
  int _energy = 5;
  int _focus = 5;
  int _stress = 5;
  int _confidence = 5;

  void _start(BuildContext context) {
    context.read<SessionBloc>().add(
          SessionStartRequested(PreSessionData(
            energy: _energy,
            focus: _focus,
            stress: _stress,
            confidence: _confidence,
          )),
        );
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<SessionBloc, SessionState>(
      listener: (context, state) {
        if (state is SessionStarted) {
          context.pushReplacement('/session/active', extra: state.session.id);
        } else if (state is SessionError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
                content: Text(state.message), backgroundColor: DSColors.error),
          );
        }
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Pre-Session Check'),
          leading: IconButton(
            icon: const Icon(Icons.close_rounded),
            onPressed: () => context.pop(),
          ),
        ),
        body: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'How are you feeling right now?',
                  style: DSTypography.headingLarge,
                ),
                const SizedBox(height: 8),
                Text(
                  'Be honest — this data helps the AI understand your performance patterns.',
                  style: DSTypography.bodyMedium
                      .copyWith(color: DSColors.textSecondary),
                ),
                const SizedBox(height: 36),
                _SliderCard(
                  label: 'Energy Level',
                  subtitle: 'How physically energised do you feel?',
                  value: _energy,
                  icon: Icons.bolt_rounded,
                  color: DSColors.success,
                  onChanged: (v) => setState(() => _energy = v),
                ),
                _SliderCard(
                  label: 'Mental Focus',
                  subtitle: 'How sharp and focused is your mind?',
                  value: _focus,
                  icon: Icons.center_focus_strong_rounded,
                  color: DSColors.info,
                  onChanged: (v) => setState(() => _focus = v),
                ),
                _SliderCard(
                  label: 'Stress Level',
                  subtitle: 'How much stress or anxiety are you experiencing?',
                  value: _stress,
                  icon: Icons.monitor_heart_outlined,
                  color: DSColors.error,
                  onChanged: (v) => setState(() => _stress = v),
                ),
                _SliderCard(
                  label: 'Confidence',
                  subtitle: 'How confident do you feel about today\'s session?',
                  value: _confidence,
                  icon: Icons.emoji_events_outlined,
                  color: DSColors.warning,
                  onChanged: (v) => setState(() => _confidence = v),
                ),
                const SizedBox(height: 32),
                BlocBuilder<SessionBloc, SessionState>(
                  builder: (context, state) => DSButton(
                    label: 'Start Training Session',
                    onPressed: () => _start(context),
                    isLoading: state is SessionLoading,
                    leadingIcon: const Icon(Icons.play_arrow_rounded),
                    isFullWidth: true,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _SliderCard extends StatelessWidget {
  const _SliderCard({
    required this.label,
    required this.subtitle,
    required this.value,
    required this.icon,
    required this.color,
    required this.onChanged,
  });

  final String label;
  final String subtitle;
  final int value;
  final IconData icon;
  final Color color;
  final ValueChanged<int> onChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: DSColors.appCard,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: DSColors.appBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: color, size: 20),
              const SizedBox(width: 8),
              Text(label, style: DSTypography.labelLarge),
              const Spacer(),
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.15),
                  shape: BoxShape.circle,
                ),
                alignment: Alignment.center,
                child: Text(
                  '$value',
                  style: DSTypography.headingSmall.copyWith(color: color),
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(subtitle, style: DSTypography.bodySmall),
          Slider(
            value: value.toDouble(),
            min: 1,
            max: 10,
            divisions: 9,
            label: '$value',
            activeColor: color,
            onChanged: (v) => onChanged(v.round()),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Low', style: DSTypography.caption),
              Text('High', style: DSTypography.caption),
            ],
          ),
        ],
      ),
    );
  }
}
