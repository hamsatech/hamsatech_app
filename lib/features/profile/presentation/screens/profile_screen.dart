import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_text_styles.dart';
import '../../../../core/di/injection.dart';
import '../../../../core/services/storage_service.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/score_ring.dart';
import '../../../auth/presentation/bloc/auth_bloc.dart';
import '../../../auth/presentation/bloc/auth_event.dart';
import '../../../auth/presentation/bloc/auth_state.dart';

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

class _ProfileView extends StatelessWidget {
  const _ProfileView();

  @override
  Widget build(BuildContext context) {
    final profile = StorageService.getAthleteProfile();
    final scores = StorageService.getBaselineScores() ?? {};

    final name = profile?['name'] as String? ?? 'Athlete';
    final sportDomain = profile?['sportDomain'] as String? ?? '—';
    final experienceLevel = profile?['experienceLevel'] as String? ?? '—';
    final familySupport = profile?['familySupport'] as String? ?? '—';
    final pressureSources =
        (profile?['pressureSources'] as List?)?.cast<String>() ?? [];

    final focus = scores['focus'] ?? 0;
    final emotional = scores['emotionalStability'] ?? 0;
    final decision = scores['decisionStyle'] ?? 0;
    final motivation = scores['motivation'] ?? 0;
    final overall =
        focus * 0.30 + emotional * 0.25 + decision * 0.25 + motivation * 0.20;

    return BlocListener<AuthBloc, AuthState>(
      listener: (context, state) {
        if (state is AuthUnauthenticated) {
          StorageService.clearAll();
          context.go('/login');
        }
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Profile'),
          actions: [
            IconButton(
              icon: const Icon(Icons.logout_rounded,
                  color: AppColors.textSecondary),
              onPressed: () => _confirmLogout(context),
            ),
          ],
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Athlete card
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      AppColors.primary.withValues(alpha: 0.15),
                      AppColors.card,
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                      color: AppColors.primary.withValues(alpha: 0.3)),
                ),
                child: Row(
                  children: [
                    CircleAvatar(
                      radius: 32,
                      backgroundColor:
                          AppColors.primary.withValues(alpha: 0.2),
                      child: Text(
                        name.isNotEmpty ? name[0].toUpperCase() : 'A',
                        style: AppTextStyles.displayMedium
                            .copyWith(color: AppColors.primary),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(name, style: AppTextStyles.headingMedium),
                          const SizedBox(height: 4),
                          Text(sportDomain,
                              style: AppTextStyles.bodySmall
                                  .copyWith(color: AppColors.primary)),
                          Text(experienceLevel,
                              style: AppTextStyles.caption),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // Baseline scores
              _SectionCard(
                title: 'Baseline Scores',
                icon: Icons.analytics_rounded,
                iconColor: AppColors.accent,
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        _ScoreCol('Overall', overall, AppColors.primary),
                        _ScoreCol('Focus', focus, AppColors.accent),
                        _ScoreCol('Emotional', emotional, AppColors.secondary),
                        _ScoreCol('Decision', decision, AppColors.warning),
                        _ScoreCol('Motivation', motivation, AppColors.primary),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // Background info
              _SectionCard(
                title: 'Training Background',
                icon: Icons.info_outline_rounded,
                iconColor: AppColors.secondary,
                child: Column(
                  children: [
                    _InfoRow('Family Support', familySupport),
                    if (pressureSources.isNotEmpty)
                      _InfoRow('Pressure Sources',
                          pressureSources.join(', ')),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              AppButton(
                label: 'Sign Out',
                variant: AppButtonVariant.danger,
                onPressed: () => _confirmLogout(context),
                icon: Icons.logout_rounded,
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }

  void _confirmLogout(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.card,
        title: const Text('Sign Out?'),
        content: const Text(
          'Your local data will be cleared. Are you sure?',
          style: AppTextStyles.bodyMedium,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.error),
            onPressed: () {
              Navigator.pop(ctx);
              context
                  .read<AuthBloc>()
                  .add(const AuthLogoutRequested());
            },
            child: const Text('Sign Out'),
          ),
        ],
      ),
    );
  }
}

class _SectionCard extends StatelessWidget {
  const _SectionCard({
    required this.title,
    required this.icon,
    required this.iconColor,
    required this.child,
  });

  final String title;
  final IconData icon;
  final Color iconColor;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: iconColor, size: 18),
              const SizedBox(width: 8),
              Text(title, style: AppTextStyles.headingSmall),
            ],
          ),
          const SizedBox(height: 16),
          child,
        ],
      ),
    );
  }
}

class _ScoreCol extends StatelessWidget {
  const _ScoreCol(this.label, this.score, this.color);

  final String label;
  final double score;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        ScoreRing(score: score, size: 52, strokeWidth: 4, color: color),
        const SizedBox(height: 4),
        Text(label,
            style: AppTextStyles.caption,
            textAlign: TextAlign.center),
      ],
    );
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow(this.label, this.value);

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(label, style: AppTextStyles.bodySmall),
          ),
          Expanded(
            child: Text(
              value,
              style: AppTextStyles.bodySmall
                  .copyWith(color: AppColors.textPrimary),
            ),
          ),
        ],
      ),
    );
  }
}
