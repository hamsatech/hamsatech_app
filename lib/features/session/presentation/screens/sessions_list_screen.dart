import 'package:flutter/material.dart';
import 'package:hamsatech_design_system/hamsatech_design_system.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';


import '../../../../core/di/injection.dart';
import '../../domain/entities/session_entity.dart';
import '../bloc/session_bloc.dart';
import '../bloc/session_event.dart';
import '../bloc/session_state.dart';

class SessionsListScreen extends StatelessWidget {
  const SessionsListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) =>
          getIt<SessionBloc>()..add(const SessionsLoadRequested()),
      child: const _SessionsListView(),
    );
  }
}

class _SessionsListView extends StatelessWidget {
  const _SessionsListView();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Sessions')),
      body: BlocBuilder<SessionBloc, SessionState>(
        builder: (context, state) {
          if (state is SessionLoading) {
            return const Center(
                child: CircularProgressIndicator(color: DSColors.brand));
          }
          if (state is SessionError) {
            return Center(child: Text(state.message));
          }
          if (state is! SessionsListLoaded) {
            return const SizedBox.shrink();
          }

          final sessions = state.sessions
              .where((s) => s.status == SessionStatus.completed)
              .toList()
            ..sort((a, b) => b.date.compareTo(a.date));

          if (sessions.isEmpty) {
            return Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.fitness_center_rounded,
                      size: 64, color: DSColors.textMuted),
                  const SizedBox(height: 16),
                  Text('No sessions yet',
                      style: DSTypography.headingMedium),
                  const SizedBox(height: 8),
                  Text(
                    'Start a session from the dashboard to\nbuild your training history.',
                    style: DSTypography.bodySmall,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 24),
                  OutlinedButton.icon(
                    onPressed: () => context.go('/home'),
                    icon: const Icon(Icons.add_rounded),
                    label: const Text('Go to Dashboard'),
                  ),
                ],
              ),
            );
          }

          return ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: sessions.length,
            separatorBuilder: (_, __) => const SizedBox(height: 10),
            itemBuilder: (_, i) => _SessionCard(session: sessions[i]),
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.push('/session/pre'),
        backgroundColor: DSColors.brand,
        icon: const Icon(Icons.add_rounded, color: Colors.white),
        label: const Text('New Session',
            style: TextStyle(color: Colors.white)),
      ),
    );
  }
}

class _SessionCard extends StatelessWidget {
  const _SessionCard({required this.session});

  final SessionEntity session;

  @override
  Widget build(BuildContext context) {
    final post = session.postSession;
    final rating = post?.overallRating ?? 0;

    return Container(
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
              Expanded(
                child: Text(
                  DateFormat('EEE, d MMM yyyy').format(session.date),
                  style: DSTypography.headingSmall,
                ),
              ),
              Row(
                children: List.generate(5, (i) {
                  return Icon(
                    i < rating ? Icons.star_rounded : Icons.star_border_rounded,
                    color: DSColors.warning,
                    size: 16,
                  );
                }),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              _Chip(
                icon: Icons.timer_outlined,
                label: '${session.durationMinutes ?? 0}m',
              ),
              const SizedBox(width: 8),
              _Chip(
                icon: Icons.bolt_rounded,
                label: 'Energy ${session.preSession.energy}/10',
                color: DSColors.success,
              ),
              const SizedBox(width: 8),
              _Chip(
                icon: Icons.center_focus_strong_rounded,
                label: 'Focus ${session.preSession.focus}/10',
                color: DSColors.info,
              ),
            ],
          ),
          if (post?.wentWell.isNotEmpty ?? false) ...[
            const SizedBox(height: 10),
            const Divider(color: DSColors.appDivider),
            const SizedBox(height: 8),
            Text(
              post!.wentWell,
              style:
                  DSTypography.bodySmall.copyWith(color: DSColors.textSecondary),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ],
      ),
    );
  }
}

class _Chip extends StatelessWidget {
  const _Chip({required this.icon, required this.label, this.color});

  final IconData icon;
  final String label;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    final c = color ?? DSColors.textSecondary;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: c.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: c),
          const SizedBox(width: 4),
          Text(label,
              style: DSTypography.caption.copyWith(color: c)),
        ],
      ),
    );
  }
}
