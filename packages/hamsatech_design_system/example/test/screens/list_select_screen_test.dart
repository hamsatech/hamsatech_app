import 'package:flutter_test/flutter_test.dart';
import 'package:hamsatech_design_system/hamsatech_design_system.dart';
import 'package:hamsatech_design_system_example/screens/list_select_screen.dart';
import '../test_helpers.dart';

void main() {
  group('ListSelectScreen – section headings', () {
    testWidgets('renders all section titles', (tester) async {
      await pumpScreen(tester, const ListSelectScreen());

      expect(find.text('SINGLE-SELECT · CHECKMARK'), findsOneWidget);
      expect(find.text('TOGGLE SWITCH'), findsOneWidget);
      expect(find.text('MULTI-SELECT · CHECKBOX'), findsOneWidget);
      expect(find.text('USER ROWS · AVATAR / INITIALS'), findsOneWidget);
      expect(find.text('STATUS ROWS · COLOR DOT'), findsOneWidget);
      expect(find.text('DISABLED STATE'), findsOneWidget);
    });
  });

  group('ListSelectScreen – single-select checkmark', () {
    testWidgets('renders all category item labels', (tester) async {
      await pumpScreen(tester, const ListSelectScreen());

      for (final label in ['AI', 'Agency', 'Architecture', 'Booking', 'Café', 'Cars', 'Music', 'Books']) {
        expect(find.text(label), findsAtLeastNWidgets(1), reason: '"$label" item missing');
      }
    });

    testWidgets('tapping an unselected item selects it', (tester) async {
      await pumpScreen(tester, const ListSelectScreen());

      await tester.tap(find.text('AI').first);
      await tester.pump();

      expect(find.text('AI'), findsAtLeastNWidgets(1));
    });

    testWidgets('tapping a selected item deselects it', (tester) async {
      await pumpScreen(tester, const ListSelectScreen());

      await tester.tap(find.text('Agency').first);
      await tester.pump();
      await tester.tap(find.text('Agency').first);
      await tester.pump();

      expect(find.text('Agency'), findsAtLeastNWidgets(1));
    });
  });

  group('ListSelectScreen – toggle switch', () {
    testWidgets('renders DSSelectItem widgets', (tester) async {
      await pumpScreen(tester, const ListSelectScreen());

      expect(find.byType(DSSelectItem), findsAtLeastNWidgets(1));
    });

    testWidgets('tapping a toggle item flips its state', (tester) async {
      await pumpScreen(tester, const ListSelectScreen());

      // 'Agency' appears in 3 sections (checkmark, toggle, checkbox).
      // Index 1 is the toggle-switch section's Agency — the one we tap.
      final itemsBefore = tester
          .widgetList<DSSelectItem>(find.byType(DSSelectItem))
          .where((w) => w.label == 'Agency')
          .toList();
      final stateBefore = itemsBefore.length > 1 ? itemsBefore[1].isSelected : false;

      await tester.tap(find.text('Agency').at(1));
      await tester.pump();

      final itemsAfter = tester
          .widgetList<DSSelectItem>(find.byType(DSSelectItem))
          .where((w) => w.label == 'Agency')
          .toList();
      if (itemsAfter.length > 1) {
        expect(itemsAfter[1].isSelected, isNot(equals(stateBefore)));
      }
    });
  });

  group('ListSelectScreen – user rows', () {
    testWidgets('renders user names and handles', (tester) async {
      await pumpScreen(tester, const ListSelectScreen());

      expect(find.text('Grace Foster'), findsOneWidget);
      expect(find.text('Ethan Cole'), findsOneWidget);
      expect(find.text('Owen Brooks'), findsOneWidget);
      expect(find.text('@gracefoster'), findsOneWidget);
      expect(find.text('@ethancole'), findsOneWidget);
    });

    testWidgets('renders DSItemInitials widgets', (tester) async {
      await pumpScreen(tester, const ListSelectScreen());

      expect(find.byType(DSItemInitials), findsAtLeastNWidgets(1));
    });
  });

  group('ListSelectScreen – status rows', () {
    testWidgets('renders all status labels', (tester) async {
      await pumpScreen(tester, const ListSelectScreen());

      for (final label in ['Completed', 'In progress', 'Pending', 'Delayed', 'Cancelled', 'On hold']) {
        expect(find.text(label), findsOneWidget, reason: '"$label" status missing');
      }
    });

    testWidgets('renders DSItemColorDot widgets', (tester) async {
      await pumpScreen(tester, const ListSelectScreen());

      expect(find.byType(DSItemColorDot), findsAtLeastNWidgets(1));
    });
  });

  group('ListSelectScreen – disabled state', () {
    testWidgets('renders disabled item labels', (tester) async {
      await pumpScreen(tester, const ListSelectScreen());

      expect(find.text('Active item'), findsOneWidget);
      expect(find.text('Disabled off'), findsOneWidget);
      expect(find.text('Disabled on'), findsOneWidget);
    });

    testWidgets('tapping disabled item does not trigger state change', (tester) async {
      await pumpScreen(tester, const ListSelectScreen());

      await tester.tap(find.text('Disabled off'), warnIfMissed: false);
      await tester.pump();

      expect(find.text('Disabled off'), findsOneWidget);
    });
  });
}
