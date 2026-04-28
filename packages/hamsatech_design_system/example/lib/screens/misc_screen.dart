import 'package:flutter/material.dart';
import 'package:hamsatech_design_system/hamsatech_design_system.dart';
import '../widgets/showcase_helpers.dart';

class MiscScreen extends StatelessWidget {
  const MiscScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ShowcaseScaffold(
      title: 'Misc Components',
      sections: [
        ShowcaseSection(
          title: 'DSSCORERING',
          description: 'Animated arc ring for displaying a score or percentage (0–100)',
          children: [
            ShowcaseCard(
              code: "DSScoreRing(score: 87, label: 'Overall', size: 120)",
              child: Wrap(
                spacing: 24,
                runSpacing: 24,
                alignment: WrapAlignment.center,
                children: [
                  DSScoreRing(score: 95, label: 'Focus', size: 100, color: DSColors.brand),
                  DSScoreRing(score: 78, label: 'Mental', size: 100, color: DSColors.info),
                  DSScoreRing(score: 62, label: 'Stress', size: 100, color: DSColors.warning),
                  DSScoreRing(score: 88, label: 'Confidence', size: 100, color: DSColors.success),
                  DSScoreRing(score: 45, label: 'Recovery', size: 100, color: DSColors.error),
                ],
              ),
            ),
            ShowcaseCard(
              label: 'Sizes',
              code: "DSScoreRing(score: 80, size: 80)\nDSScoreRing(score: 80, size: 120)\nDSScoreRing(score: 80, size: 160)",
              child: Wrap(
                spacing: 24,
                runSpacing: 24,
                crossAxisAlignment: WrapCrossAlignment.center,
                children: [
                  DSScoreRing(score: 80, label: 'SM', size: 72),
                  DSScoreRing(score: 80, label: 'MD', size: 100),
                  DSScoreRing(score: 80, label: 'LG', size: 132),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }
}
