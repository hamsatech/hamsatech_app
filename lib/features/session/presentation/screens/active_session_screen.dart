import 'dart:async';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_text_styles.dart';

class ActiveSessionScreen extends StatefulWidget {
  const ActiveSessionScreen({super.key, required this.sessionId});

  final String sessionId;

  @override
  State<ActiveSessionScreen> createState() => _ActiveSessionScreenState();
}

class _ActiveSessionScreenState extends State<ActiveSessionScreen> {
  late Stopwatch _stopwatch;
  Timer? _timer;
  final List<String> _notes = [];
  final _noteController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _stopwatch = Stopwatch()..start();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (mounted) setState(() {});
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _stopwatch.stop();
    _noteController.dispose();
    super.dispose();
  }

  String get _elapsed {
    final d = _stopwatch.elapsed;
    final h = d.inHours.toString().padLeft(2, '0');
    final m = d.inMinutes.remainder(60).toString().padLeft(2, '0');
    final s = d.inSeconds.remainder(60).toString().padLeft(2, '0');
    return d.inHours > 0 ? '$h:$m:$s' : '$m:$s';
  }

  void _addNote() {
    final note = _noteController.text.trim();
    if (note.isEmpty) return;
    setState(() => _notes.add(note));
    _noteController.clear();
  }

  void _endSession() {
    _stopwatch.stop();
    _timer?.cancel();
    final durationMinutes = _stopwatch.elapsed.inMinutes;
    context.pushReplacement(
      '/session/post',
      extra: {'sessionId': widget.sessionId, 'durationMinutes': durationMinutes},
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Active Session'),
        automaticallyImplyLeading: false,
        actions: [
          TextButton.icon(
            onPressed: _endSession,
            icon: const Icon(Icons.stop_circle_outlined,
                color: AppColors.error),
            label: const Text('End Session',
                style: TextStyle(color: AppColors.error)),
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 32),
              color: AppColors.surface,
              child: Column(
                children: [
                  Text(
                    _elapsed,
                    style: AppTextStyles.scoreDisplay.copyWith(
                      color: AppColors.primary,
                      fontSize: 56,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        width: 8,
                        height: 8,
                        decoration: const BoxDecoration(
                          color: AppColors.error,
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 6),
                      Text('Session in progress',
                          style: AppTextStyles.labelMedium
                              .copyWith(color: AppColors.textSecondary)),
                    ],
                  ),
                ],
              ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Session Notes', style: AppTextStyles.headingSmall),
                    const SizedBox(height: 4),
                    Text(
                      'Jot down observations, technical issues, or mental state changes',
                      style: AppTextStyles.bodySmall,
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: _noteController,
                            style: AppTextStyles.bodyMedium,
                            decoration: const InputDecoration(
                              hintText: 'Add a note...',
                              filled: true,
                              fillColor: AppColors.card,
                            ),
                            onSubmitted: (_) => _addNote(),
                          ),
                        ),
                        const SizedBox(width: 8),
                        IconButton.filled(
                          onPressed: _addNote,
                          icon: const Icon(Icons.add_rounded),
                          style: IconButton.styleFrom(
                            backgroundColor: AppColors.primary,
                            foregroundColor: Colors.white,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Expanded(
                      child: _notes.isEmpty
                          ? Center(
                              child: Text(
                                'No notes yet. Use this space to capture\nwhat\'s happening during your session.',
                                style: AppTextStyles.bodySmall,
                                textAlign: TextAlign.center,
                              ),
                            )
                          : ListView.builder(
                              itemCount: _notes.length,
                              itemBuilder: (_, i) => Padding(
                                padding: const EdgeInsets.only(bottom: 8),
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Padding(
                                      padding: EdgeInsets.only(top: 4, right: 8),
                                      child: Icon(
                                        Icons.circle,
                                        size: 6,
                                        color: AppColors.primary,
                                      ),
                                    ),
                                    Expanded(
                                      child: Text(
                                        _notes[i],
                                        style: AppTextStyles.bodyMedium,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
