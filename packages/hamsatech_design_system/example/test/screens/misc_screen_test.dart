import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hamsatech_design_system/hamsatech_design_system.dart';
import 'package:hamsatech_design_system_example/screens/misc_screen.dart';
import '../test_helpers.dart';

void main() {
  group('MiscScreen – section headings', () {
    testWidgets('renders DSSCORERING section title', (tester) async {
      await pumpScreen(tester, const MiscScreen());

      expect(find.text('DSSCORERING'), findsOneWidget);
    });

    testWidgets('renders section description', (tester) async {
      await pumpScreen(tester, const MiscScreen());

      expect(
        find.text('Animated arc ring for displaying a score or percentage (0–100)'),
        findsOneWidget,
      );
    });
  });

  group('MiscScreen – DSScoreRing instances', () {
    testWidgets('renders all 8 DSScoreRing widgets', (tester) async {
      await pumpScreen(tester, const MiscScreen());
      await tester.pumpAndSettle();

      // 5 in the variants card + 3 in the sizes card
      expect(find.byType(DSScoreRing), findsAtLeastNWidgets(8));
    });

    testWidgets('renders ring labels for each sport metric', (tester) async {
      await pumpScreen(tester, const MiscScreen());
      await tester.pumpAndSettle();

      for (final label in ['Focus', 'Mental', 'Stress', 'Confidence', 'Recovery']) {
        expect(find.text(label), findsOneWidget, reason: '"$label" ring missing');
      }
    });

    testWidgets('renders size variant labels SM, MD, LG', (tester) async {
      await pumpScreen(tester, const MiscScreen());
      await tester.pumpAndSettle();

      expect(find.text('SM'), findsOneWidget);
      expect(find.text('MD'), findsOneWidget);
      expect(find.text('LG'), findsOneWidget);
    });

    testWidgets('"Sizes" card label is visible', (tester) async {
      await pumpScreen(tester, const MiscScreen());
      await tester.pumpAndSettle();

      expect(find.text('Sizes'), findsOneWidget);
    });
  });

  group('MiscScreen – DSScoreRing score values', () {
    testWidgets('variant rings carry correct scores', (tester) async {
      await pumpScreen(tester, const MiscScreen());
      await tester.pumpAndSettle();

      final rings = tester.widgetList<DSScoreRing>(find.byType(DSScoreRing)).toList();
      final scores = rings.map((r) => r.score).toList();

      expect(scores, containsAll([95, 78, 62, 88, 45]));
    });

    testWidgets('all three size-variant rings use score 80', (tester) async {
      await pumpScreen(tester, const MiscScreen());
      await tester.pumpAndSettle();

      final rings = tester.widgetList<DSScoreRing>(find.byType(DSScoreRing)).toList();
      final eighties = rings.where((r) => r.score == 80).toList();
      expect(eighties.length, equals(3));
    });
  });

  group('MiscScreen – dark theme', () {
    testWidgets('renders without error in dark theme', (tester) async {
      await pumpScreen(tester, const MiscScreen(), themeMode: ThemeMode.dark);
      await tester.pumpAndSettle();

      expect(find.byType(DSScoreRing), findsAtLeastNWidgets(8));
    });
  });
}
