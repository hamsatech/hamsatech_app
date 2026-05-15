import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hamsatech_design_system/hamsatech_design_system.dart';

import '../../bloc/score_entry_bloc.dart';
import '../../bloc/score_entry_event.dart';
import '../../domain/entities/session_series_entity.dart';
import 'score_button.dart';

class ScoreGrid extends StatelessWidget {
  const ScoreGrid({super.key});

  static const _rows = [
    [0, 1, 2, 3],
    [4, 5, 6, 7],
  ];

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: _rows.map((row) {
        return Padding(
          padding: const EdgeInsets.only(bottom: DSSpacing.sm),
          child: IntrinsicHeight(
            child: Row(
              children: row.map((i) {
                return Expanded(
                  child: Padding(
                    padding: EdgeInsets.only(
                      right: i == row.last ? 0 : DSSpacing.sm,
                    ),
                    child: SizedBox(
                      height: 52,
                      child: ScoreButton(
                        value: ScoreValue.all[i],
                        onTap: () => context
                            .read<ScoreEntryBloc>()
                            .add(ScoreScoreSelected(ScoreValue.all[i])),
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
        );
      }).toList(),
    );
  }
}
