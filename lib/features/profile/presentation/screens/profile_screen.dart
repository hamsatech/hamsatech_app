import 'package:flutter/material.dart';
import 'package:hamsatech_design_system/hamsatech_design_system.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/di/injection.dart';
import '../../../../core/services/api_service.dart';
import '../../../../core/services/auth_helper.dart';
import '../../../../core/services/storage_service.dart';
import '../../../auth/presentation/bloc/auth_bloc.dart';
import '../../../auth/presentation/bloc/auth_event.dart';
import '../../../auth/presentation/bloc/auth_state.dart';

const _kTeal = Color(0xFF2F7E8F);

double _safeNum(dynamic value) {
  if (value is num) return value.toDouble();
  if (value is List && value.isNotEmpty && value.first is num) {
    return (value.first as num).toDouble();
  }
  if (value is String) return double.tryParse(value) ?? 0.0;
  return 0.0;
}

int? _safeInt(dynamic value) {
  if (value is int) return value;
  if (value is num) return value.toInt();
  if (value is String) return int.tryParse(value);
  if (value is List && value.isNotEmpty) return _safeInt(value.first);
  return null;
}

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => getIt<AuthBloc>(),
      child: const _ProfileView(),
    );
  }
}

class _ProfileView extends StatefulWidget {
  const _ProfileView();

  @override
  State<_ProfileView> createState() => _ProfileViewState();
}

class _ProfileViewState extends State<_ProfileView> {
  @override
  void initState() {
    super.initState();
    _syncProfileFromApi();
  }

  void _syncProfileFromApi() {
    final athleteId = AuthHelper.getCurrentAthleteId();
    if (athleteId == null) return;

    Future(() async {
      try {
        final res = await ApiService.instance.getMobileAthleteProfile(athleteId);
        final raw = res.data;
        Map<String, dynamic>? apiData;
        if (raw is Map<String, dynamic>) {
          apiData = raw;
        } else if (raw is Map && raw['data'] is Map<String, dynamic>) {
          apiData = raw['data'] as Map<String, dynamic>;
        }
        if (apiData == null || apiData.isEmpty) return;

        final existing = StorageService.getAthleteProfile() ?? {};
        final merged = Map<String, dynamic>.from(existing);

        String? pick(List<String> keys) {
          for (final k in keys) {
            final v = apiData![k];
            if (v != null && v.toString().trim().isNotEmpty) return v.toString().trim();
          }
          return null;
        }

        final name = pick(['name', 'athlete_name', 'full_name']);
        if (name != null) merged['name'] = name;

        final age = apiData['age'];
        if (age != null) merged['age'] = age;

        final sport = pick(['sport_domain', 'sport', 'sportDomain']);
        if (sport != null) merged['sportDomain'] = sport;

        final expLevel = pick(['experience_level', 'experienceLevel']);
        if (expLevel != null) merged['experienceLevel'] = expLevel;

        final goal30 = pick(['goal_30', 'short_term_goal', 'goal30']);
        if (goal30 != null) merged['goal30'] = goal30;

        final goal6 = pick(['goal_6_month', 'long_term_goal', 'goal6Month']);
        if (goal6 != null) merged['goal6Month'] = goal6;

        await StorageService.saveAthleteProfile(merged);
        debugPrint('[PROFILE] local profile updated from API');
        if (mounted) setState(() {});
      } catch (e) {
        debugPrint('[PROFILE] API fetch failed (non-fatal): $e');
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final profile = StorageService.getAthleteProfile();
    final sessions = StorageService.getSessions();
    final scoreSummary = StorageService.getScoreSummary() ?? [];

    final name = profile?['name'] as String? ?? 'Athlete';
    final age = _safeInt(profile?['age']);
    final sportDomain = profile?['sportDomain'] as String? ?? '';
    final experienceLevel = profile?['experienceLevel'] as String? ?? '';

    final sessionCount = sessions.length;
    final streak = _computeStreak(sessions);
    final level = (sessionCount ~/ 5) + 1;
    final avgScore = _computeAvgScore(sessions);
    final personalBest = _computePersonalBest(sessions);
    final totalShots = _computeTotalShots(scoreSummary);

    final goal30 = profile?['goal30'] as String? ?? '';
    final goal6Month = profile?['goal6Month'] as String? ?? '';

    return BlocListener<AuthBloc, AuthState>(
      listener: (context, state) {
        if (state is AuthUnauthenticated) {
          StorageService.clearAll();
          context.go('/login');
        }
      },
      child: Scaffold(
        backgroundColor: DSColors.appBackground,
        appBar: AppBar(
          backgroundColor: DSColors.appBackground,
          elevation: 0,
          scrolledUnderElevation: 0,
          centerTitle: true,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: DSColors.black),
            onPressed: () => Navigator.of(context).maybePop(),
          ),
          title: Text(
            'Profile',
            style: DSTypography.headingSm.copyWith(color: DSColors.black),
          ),
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 40),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── Page header ──────────────────────────────────────────────
              _PageHeader(),
              const SizedBox(height: 16),

              // ── Athlete identity card ────────────────────────────────────
              _AthleteCard(
                name: name,
                age: age,
                sportDomain: sportDomain,
                streak: streak,
                level: level,
              ),
              const SizedBox(height: 14),

              // ── Tag chips ────────────────────────────────────────────────
              _TagsRow(
                experienceLevel: experienceLevel,
                sportDomain: sportDomain,
              ),
              const SizedBox(height: 20),

              // ── Stats 2×2 grid ───────────────────────────────────────────
              _StatsGrid(
                avgScore: avgScore,
                personalBest: personalBest,
                sessionCount: sessionCount,
                totalShots: totalShots,
              ),
              const SizedBox(height: 20),

              // ── Quick Psychology Scores ──────────────────────────────────
              const _PsychologyCard(),
              const SizedBox(height: 20),

              // ── Goals ────────────────────────────────────────────────────
              _GoalsSectionHeader(),
              const SizedBox(height: 12),
              _GoalsCard(goal30: goal30, goal6Month: goal6Month),
              const SizedBox(height: 32),

              // ── Sign Out ─────────────────────────────────────────────────
              DSButton(
                label: 'Sign Out',
                variant: DSButtonVariant.danger,
                onPressed: () => _confirmLogout(context),
                leadingIcon: const Icon(Icons.logout_rounded),
                isFullWidth: true,
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ── Data computation (unchanged) ─────────────────────────────────────────

  int _computeStreak(List<Map<String, dynamic>> sessions) {
    if (sessions.isEmpty) return 0;
    final dates = <DateTime>{};
    for (final s in sessions) {
      final raw = s['date'] as String?;
      if (raw != null) {
        try {
          final d = DateTime.parse(raw);
          dates.add(DateTime(d.year, d.month, d.day));
        } catch (_) {}
      }
    }
    if (dates.isEmpty) return 0;
    final sorted = dates.toList()..sort((a, b) => b.compareTo(a));
    var streak = 0;
    var current = DateTime.now();
    current = DateTime(current.year, current.month, current.day);
    for (final d in sorted) {
      if (d == current || d == current.subtract(const Duration(days: 1))) {
        streak++;
        current = d.subtract(const Duration(days: 1));
      } else {
        break;
      }
    }
    return streak;
  }

  String _computeAvgScore(List<Map<String, dynamic>> sessions) {
    if (sessions.isEmpty) return '—';
    final scores = <double>[];
    for (final s in sessions) {
      final v = s['avgScore'] ?? s['totalScore'] ?? s['score'];
      if (v != null) scores.add(_safeNum(v));
    }
    if (scores.isEmpty) return '—';
    return (scores.reduce((a, b) => a + b) / scores.length).toStringAsFixed(0);
  }

  String _computePersonalBest(List<Map<String, dynamic>> sessions) {
    if (sessions.isEmpty) return '—';
    final scores = <double>[];
    for (final s in sessions) {
      final v = s['avgScore'] ?? s['totalScore'] ?? s['score'];
      if (v != null) scores.add(_safeNum(v));
    }
    if (scores.isEmpty) return '—';
    return scores.reduce((a, b) => a > b ? a : b).toStringAsFixed(0);
  }

  String _computeTotalShots(List<Map<String, dynamic>> scoreSummary) {
    if (scoreSummary.isEmpty) return '—';
    var total = 0;
    for (final s in scoreSummary) {
      final shots = s['shots'] ?? s['totalShots'] ?? s['count'];
      if (shots != null) total += _safeNum(shots).toInt();
    }
    return total > 0 ? total.toString() : '—';
  }

  void _confirmLogout(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: DSColors.appCard,
        title: const Text('Sign Out?'),
        content: Text(
          'Your local data will be cleared. Are you sure?',
          style: DSTypography.bodyMedium,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: DSColors.error),
            onPressed: () {
              Navigator.pop(ctx);
              context.read<AuthBloc>().add(const AuthLogoutRequested());
            },
            child: const Text('Sign Out'),
          ),
        ],
      ),
    );
  }
}

// ── Page header ───────────────────────────────────────────────────────────────

class _PageHeader extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Astra Performance',
          style: DSTypography.caption.copyWith(
            color: DSColors.brand,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.5,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          'Athlete Profile',
          style: DSTypography.headingXl.copyWith(
            color: DSColors.textPrimary,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 3),
        Text(
          'Identity, coach, psychology and score history',
          style: DSTypography.bodySm.copyWith(
            color: DSColors.textSecondary,
          ),
        ),
      ],
    );
  }
}

// ── Athlete identity card ─────────────────────────────────────────────────────

class _AthleteCard extends StatelessWidget {
  const _AthleteCard({
    required this.name,
    required this.age,
    required this.sportDomain,
    required this.streak,
    required this.level,
  });

  final String name;
  final int? age;
  final String sportDomain;
  final int streak;
  final int level;

  @override
  Widget build(BuildContext context) {
    final initials = name.trim().isNotEmpty
        ? name.trim().split(' ').map((w) => w[0].toUpperCase()).take(2).join()
        : 'A';

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: DSColors.appCard,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: DSColors.gray200),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          // Avatar
          Container(
            width: 56,
            height: 56,
            decoration: const BoxDecoration(
              color: Color(0xFF1D3A40),
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                initials,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ),
          const SizedBox(width: 14),
          // Info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: DSTypography.headingMd.copyWith(
                    color: DSColors.textPrimary,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                if (sportDomain.isNotEmpty) ...[
                  const SizedBox(height: 3),
                  Text(
                    sportDomain,
                    style: DSTypography.bodySm.copyWith(
                      color: DSColors.textSecondary,
                    ),
                  ),
                ],
                const SizedBox(height: 3),
                Text(
                  'Coach — Not linked',
                  style: DSTypography.caption.copyWith(
                    color: DSColors.textMuted,
                  ),
                ),
              ],
            ),
          ),
          // Streak + level
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              _MiniStat(
                icon: Icons.local_fire_department_rounded,
                iconColor: const Color(0xFFF59E0B),
                value: '$streak',
                label: 'streak',
              ),
              const SizedBox(height: 8),
              _MiniStat(
                value: 'Lvl $level',
                label: 'rank',
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _MiniStat extends StatelessWidget {
  const _MiniStat({
    this.icon,
    this.iconColor,
    required this.value,
    required this.label,
  });
  final IconData? icon;
  final Color? iconColor;
  final String value;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (icon != null) ...[
              Icon(icon, size: 14, color: iconColor),
              const SizedBox(width: 3),
            ],
            Text(
              value,
              style: DSTypography.headingSm.copyWith(
                color: DSColors.textPrimary,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
        Text(
          label,
          style: DSTypography.caption.copyWith(color: DSColors.textSecondary),
        ),
      ],
    );
  }
}

// ── Tag chips ─────────────────────────────────────────────────────────────────

class _TagsRow extends StatelessWidget {
  const _TagsRow({required this.experienceLevel, required this.sportDomain});

  final String experienceLevel;
  final String sportDomain;

  @override
  Widget build(BuildContext context) {
    final tags = <_TagData>[
      const _TagData(label: 'Right dominant', color: Color(0xFF2F7E8F)),
      if (experienceLevel.isNotEmpty)
        _TagData(label: experienceLevel, color: const Color(0xFF6366F1))
      else
        const _TagData(label: 'Intermediate', color: Color(0xFF6366F1)),
      const _TagData(label: 'Training', color: Color(0xFFF59E0B)),
    ];

    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: tags.map((t) => _TagChip(data: t)).toList(),
    );
  }
}

class _TagData {
  const _TagData({required this.label, required this.color});
  final String label;
  final Color color;
}

class _TagChip extends StatelessWidget {
  const _TagChip({required this.data});
  final _TagData data;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: data.color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: data.color.withValues(alpha: 0.3)),
      ),
      child: Text(
        data.label,
        style: DSTypography.caption.copyWith(
          color: data.color,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

// ── Stats 2×2 grid ────────────────────────────────────────────────────────────

class _StatsGrid extends StatelessWidget {
  const _StatsGrid({
    required this.avgScore,
    required this.personalBest,
    required this.sessionCount,
    required this.totalShots,
  });

  final String avgScore;
  final String personalBest;
  final int sessionCount;
  final String totalShots;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: _StatCard(
                label: 'BEST AVG',
                value: avgScore,
                subLabel: '30 days',
                dotColor: DSColors.success,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _StatCard(
                label: 'PERIOD AVG',
                value: personalBest,
                subLabel: '$sessionCount sessions',
                dotColor: DSColors.brand,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _StatCard(
                label: 'BEST SERIES',
                value: totalShots,
                subLabel: 'all time',
                dotColor: DSColors.success,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _StatCard(
                label: 'LAST SESSION',
                value: sessionCount > 0 ? '$sessionCount' : '—',
                subLabel: 'sessions total',
                dotColor: const Color(0xFFF59E0B),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _StatCard extends StatelessWidget {
  const _StatCard({
    required this.label,
    required this.value,
    required this.subLabel,
    required this.dotColor,
  });

  final String label;
  final String value;
  final String subLabel;
  final Color dotColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: DSColors.appCard,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: DSColors.gray200),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: DSTypography.labelXs.copyWith(
              color: DSColors.textSecondary,
              fontWeight: FontWeight.w600,
              letterSpacing: 0.6,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: DSTypography.headingXl.copyWith(
              color: DSColors.textPrimary,
              fontWeight: FontWeight.w700,
              fontSize: 28,
              height: 1.0,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Container(
                width: 6,
                height: 6,
                decoration: BoxDecoration(
                  color: dotColor,
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 5),
              Expanded(
                child: Text(
                  subLabel,
                  style: DSTypography.caption.copyWith(
                    color: DSColors.textSecondary,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ── Quick Psychology Scores ───────────────────────────────────────────────────

class _PsychologyCard extends StatelessWidget {
  const _PsychologyCard();

  static const _scores = [
    _PsychScore(label: 'Social', value: 72, color: Color(0xFF22C55E)),
    _PsychScore(label: 'Arousal', value: 61, color: Color(0xFFF59E0B)),
    _PsychScore(label: 'Decision', value: 80, color: Color(0xFF2F7E8F)),
    _PsychScore(label: 'Focus', value: 82, color: Color(0xFF6366F1)),
    _PsychScore(label: 'Recovery', value: 66, color: Color(0xFFEF4444)),
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: DSColors.appCard,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: DSColors.gray200),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Quick Psychology Scores',
            style: DSTypography.headingMd.copyWith(
              color: DSColors.textPrimary,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 16),
          for (int i = 0; i < _scores.length; i++) ...[
            _PsychBar(score: _scores[i]),
            if (i < _scores.length - 1) const SizedBox(height: 12),
          ],
        ],
      ),
    );
  }
}

class _PsychScore {
  const _PsychScore({
    required this.label,
    required this.value,
    required this.color,
  });
  final String label;
  final int value;
  final Color color;
}

class _PsychBar extends StatelessWidget {
  const _PsychBar({required this.score});
  final _PsychScore score;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        SizedBox(
          width: 76,
          child: Text(
            score.label,
            style: DSTypography.bodySm.copyWith(
              color: DSColors.textPrimary,
            ),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: score.value / 100,
              backgroundColor: DSColors.gray100,
              valueColor: AlwaysStoppedAnimation<Color>(score.color),
              minHeight: 8,
            ),
          ),
        ),
        const SizedBox(width: 10),
        SizedBox(
          width: 28,
          child: Text(
            '${score.value}',
            style: DSTypography.bodySmall.copyWith(
              color: DSColors.textPrimary,
              fontWeight: FontWeight.w600,
            ),
            textAlign: TextAlign.right,
          ),
        ),
      ],
    );
  }
}

// ── Goals section ─────────────────────────────────────────────────────────────

class _GoalsSectionHeader extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          'Goals',
          style: DSTypography.headingMd.copyWith(
            color: DSColors.textPrimary,
            fontWeight: FontWeight.w700,
          ),
        ),
        GestureDetector(
          onTap: () {},
          child: Text(
            'Edit Goals →',
            style: DSTypography.labelSm.copyWith(color: _kTeal),
          ),
        ),
      ],
    );
  }
}

class _GoalsCard extends StatelessWidget {
  const _GoalsCard({required this.goal30, required this.goal6Month});

  final String goal30;
  final String goal6Month;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: DSColors.appCard,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: DSColors.gray200),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _GoalRow(
            label: 'Short-term (30 Days)',
            goal: goal30.isNotEmpty ? goal30 : 'Not set yet',
            progress: 0.0,
          ),
          const SizedBox(height: 16),
          _GoalRow(
            label: 'Long-term (6 Months)',
            goal: goal6Month.isNotEmpty ? goal6Month : 'Not set yet',
            progress: 0.0,
          ),
          const SizedBox(height: 16),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            decoration: BoxDecoration(
              color: _kTeal.withValues(alpha: 0.07),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: _kTeal.withValues(alpha: 0.2)),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('⭐', style: TextStyle(fontSize: 16)),
                const SizedBox(width: 10),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Dream Goal',
                      style: DSTypography.caption.copyWith(
                        color: DSColors.textSecondary,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Not set yet',
                      style: DSTypography.bodySm.copyWith(
                        color: DSColors.textPrimary,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _GoalRow extends StatelessWidget {
  const _GoalRow({
    required this.label,
    required this.goal,
    required this.progress,
  });

  final String label;
  final String goal;
  final double progress;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Text(
                '$label: $goal',
                style: DSTypography.bodySm.copyWith(
                  color: DSColors.textPrimary,
                ),
              ),
            ),
            const SizedBox(width: 8),
            Text(
              '${(progress * 100).toInt()}%',
              style: DSTypography.labelSm.copyWith(
                color: DSColors.textSecondary,
              ),
            ),
          ],
        ),
        const SizedBox(height: 6),
        ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: LinearProgressIndicator(
            value: progress,
            backgroundColor: DSColors.gray100,
            valueColor: const AlwaysStoppedAnimation<Color>(_kTeal),
            minHeight: 6,
          ),
        ),
      ],
    );
  }
}
