import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:hamsatech_design_system/hamsatech_design_system.dart';

import '../../../../core/di/injection.dart';
import '../../../../core/services/storage_service.dart';
import '../bloc/session_setup_bloc.dart';
import '../bloc/session_setup_event.dart';
import '../bloc/session_setup_state.dart';
import '../widgets/begin_ritual_button.dart';
import '../widgets/discipline_dropdown.dart';
import '../widgets/planned_shots_selector.dart';
import '../widgets/range_type_selector.dart';
import '../widgets/session_type_selector.dart';

class SessionSetupScreen extends StatelessWidget {
  const SessionSetupScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) =>
          getIt<SessionSetupBloc>()..add(const SessionSetupLoadRequested()),
      child: const _SessionSetupView(),
    );
  }
}

class _SessionSetupView extends StatelessWidget {
  const _SessionSetupView();

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<SessionSetupBloc, SessionSetupState>(
      listener: (context, state) {
        if (state is SessionSetupSuccess) {
          if (StorageService.isPolarEnabled()) {
            context.push('/session/live');
          } else {
            context.push('/session/scores');
          }
        } else if (state is SessionSetupError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.message),
              backgroundColor: DSColors.error,
            ),
          );
        }
      },
      builder: (context, state) {
        final editing = state is SessionSetupEditing
            ? state
            : const SessionSetupEditing();

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
              'Set up your session',
              style: DSTypography.headingMd.copyWith(
                color: DSColors.textPrimary,
              ),
            ),
            bottom: PreferredSize(
              preferredSize: const Size.fromHeight(1),
              child: Container(height: 1, color: DSColors.appBorder),
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
                      // ── Header ──────────────────────────────────────────
                      Text(
                        'New session',
                        style: DSTypography.headingXl.copyWith(
                          color: DSColors.textPrimary,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Set up your training parameters.',
                        style: DSTypography.bodyMd.copyWith(
                          color: DSColors.textSecondary,
                        ),
                      ),

                      const SizedBox(height: 32),

                      // ── Range type ───────────────────────────────────────
                      _SectionLabel(label: 'Range type today'),
                      const SizedBox(height: 10),
                      RangeTypeSelector(
                        selected: editing.rangeType,
                        onChanged: (v) => context
                            .read<SessionSetupBloc>()
                            .add(SessionSetupRangeTypeChanged(v)),
                      ),

                      const SizedBox(height: 28),

                      // ── Session type ─────────────────────────────────────
                      _SectionLabel(label: 'Session type'),
                      const SizedBox(height: 10),
                      SessionTypeSelector(
                        selected: editing.sessionType,
                        onSelected: (v) => context
                            .read<SessionSetupBloc>()
                            .add(SessionSetupSessionTypeChanged(v)),
                      ),

                      const SizedBox(height: 28),

                      // ── Planned shots ────────────────────────────────────
                      _SectionLabel(label: 'Planned shots'),
                      const SizedBox(height: 10),
                      PlannedShotsSelector(
                        value: editing.plannedShots,
                        quickSelectValues: SessionSetupEditing.quickSelectValues,
                        min: SessionSetupEditing.minShots,
                        max: SessionSetupEditing.maxShots,
                        onChanged: (v) => context
                            .read<SessionSetupBloc>()
                            .add(SessionSetupShotsChanged(v)),
                      ),

                      const SizedBox(height: 28),

                      // ── Discipline ───────────────────────────────────────
                      _SectionLabel(label: 'Discipline'),
                      const SizedBox(height: 10),
                      DisciplineDropdown(
                        disciplines: editing.disciplines,
                        selected: editing.discipline,
                        onSelected: (d) => context
                            .read<SessionSetupBloc>()
                            .add(SessionSetupDisciplineChanged(d)),
                      ),

                      const SizedBox(height: 16),
                    ],
                  ),
                ),
              ),

              // ── Sticky CTA ───────────────────────────────────────────────
              BeginRitualButton(
                canBegin: editing.canBeginRitual,
                isLoading: editing.isSubmitting,
                onTap: () => context
                    .read<SessionSetupBloc>()
                    .add(const SessionSetupBeginRitualRequested()),
              ),
            ],
          ),
        );
      },
    );
  }
}

// ─── Section label ────────────────────────────────────────────────────────────

class _SectionLabel extends StatelessWidget {
  const _SectionLabel({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Text(
      label,
      style: DSTypography.headingSm.copyWith(
        color: DSColors.textPrimary,
      ),
    );
  }
}
