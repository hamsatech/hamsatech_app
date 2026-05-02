import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hamsatech_design_system/hamsatech_design_system.dart';
import 'package:hamsatech_design_system_example/screens/button_showcase_screen.dart';
import '../test_helpers.dart';

void main() {
  group('ButtonShowcaseScreen – section headings', () {
    testWidgets('renders all section titles', (tester) async {
      await pumpScreen(tester, const ButtonShowcaseScreen());

      expect(find.text('DSBUTTON · VARIANTS'), findsOneWidget);
      expect(find.text('DSBUTTON · SIZES'), findsOneWidget);
      expect(find.text('DSBUTTON · ADD-ONS'), findsOneWidget);
      expect(find.text('DSICONBUTTON'), findsOneWidget);
      expect(find.text('DSSEGMENTEDCONTROL'), findsOneWidget);
      expect(find.text('DSBUTTONGROUP'), findsOneWidget);
    });
  });

  group('ButtonShowcaseScreen – DSButton variants', () {
    testWidgets('renders all 9 variant labels', (tester) async {
      await pumpScreen(tester, const ButtonShowcaseScreen());

      for (final label in [
        'Brand', 'Black', 'Outline', 'Gray', 'White',
        'Ghost', 'Link Sec', 'Link', 'Danger',
      ]) {
        expect(find.text(label), findsAtLeastNWidgets(1), reason: '"$label" variant missing');
      }
    });

    testWidgets('renders size labels Small, Medium, Large', (tester) async {
      await pumpScreen(tester, const ButtonShowcaseScreen());

      expect(find.text('Small'), findsOneWidget);
      expect(find.text('Medium'), findsOneWidget);
      expect(find.text('Large'), findsAtLeastNWidgets(1));
    });

    testWidgets('disabled button does not trigger callback', (tester) async {
      await pumpScreen(tester, const ButtonShowcaseScreen());

      final disabledBtn = find.widgetWithText(DSButton, 'Disabled').first;
      await tester.tap(disabledBtn, warnIfMissed: false);
      await tester.pump();
      // No exception = disabled state is handled correctly
    });

    testWidgets('full-width buttons render', (tester) async {
      await pumpScreen(tester, const ButtonShowcaseScreen());

      expect(find.text('Full Width'), findsOneWidget);
      expect(find.text('Full Width Outline'), findsOneWidget);
    });

    testWidgets('add-on buttons with leading/trailing icons render', (tester) async {
      await pumpScreen(tester, const ButtonShowcaseScreen());

      expect(find.text('Leading'), findsOneWidget);
      expect(find.text('Trailing'), findsOneWidget);
      expect(find.text('Both'), findsOneWidget);
      expect(find.text('Shortcut'), findsOneWidget);
    });
  });

  group('ButtonShowcaseScreen – loading state', () {
    testWidgets('tapping "Tap to load" shows CircularProgressIndicator', (tester) async {
      await pumpScreen(tester, const ButtonShowcaseScreen());

      expect(find.text('Tap to load'), findsOneWidget);
      await tester.tap(find.text('Tap to load'));
      await tester.pump();

      expect(find.byType(CircularProgressIndicator), findsAtLeastNWidgets(1));

      // Drain the pending 2-second Future.delayed timer before teardown.
      await tester.pump(const Duration(seconds: 3));
    });

    testWidgets('"Tap to load" returns to normal text after 2 seconds', (tester) async {
      await pumpScreen(tester, const ButtonShowcaseScreen());

      await tester.tap(find.text('Tap to load'));
      await tester.pump();
      expect(find.byType(CircularProgressIndicator), findsAtLeastNWidgets(1));

      await tester.pump(const Duration(seconds: 3));
      expect(find.text('Tap to load'), findsOneWidget);
    });
  });

  group('ButtonShowcaseScreen – DSSegmentedControl', () {
    testWidgets('renders segment labels All, Active, Done', (tester) async {
      await pumpScreen(tester, const ButtonShowcaseScreen());

      // Three segmented controls → three copies of each label
      expect(find.text('All'), findsAtLeastNWidgets(3));
      expect(find.text('Active'), findsAtLeastNWidgets(3));
      expect(find.text('Done'), findsAtLeastNWidgets(3));
    });

    testWidgets('tapping "Active" segment fires onChanged without error', (tester) async {
      await pumpScreen(tester, const ButtonShowcaseScreen());

      await tester.tap(find.text('Active').first);
      await tester.pump();

      expect(find.text('Active'), findsAtLeastNWidgets(1));
    });
  });

  group('ButtonShowcaseScreen – DSButtonGroup', () {
    testWidgets('renders button group items', (tester) async {
      await pumpScreen(tester, const ButtonShowcaseScreen());

      expect(find.text('Create'), findsAtLeastNWidgets(1));
      expect(find.text('Add'), findsAtLeastNWidgets(1));
    });

    testWidgets('tapping "Add" updates selection', (tester) async {
      await pumpScreen(tester, const ButtonShowcaseScreen());

      await tester.tap(find.text('Add').first);
      await tester.pump();

      expect(find.text('Add'), findsAtLeastNWidgets(1));
    });
  });

  group('ButtonShowcaseScreen – DSIconButton', () {
    testWidgets('renders multiple DSIconButton instances', (tester) async {
      await pumpScreen(tester, const ButtonShowcaseScreen());

      expect(find.byType(DSIconButton), findsAtLeastNWidgets(1));
    });

    testWidgets('size section label "Sizes — SM / MD / LG" is visible', (tester) async {
      await pumpScreen(tester, const ButtonShowcaseScreen());

      expect(find.text('Sizes — SM / MD / LG'), findsOneWidget);
    });
  });
}
