import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hamsatech/features/dashboard/presentation/widgets/weekly_stats_card.dart';

void main() {
  testWidgets('renders the real session count and rounded average score',
      (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: WeeklyStatsCard(sessionCount: 3, averageScore: 92.5),
        ),
      ),
    );

    expect(find.text('3'), findsOneWidget);
    expect(find.text('93'), findsOneWidget); // 92.5 rounds to 93
    expect(find.text('Sessions this week'), findsOneWidget);
    expect(find.text('Average score'), findsOneWidget);
  });

  testWidgets(
      'a new athlete with 0 sessions this week shows "—" for average score, '
      'never a fabricated number', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: WeeklyStatsCard(sessionCount: 0, averageScore: null),
        ),
      ),
    );

    expect(find.text('0'), findsOneWidget);
    expect(find.text('—'), findsOneWidget);
    expect(find.text('60'), findsNothing);
  });
}
