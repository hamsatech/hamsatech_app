import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:hamsatech_design_system/hamsatech_design_system.dart';

import '../../bloc/score_entry_bloc.dart';
import '../../bloc/score_entry_event.dart';
import '../../bloc/score_entry_state.dart';

class ScoreEntryScreen extends StatefulWidget {
  const ScoreEntryScreen({super.key});

  @override
  State<ScoreEntryScreen> createState() => _ScoreEntryScreenState();
}

class _ScoreEntryScreenState extends State<ScoreEntryScreen> {
  final _inputCtrl = TextEditingController();
  final _inputFocus = FocusNode();
  String? _inputError;
  int _prevSeriesNumber = 0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        context
            .read<ScoreEntryBloc>()
            .add(const ScoreEntryStartRequested());
        _inputFocus.requestFocus();
      }
    });
  }

  @override
  void dispose() {
    _inputCtrl.dispose();
    _inputFocus.dispose();
    super.dispose();
  }

  void _onSave(BuildContext ctx, ScoreEntryActiveState state) {
    final text = _inputCtrl.text.trim();
    final value = double.tryParse(text);
    if (value == null || text.isEmpty) {
      setState(() => _inputError = 'Enter a valid number');
      return;
    }
    if (value < 0) {
      setState(() => _inputError = 'Score cannot be negative');
      return;
    }
    if (value > state.maxSeriesScore) {
      setState(
          () => _inputError = 'Max is ${state.formattedMaxSeriesScore}');
      return;
    }
    setState(() => _inputError = null);
    ctx.read<ScoreEntryBloc>().add(SeriesTotalSubmitted(value));
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<ScoreEntryBloc, ScoreEntryState>(
      listener: (ctx, state) {
        if (state is ScoreEntrySavedState) {
          ctx.go('/session/reflection');
          return;
        }
        if (state is ScoreEntryActiveState) {
          // New series — clear input and re-focus
          if (state.currentSeriesNumber != _prevSeriesNumber) {
            _prevSeriesNumber = state.currentSeriesNumber;
            _inputCtrl.clear();
            setState(() => _inputError = null);
            Future.microtask(() {
              if (mounted && !state.isComplete) {
                _inputFocus.requestFocus();
              }
            });
          }
        }
      },
      builder: (ctx, state) {
        if (state is! ScoreEntryActiveState) {
          return const Scaffold(
            backgroundColor: DSColors.appBackground,
            body: Center(child: CircularProgressIndicator()),
          );
        }
        return _buildScaffold(ctx, state);
      },
    );
  }

  Widget _buildScaffold(BuildContext ctx, ScoreEntryActiveState state) {
    return Scaffold(
      backgroundColor: DSColors.appBackground,
      appBar: AppBar(
        backgroundColor: DSColors.appBackground,
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: DSColors.black),
          onPressed: () => ctx.go('/home'),
        ),
        title: Text(
          state.sessionTitle,
          style: DSTypography.headingSmall.copyWith(color: DSColors.black),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: DSSpacing.xl),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: DSSpacing.xl),
              _buildHeading(state),
              const SizedBox(height: DSSpacing.xl),
              if (!state.isComplete)
                _buildInputCard(ctx, state)
              else
                _buildContinueButton(ctx),
              const SizedBox(height: DSSpacing.xl),
              Text(
                'So far in session',
                style: DSTypography.labelMd
                    .copyWith(color: DSColors.textSecondary),
              ),
              const SizedBox(height: DSSpacing.sm),
              _buildSeriesList(state),
              const SizedBox(height: DSSpacing.lg),
              _buildRunningTotalCard(state),
              const SizedBox(height: DSSpacing.xl),
              if (state.canUndo)
                Center(
                  child: GestureDetector(
                    onTap: () => ctx
                        .read<ScoreEntryBloc>()
                        .add(const ScoreEntryUndoLast()),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(
                          Icons.undo_rounded,
                          size: 16,
                          color: DSColors.brand,
                        ),
                        const SizedBox(width: 5),
                        Text(
                          'Undo last entry',
                          style: DSTypography.labelSm
                              .copyWith(color: DSColors.brand),
                        ),
                      ],
                    ),
                  ),
                ),
              const SizedBox(height: DSSpacing.xxl),
            ],
          ),
        ),
      ),
    );
  }

  // ── Heading ─────────────────────────────────────────────────────────────────

  Widget _buildHeading(ScoreEntryActiveState state) {
    if (state.isComplete) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'All series entered',
            style: DSTypography.headingXl.copyWith(color: DSColors.black),
          ),
          const SizedBox(height: 4),
          Text(
            'Review your scores and continue.',
            style: DSTypography.bodySm
                .copyWith(color: DSColors.textSecondary),
          ),
        ],
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Enter your series total score',
          style: DSTypography.headingXl.copyWith(color: DSColors.black),
        ),
        const SizedBox(height: 4),
        Text(
          'Enter the total score for this series.',
          style: DSTypography.bodySm
              .copyWith(color: DSColors.textSecondary),
        ),
        const SizedBox(height: DSSpacing.sm),
        Text.rich(
          TextSpan(
            text: 'Series ',
            style:
                DSTypography.headingMd.copyWith(color: DSColors.black),
            children: [
              TextSpan(
                text: '${state.currentSeriesNumber}',
                style: DSTypography.headingMd
                    .copyWith(color: DSColors.brand),
              ),
              TextSpan(
                text: ' of ${state.totalSeries}',
                style: DSTypography.headingMd
                    .copyWith(color: DSColors.black),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // ── Input card ──────────────────────────────────────────────────────────────

  Widget _buildInputCard(BuildContext ctx, ScoreEntryActiveState state) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(DSSpacing.xl),
      decoration: BoxDecoration(
        color: DSColors.appCard,
        borderRadius: BorderRadius.circular(20),
        border:
            Border.all(color: DSColors.appBorder.withValues(alpha: 0.5)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 12,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Series identity row
          Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: const BoxDecoration(
                  color: DSColors.brandMuted,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.gps_fixed_rounded,
                  color: DSColors.brand,
                  size: 22,
                ),
              ),
              const SizedBox(width: DSSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Series ${state.currentSeriesNumber}',
                      style: DSTypography.headingMd
                          .copyWith(color: DSColors.black),
                    ),
                    Text(
                      '${state.shotsPerSeries} shots',
                      style: DSTypography.bodySm
                          .copyWith(color: DSColors.textSecondary),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  color: DSColors.brandMuted,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  'Max score: ${state.formattedMaxSeriesScore}',
                  style: DSTypography.labelXs
                      .copyWith(color: DSColors.brand),
                ),
              ),
            ],
          ),
          const SizedBox(height: DSSpacing.xl),
          // Input label
          Text(
            'Enter total score (out of ${state.formattedMaxSeriesScore})',
            style: DSTypography.bodyMd
                .copyWith(color: DSColors.textSecondary),
          ),
          const SizedBox(height: DSSpacing.sm),
          // Score input field
          TextField(
            controller: _inputCtrl,
            focusNode: _inputFocus,
            keyboardType: const TextInputType.numberWithOptions(
                decimal: true),
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontFamily: 'Inter',
              fontSize: 36,
              fontWeight: FontWeight.w700,
              color: Color(0xFF000F12),
              height: 1.1,
            ),
            decoration: InputDecoration(
              hintText: '0',
              hintStyle: const TextStyle(
                fontFamily: 'Inter',
                fontSize: 36,
                fontWeight: FontWeight.w700,
                color: Color(0x4D000F12),
              ),
              errorText: _inputError,
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide:
                    BorderSide(color: DSColors.appBorder, width: 1.5),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(
                    color: DSColors.brand, width: 2),
              ),
              errorBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(
                    color: DSColors.error, width: 1.5),
              ),
              focusedErrorBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(
                    color: DSColors.error, width: 2),
              ),
              contentPadding: const EdgeInsets.symmetric(
                  vertical: 18, horizontal: 16),
            ),
            onSubmitted: (_) => _onSave(ctx, state),
          ),
          const SizedBox(height: DSSpacing.lg),
          // Save Score button
          SizedBox(
            width: double.infinity,
            height: 54,
            child: ElevatedButton(
              onPressed: () => _onSave(ctx, state),
              style: ElevatedButton.styleFrom(
                backgroundColor: DSColors.brand,
                foregroundColor: Colors.white,
                elevation: 0,
                shadowColor: Colors.transparent,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Save Score',
                    style: DSTypography.labelLg.copyWith(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(width: DSSpacing.sm),
                  Container(
                    width: 28,
                    height: 28,
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.20),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.check_rounded,
                      color: Colors.white,
                      size: 16,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ── Continue button (shown when all series are done) ─────────────────────────

  Widget _buildContinueButton(BuildContext ctx) {
    return DSPrimaryButton(
      label: 'Continue to Summary  ✓',
      color: DSColors.brand,
      onPressed: () => ctx
          .read<ScoreEntryBloc>()
          .add(const ScoreEntryFinalConfirmed()),
    );
  }

  // ── Series list ─────────────────────────────────────────────────────────────

  Widget _buildSeriesList(ScoreEntryActiveState state) {
    return Container(
      decoration: BoxDecoration(
        color: DSColors.appCard,
        borderRadius: BorderRadius.circular(16),
        border:
            Border.all(color: DSColors.appBorder.withValues(alpha: 0.5)),
      ),
      child: Column(
        children: List.generate(state.totalSeries, (i) {
          final seriesNum = i + 1;
          final isCompleted = i < state.enteredTotals.length;
          return _SeriesListItem(
            number: seriesNum,
            shotsPerSeries: state.shotsPerSeries,
            formattedTotal:
                isCompleted ? state.formattedEnteredTotal(i) : null,
            isLast: i == state.totalSeries - 1,
          );
        }),
      ),
    );
  }

  // ── Running total card ──────────────────────────────────────────────────────

  Widget _buildRunningTotalCard(ScoreEntryActiveState state) {
    final completedCount = state.enteredTotals.length;
    return Container(
      padding: const EdgeInsets.all(DSSpacing.lg),
      decoration: BoxDecoration(
        color: DSColors.appCard,
        borderRadius: BorderRadius.circular(16),
        border:
            Border.all(color: DSColors.appBorder.withValues(alpha: 0.5)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: const BoxDecoration(
              color: DSColors.gray100,
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.trending_up_rounded,
              color: DSColors.brand,
              size: 22,
            ),
          ),
          const SizedBox(width: DSSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Running total',
                  style: DSTypography.headingSm
                      .copyWith(color: DSColors.black),
                ),
                Text(
                  'After $completedCount of ${state.totalSeries} series',
                  style: DSTypography.bodySm
                      .copyWith(color: DSColors.textSecondary),
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                completedCount > 0 ? state.formattedRunningTotal : '—',
                style: DSTypography.headingLg
                    .copyWith(color: DSColors.brand),
              ),
              Text(
                '/ ${state.formattedMaxTotalScore}',
                style: DSTypography.bodySm
                    .copyWith(color: DSColors.textMuted),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ── Series list item ──────────────────────────────────────────────────────────

class _SeriesListItem extends StatelessWidget {
  const _SeriesListItem({
    required this.number,
    required this.shotsPerSeries,
    required this.formattedTotal,
    required this.isLast,
  });

  final int number;
  final int shotsPerSeries;
  final String? formattedTotal;
  final bool isLast;

  bool get _isCompleted => formattedTotal != null;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
          horizontal: DSSpacing.lg, vertical: 14),
      decoration: BoxDecoration(
        border: isLast
            ? null
            : const Border(
                bottom: BorderSide(
                    color: DSColors.appBorder, width: 0.5),
              ),
      ),
      child: Row(
        children: [
          // Number badge
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: _isCompleted ? DSColors.brand : DSColors.gray100,
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                '$number',
                style: DSTypography.labelXs.copyWith(
                  color: _isCompleted
                      ? Colors.white
                      : DSColors.textSecondary,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ),
          const SizedBox(width: DSSpacing.md),
          // Series label
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Series $number',
                  style: DSTypography.bodyMd.copyWith(
                    color: _isCompleted
                        ? DSColors.black
                        : DSColors.textSecondary,
                    fontWeight: _isCompleted
                        ? FontWeight.w600
                        : FontWeight.w400,
                  ),
                ),
                Text(
                  '$shotsPerSeries shots',
                  style: DSTypography.bodyXs
                      .copyWith(color: DSColors.textMuted),
                ),
              ],
            ),
          ),
          // Score or dash pill
          if (_isCompleted)
            Text(
              formattedTotal!,
              style: DSTypography.headingMd
                  .copyWith(color: DSColors.brand),
            )
          else
            Container(
              padding: const EdgeInsets.symmetric(
                  horizontal: 12, vertical: 5),
              decoration: BoxDecoration(
                color: DSColors.gray100,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                '—',
                style: DSTypography.labelSm
                    .copyWith(color: DSColors.textMuted),
              ),
            ),
        ],
      ),
    );
  }
}
