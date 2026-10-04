import 'package:flutter/material.dart';
import 'package:hamsatech_design_system/hamsatech_design_system.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../../core/services/api_service.dart';
import '../../../../core/services/auth_helper.dart';
import '../../../../core/services/session_memory.dart';
import '../../../../core/services/storage_service.dart';
import '../../data/models/session_history_item_model.dart';

/// Real session history, backed by
/// `GET /api/mobile/athletes/{athleteId}/sessions` — replaces the previous
/// local-only (`StorageService.getSessions()`) source. Only fields the
/// backend actually returns are shown; see `SessionHistoryItemModel`'s
/// doc comment for what was intentionally left out and why.
class SessionsListScreen extends StatefulWidget {
  const SessionsListScreen({super.key});

  @override
  State<SessionsListScreen> createState() => _SessionsListScreenState();
}

enum _LoadState { loading, loaded, error }

class _SessionsListScreenState extends State<SessionsListScreen> {
  _LoadState _state = _LoadState.loading;
  List<SessionHistoryItemModel> _sessions = const [];
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final athleteId = AuthHelper.getCurrentAthleteId();
    if (athleteId == null) {
      setState(() {
        _state = _LoadState.error;
        _errorMessage = 'Unable to load sessions — please sign in again.';
      });
      return;
    }

    setState(() => _state = _LoadState.loading);
    try {
      final res = await ApiService.instance.getSessionHistory(athleteId: athleteId);
      final body = res.data;
      final rawItems = body is Map<String, dynamic> ? body['data'] : null;
      final items = rawItems is List
          ? rawItems
              .map((e) => SessionHistoryItemModel.fromJson(e as Map<String, dynamic>))
              .toList()
          : <SessionHistoryItemModel>[];

      setState(() {
        _sessions = items;
        _state = _LoadState.loaded;
      });
    } catch (_) {
      setState(() {
        _state = _LoadState.error;
        _errorMessage = 'Could not load your session history. Pull down to try again.';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Sessions')),
      body: RefreshIndicator(
        onRefresh: _load,
        child: _buildBody(),
      ),
      floatingActionButton: FloatingActionButton.extended(
        heroTag: 'fab_sessions',
        onPressed: () => context.push('/session/setup'),
        backgroundColor: DSColors.brand,
        icon: const Icon(Icons.add_rounded, color: Colors.white),
        label: const Text('New Session', style: TextStyle(color: Colors.white)),
      ),
    );
  }

  Widget _buildBody() {
    switch (_state) {
      case _LoadState.loading:
        return const Center(child: CircularProgressIndicator(color: DSColors.brand));
      case _LoadState.error:
        return LayoutBuilder(
          builder: (_, constraints) => SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            child: ConstrainedBox(
              constraints: BoxConstraints(minHeight: constraints.maxHeight),
              child: Center(child: Text(_errorMessage ?? 'Something went wrong.')),
            ),
          ),
        );
      case _LoadState.loaded:
        if (_sessions.isEmpty) {
          return LayoutBuilder(
            builder: (_, constraints) => SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              child: ConstrainedBox(
                constraints: BoxConstraints(minHeight: constraints.maxHeight),
                child: Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.fitness_center_rounded,
                          size: 64, color: DSColors.textMuted),
                      const SizedBox(height: 16),
                      Text('No sessions yet', style: DSTypography.headingMedium),
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
                ),
              ),
            ),
          );
        }
        return ListView.separated(
          padding: const EdgeInsets.all(16),
          itemCount: _sessions.length,
          separatorBuilder: (_, __) => const SizedBox(height: 10),
          itemBuilder: (context, i) => _SessionCard(
            item: _sessions[i],
            onTap: () => _openSessionReport(context, _sessions[i]),
          ),
        );
    }
  }

  /// Navigates to the existing session report screen for exactly the
  /// tapped session — never a fabricated/cached one. The report screen
  /// (`SessionReportScreen`/`SessionReportBloc`) takes no route parameter;
  /// it resolves which session to show via `SessionMemory.sessionId ??
  /// StorageService.getSessionId()` (see
  /// `SessionReportRepositoryImpl._fetchSessionReport`), so this sets both
  /// of those existing slots to the real, backend-returned `session_id`
  /// before navigating — the same convention already used elsewhere in the
  /// app to tell that screen which session to load, not a new mechanism.
  void _openSessionReport(BuildContext context, SessionHistoryItemModel item) {
    final sessionId = item.sessionId;
    if (sessionId.isEmpty) {
      // Defensive only: the backend always returns a real session_id for
      // every history item. Never navigate with a fabricated ID.
      return;
    }
    SessionMemory.sessionId = sessionId;
    StorageService.saveSessionId(sessionId);
    context.go('/session/report');
  }
}

class _SessionCard extends StatelessWidget {
  const _SessionCard({required this.item, required this.onTap});

  final SessionHistoryItemModel item;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final durationMinutes = item.durationSeconds ~/ 60;

    return Material(
      color: DSColors.appCard,
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
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
                      DateFormat('EEE, d MMM yyyy').format(item.startTime.toLocal()),
                      style: DSTypography.headingSmall,
                    ),
                  ),
                  if (item.sessionType != null)
                    Text(item.sessionType!, style: DSTypography.caption),
                ],
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  _Chip(icon: Icons.timer_outlined, label: '${durationMinutes}m'),
                  if (item.avgScore != null)
                    _Chip(
                      icon: Icons.military_tech_outlined,
                      label: 'Avg ${item.avgScore!.toStringAsFixed(1)}',
                      color: DSColors.success,
                    )
                  else
                    const _Chip(icon: Icons.military_tech_outlined, label: 'No score yet'),
                  if (item.seriesCount > 0)
                    _Chip(
                      icon: Icons.format_list_numbered_rounded,
                      label: '${item.seriesCount} series',
                      color: DSColors.info,
                    ),
                  if (item.totalShots != null)
                    _Chip(
                      icon: Icons.gps_fixed_rounded,
                      label: '${item.totalShots} shots',
                    ),
                ],
              ),
            ],
          ),
        ),
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
          Text(label, style: DSTypography.caption.copyWith(color: c)),
        ],
      ),
    );
  }
}
