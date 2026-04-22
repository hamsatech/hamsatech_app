import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_text_styles.dart';
import '../../../../core/di/injection.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/app_text_field.dart';
import '../../domain/entities/session_entity.dart';
import '../bloc/session_bloc.dart';
import '../bloc/session_event.dart';
import '../bloc/session_state.dart';

class PostSessionScreen extends StatelessWidget {
  const PostSessionScreen({
    super.key,
    required this.sessionId,
    required this.durationMinutes,
  });

  final String sessionId;
  final int durationMinutes;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => getIt<SessionBloc>(),
      child: _PostSessionView(
        sessionId: sessionId,
        durationMinutes: durationMinutes,
      ),
    );
  }
}

class _PostSessionView extends StatefulWidget {
  const _PostSessionView({
    required this.sessionId,
    required this.durationMinutes,
  });

  final String sessionId;
  final int durationMinutes;

  @override
  State<_PostSessionView> createState() => _PostSessionViewState();
}

class _PostSessionViewState extends State<_PostSessionView> {
  int _rating = 3;
  final _wentWellController = TextEditingController();
  final _wentWrongController = TextEditingController();
  final _mentalNotesController = TextEditingController();

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    _wentWellController.dispose();
    _wentWrongController.dispose();
    _mentalNotesController.dispose();
    super.dispose();
  }

  void _save(BuildContext context) {
    context.read<SessionBloc>().add(
          SessionCompleteRequested(
            sessionId: widget.sessionId,
            durationMinutes: widget.durationMinutes,
            postSession: PostSessionData(
              overallRating: _rating,
              wentWell: _wentWellController.text.trim(),
              wentWrong: _wentWrongController.text.trim(),
              mentalNotes: _mentalNotesController.text.trim(),
            ),
          ),
        );
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<SessionBloc, SessionState>(
      listener: (context, state) {
        if (state is SessionCompleted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Session saved! Great work.'),
              backgroundColor: AppColors.secondary,
            ),
          );
          context.go('/home');
        } else if (state is SessionError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
                content: Text(state.message),
                backgroundColor: AppColors.error),
          );
        }
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Post-Session Reflection'),
          automaticallyImplyLeading: false,
        ),
        body: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Session complete!', style: AppTextStyles.displayMedium),
                const SizedBox(height: 8),
                Text(
                  'Take 2 minutes to reflect. This is where growth happens.',
                  style: AppTextStyles.bodyMedium
                      .copyWith(color: AppColors.textSecondary),
                ),
                const SizedBox(height: 32),
                Text('Overall session quality',
                    style: AppTextStyles.headingSmall),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(5, (i) {
                    final star = i + 1;
                    return GestureDetector(
                      onTap: () => setState(() => _rating = star),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 6),
                        child: Icon(
                          star <= _rating ? Icons.star_rounded : Icons.star_border_rounded,
                          color: AppColors.warning,
                          size: 40,
                        ),
                      ),
                    );
                  }),
                ),
                const SizedBox(height: 28),
                AppTextField(
                  controller: _wentWellController,
                  label: 'What went well?',
                  hint: 'e.g. My hold was steady, breathing was controlled...',
                  maxLines: 3,
                  prefixIcon: Icons.thumb_up_outlined,
                ),
                const SizedBox(height: 16),
                AppTextField(
                  controller: _wentWrongController,
                  label: 'What needs improvement?',
                  hint: 'e.g. I lost focus after shot 8, trigger pull was inconsistent...',
                  maxLines: 3,
                  prefixIcon: Icons.thumb_down_outlined,
                ),
                const SizedBox(height: 16),
                AppTextField(
                  controller: _mentalNotesController,
                  label: 'Mental state notes',
                  hint: 'e.g. Felt anxious about selection, distracted by external noise...',
                  maxLines: 3,
                  prefixIcon: Icons.psychology_outlined,
                ),
                const SizedBox(height: 36),
                BlocBuilder<SessionBloc, SessionState>(
                  builder: (context, state) => AppButton(
                    label: 'Save Reflection',
                    onPressed: () => _save(context),
                    isLoading: state is SessionLoading,
                    icon: Icons.save_rounded,
                  ),
                ),
                const SizedBox(height: 24),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
