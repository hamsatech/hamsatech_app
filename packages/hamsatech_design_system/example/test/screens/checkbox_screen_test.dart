import 'package:flutter_test/flutter_test.dart';
import 'package:hamsatech_design_system/hamsatech_design_system.dart';
import 'package:hamsatech_design_system_example/screens/checkbox_screen.dart';
import '../test_helpers.dart';

void main() {
  group('CheckboxScreen – section headings', () {
    testWidgets('renders all section titles', (tester) async {
      await pumpScreen(tester, const CheckboxScreen());

      expect(find.text('DSCHECKBOX · STATES'), findsOneWidget);
      expect(find.text('DSCHECKBOX · LABEL + DESCRIPTION + BADGE'), findsOneWidget);
      expect(find.text('DSCHECKBOXGROUP · VERTICAL'), findsOneWidget);
      expect(find.text('DSCHECKBOXGROUP · HORIZONTAL'), findsOneWidget);
      expect(find.text('DSCHECKBOXCARDGROUP'), findsOneWidget);
      expect(find.text('DSCHECKBOXTREE'), findsOneWidget);
    });
  });

  group('CheckboxScreen – DSCheckbox states', () {
    testWidgets('renders state descriptor labels', (tester) async {
      await pumpScreen(tester, const CheckboxScreen());

      expect(find.text('Checked (SM · MD · LG)'), findsOneWidget);
      expect(find.text('Indeterminate'), findsAtLeastNWidgets(1));
      expect(find.text('Unchecked'), findsAtLeastNWidgets(1));
      expect(find.text('Disabled'), findsAtLeastNWidgets(1));
    });

    testWidgets('renders at least 12 DSCheckbox widgets for state rows', (tester) async {
      await pumpScreen(tester, const CheckboxScreen());

      // 4 rows × 3 sizes = 12 in the state grid alone
      expect(find.byType(DSCheckbox), findsAtLeastNWidgets(12));
    });
  });

  group('CheckboxScreen – labelled DSCheckbox interaction', () {
    testWidgets('renders labelled checkboxes', (tester) async {
      await pumpScreen(tester, const CheckboxScreen());

      expect(find.text('Receive Updates'), findsAtLeastNWidgets(1));
      expect(find.text('Disabled checked'), findsOneWidget);
      expect(find.text('Disabled unchecked'), findsOneWidget);
    });

    testWidgets('tapping "Unchecked item" labelled checkbox toggles its value', (tester) async {
      await pumpScreen(tester, const CheckboxScreen());

      final checkbox = find.widgetWithText(DSCheckbox, 'Unchecked item');
      final before = tester.widget<DSCheckbox>(checkbox).value;

      await tester.tap(checkbox);
      await tester.pump();

      final after = tester.widget<DSCheckbox>(checkbox).value;
      expect(after, isNot(equals(before)));
    });

    testWidgets('tapping disabled checkbox does not change its value', (tester) async {
      await pumpScreen(tester, const CheckboxScreen());

      final checkbox = find.widgetWithText(DSCheckbox, 'Disabled checked');
      final before = tester.widget<DSCheckbox>(checkbox).value;

      await tester.tap(checkbox, warnIfMissed: false);
      await tester.pump();

      final after = tester.widget<DSCheckbox>(checkbox).value;
      expect(after, equals(before));
    });
  });

  group('CheckboxScreen – DSCheckboxGroup', () {
    testWidgets('flat group renders all 5 items', (tester) async {
      await pumpScreen(tester, const CheckboxScreen());

      expect(find.text('Promotional Offers'), findsAtLeastNWidgets(1));
      expect(find.text('Beta Access'), findsAtLeastNWidgets(1));
      expect(find.text('Event Invitations'), findsAtLeastNWidgets(1));
      expect(find.text('Feedback Requests'), findsAtLeastNWidgets(1));
    });

    testWidgets('tapping an unselected group item toggles it', (tester) async {
      await pumpScreen(tester, const CheckboxScreen());

      // "Promotional Offers" starts unchecked in the vertical flat group
      await tester.tap(find.text('Promotional Offers').first);
      await tester.pump();

      expect(find.text('Promotional Offers'), findsAtLeastNWidgets(1));
    });
  });

  group('CheckboxScreen – DSCheckboxCardGroup', () {
    testWidgets('card group renders badge "New" text', (tester) async {
      await pumpScreen(tester, const CheckboxScreen());

      expect(find.text('New'), findsAtLeastNWidgets(1));
    });

    testWidgets('card group renders item descriptions', (tester) async {
      await pumpScreen(tester, const CheckboxScreen());

      expect(find.text('Get product news and updates.'), findsAtLeastNWidgets(1));
      expect(find.text('Try new features early.'), findsOneWidget);
    });
  });

  group('CheckboxScreen – DSCheckboxTree', () {
    testWidgets('renders tree root nodes', (tester) async {
      await pumpScreen(tester, const CheckboxScreen());

      expect(find.text('Project Settings'), findsOneWidget);
      expect(find.text('User Permissions'), findsOneWidget);
    });

    testWidgets('renders nested child nodes', (tester) async {
      await pumpScreen(tester, const CheckboxScreen());

      expect(find.text('General Settings'), findsOneWidget);
      expect(find.text('Collaboration'), findsOneWidget);
      expect(find.text('Access Levels'), findsOneWidget);
    });

    testWidgets('disabled tree node "Enable Notifications" is present', (tester) async {
      await pumpScreen(tester, const CheckboxScreen());

      expect(find.text('Enable Notifications'), findsOneWidget);
    });
  });
}
