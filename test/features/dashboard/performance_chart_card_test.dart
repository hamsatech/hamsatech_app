import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hamsatech/features/dashboard/domain/entities/dashboard_data_entity.dart';
import 'package:hamsatech/features/dashboard/presentation/widgets/performance_chart_card.dart';

void main() {
  testWidgets(
      'a brand-new athlete with no session history sees an honest empty '
      'state, never a manufactured chart', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(body: PerformanceChartCard(history: [])),
      ),
    );

    expect(find.text('Complete sessions to see your trend'), findsOneWidget);
    expect(find.byType(SizedBox).evaluate().any((e) {
      final box = e.widget as SizedBox;
      return box.height == 160; // the chart's own SizedBox height
    }), isFalse);
  });

  testWidgets(
      'sessions exist but none has a saved score yet — still an honest '
      'empty state, not a chart with fabricated points', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: PerformanceChartCard(history: [
            PerformanceDataPoint(
                date: DateTime(2026, 1, 1), sessionNumber: 1, avgScore: null),
          ]),
        ),
      ),
    );

    expect(
      find.textContaining('No scored sessions yet'),
      findsOneWidget,
    );
  });

  testWidgets('real scored sessions render the chart, not the empty state',
      (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: PerformanceChartCard(history: [
            PerformanceDataPoint(
                date: DateTime(2026, 1, 1), sessionNumber: 1, avgScore: 88.0),
            PerformanceDataPoint(
                date: DateTime(2026, 1, 3), sessionNumber: 2, avgScore: 92.5),
          ]),
        ),
      ),
    );

    expect(find.text('Complete sessions to see your trend'), findsNothing);
    expect(find.textContaining('No scored sessions yet'), findsNothing);
  });
}
