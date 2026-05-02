import 'package:flutter_test/flutter_test.dart';
import 'package:hamsatech_design_system_example/screens/typography_screen.dart';
import '../test_helpers.dart';

void main() {
  group('TypographyScreen – section rendering', () {
    testWidgets('renders all six section headings', (tester) async {
      await pumpScreen(tester, const TypographyScreen());

      for (final heading in ['DISPLAY', 'HEADING', 'BODY', 'LABEL', 'APP-SPECIFIC', 'MONO']) {
        expect(find.text(heading), findsOneWidget, reason: '"$heading" section missing');
      }
    });

    testWidgets('renders section descriptions', (tester) async {
      await pumpScreen(tester, const TypographyScreen());

      expect(find.text('Hero text, splash screens'), findsOneWidget);
      expect(find.text('Screen titles, card headers'), findsOneWidget);
      expect(find.text('Paragraphs, descriptions'), findsOneWidget);
      expect(find.text('Buttons, tags, badges'), findsOneWidget);
    });
  });

  group('TypographyScreen – token rows', () {
    testWidgets('renders display token names', (tester) async {
      await pumpScreen(tester, const TypographyScreen());

      expect(find.text('displayLg'), findsOneWidget);
      expect(find.text('displayMd'), findsOneWidget);
      expect(find.text('displaySm'), findsOneWidget);
    });

    testWidgets('renders heading token names', (tester) async {
      await pumpScreen(tester, const TypographyScreen());

      expect(find.text('headingXl'), findsOneWidget);
      expect(find.text('headingLg'), findsOneWidget);
      expect(find.text('headingMd'), findsOneWidget);
      expect(find.text('headingSm'), findsOneWidget);
      expect(find.text('headingXs'), findsOneWidget);
    });

    testWidgets('renders label token names', (tester) async {
      await pumpScreen(tester, const TypographyScreen());

      expect(find.text('labelLg'), findsOneWidget);
      expect(find.text('labelMd'), findsOneWidget);
      expect(find.text('labelSm'), findsOneWidget);
      expect(find.text('labelXs'), findsOneWidget);
    });

    testWidgets('renders mono token row', (tester) async {
      await pumpScreen(tester, const TypographyScreen());

      expect(find.text('mono'), findsOneWidget);
    });

    testWidgets('renders app-specific tokens scoreDisplay and metricValue', (tester) async {
      await pumpScreen(tester, const TypographyScreen());

      expect(find.text('scoreDisplay'), findsOneWidget);
      expect(find.text('metricValue'), findsOneWidget);
      expect(find.text('caption'), findsOneWidget);
    });

    testWidgets('sample text "The quick brown fox" appears for every token row', (tester) async {
      await pumpScreen(tester, const TypographyScreen());

      // display(3) + heading(5) + body(4) + label(4) + app-specific(13) + mono(1) = 30 rows
      final matches = tester.widgetList(find.text('The quick brown fox'));
      expect(matches.length, greaterThanOrEqualTo(20));
    });

    testWidgets('meta size info is shown for display tokens', (tester) async {
      await pumpScreen(tester, const TypographyScreen());

      expect(find.text('48 · w700 · -0.5'), findsOneWidget);
      expect(find.text('36 · w700 · -0.3'), findsOneWidget);
    });
  });
}
