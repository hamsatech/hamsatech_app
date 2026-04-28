import 'package:flutter/material.dart';
import 'package:hamsatech_design_system/hamsatech_design_system.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';


import '../../../../core/di/injection.dart';
import '../../domain/entities/journal_entry_entity.dart';
import '../bloc/reflection_bloc.dart';
import '../bloc/reflection_event.dart';
import '../bloc/reflection_state.dart';

class ReflectionScreen extends StatelessWidget {
  const ReflectionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) =>
          getIt<ReflectionBloc>()..add(const ReflectionLoadRequested()),
      child: const _ReflectionView(),
    );
  }
}

class _ReflectionView extends StatelessWidget {
  const _ReflectionView();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Ask Me Journal')),
      body: BlocBuilder<ReflectionBloc, ReflectionState>(
        builder: (context, state) {
          if (state is ReflectionLoaded && state.entries.isEmpty) {
            return Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.auto_stories_rounded,
                      size: 64, color: DSColors.textMuted),
                  const SizedBox(height: 16),
                  Text('Your journal is empty',
                      style: DSTypography.headingMedium),
                  const SizedBox(height: 8),
                  Text(
                    'Tap the button below to write your first entry.\nExpress anything — thoughts, emotions, goals.',
                    style: DSTypography.bodySmall,
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            );
          }

          final entries = state is ReflectionLoaded ? state.entries : <JournalEntryEntity>[];

          return ListView.separated(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
            itemCount: entries.length,
            separatorBuilder: (_, __) => const SizedBox(height: 10),
            itemBuilder: (_, i) => _EntryCard(entry: entries[i]),
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showAddEntrySheet(context),
        backgroundColor: DSColors.brand,
        icon: const Icon(Icons.edit_rounded, color: Colors.white),
        label: const Text('Write Entry',
            style: TextStyle(color: Colors.white)),
      ),
    );
  }

  void _showAddEntrySheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: DSColors.appSurface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => BlocProvider.value(
        value: context.read<ReflectionBloc>(),
        child: const _AddEntrySheet(),
      ),
    );
  }
}

class _AddEntrySheet extends StatefulWidget {
  const _AddEntrySheet();

  @override
  State<_AddEntrySheet> createState() => _AddEntrySheetState();
}

class _AddEntrySheetState extends State<_AddEntrySheet> {
  final _controller = TextEditingController();
  String? _selectedEmotion;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _save(BuildContext context) {
    final content = _controller.text.trim();
    if (content.isEmpty) return;
    context.read<ReflectionBloc>().add(
          ReflectionAddEntryRequested(
            content: content,
            emotion: _selectedEmotion,
          ),
        );
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        left: 20,
        right: 20,
        top: 20,
        bottom: MediaQuery.of(context).viewInsets.bottom + 20,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: DSColors.appBorder,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 20),
          Text('How are you feeling?', style: DSTypography.headingMedium),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: kEmotions.map((e) {
              final (label, emoji) = e;
              final isSelected = _selectedEmotion == label;
              return GestureDetector(
                onTap: () => setState(() {
                  _selectedEmotion = isSelected ? null : label;
                }),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 150),
                  padding: const EdgeInsets.symmetric(
                      horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? DSColors.brand.withValues(alpha: 0.2)
                        : DSColors.appCard,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: isSelected
                          ? DSColors.brand
                          : DSColors.appBorder,
                    ),
                  ),
                  child: Text(
                    '$emoji $label',
                    style: DSTypography.labelMedium.copyWith(
                      color: isSelected
                          ? DSColors.brand
                          : DSColors.textSecondary,
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 20),
          TextField(
            controller: _controller,
            autofocus: true,
            maxLines: 5,
            style: DSTypography.bodyMedium,
            decoration: const InputDecoration(
              hintText:
                  'Write your thoughts, feelings, goals, or anything on your mind...',
              filled: true,
              fillColor: DSColors.appCard,
            ),
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: () => _save(context),
              icon: const Icon(Icons.save_rounded),
              label: const Text('Save Entry'),
            ),
          ),
        ],
      ),
    );
  }
}

class _EntryCard extends StatelessWidget {
  const _EntryCard({required this.entry});

  final JournalEntryEntity entry;

  @override
  Widget build(BuildContext context) {
    return Dismissible(
      key: Key(entry.id),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        decoration: BoxDecoration(
          color: DSColors.error.withValues(alpha: 0.15),
          borderRadius: BorderRadius.circular(14),
        ),
        child: const Icon(Icons.delete_outline_rounded, color: DSColors.error),
      ),
      onDismissed: (_) => context.read<ReflectionBloc>().add(
            ReflectionDeleteEntryRequested(entry.id),
          ),
      child: Container(
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
                Text(
                  DateFormat('EEE, d MMM · HH:mm').format(entry.timestamp),
                  style: DSTypography.caption,
                ),
                const Spacer(),
                if (entry.emotion != null)
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: DSColors.brand.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      entry.emotion!,
                      style: DSTypography.caption
                          .copyWith(color: DSColors.brand),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              entry.content,
              style: DSTypography.bodyMedium
                  .copyWith(color: DSColors.textSecondary),
            ),
          ],
        ),
      ),
    );
  }
}
