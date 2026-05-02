import 'package:flutter_test/flutter_test.dart';
import 'package:hamsatech_design_system/hamsatech_design_system.dart';
import 'package:hamsatech_design_system_example/screens/inputs_screen.dart';
import '../test_helpers.dart';

void main() {
  group('InputsScreen – section headings', () {
    testWidgets('renders all section titles', (tester) async {
      await pumpScreen(tester, const InputsScreen());

      for (final title in [
        'DSTEXTINPUT · STATES',
        'DSSEARCHINPUT',
        'DSURLINPUT',
        'DSPHONEINPUT',
        'DSAMOUNTINPUT',
        'DSTAGSINPUT',
        'DSPASSWORDINPUT',
        'DSREFERRALINPUT',
        'DSDATEINPUT',
        'DSTEXTAREA',
        'DSINPUTGROUP',
        'DSCOMBOBOX',
        'DSMULTICOMBOBOX',
      ]) {
        expect(find.text(title), findsOneWidget, reason: '"$title" section missing');
      }
    });
  });

  group('InputsScreen – DSTextInput states', () {
    testWidgets('renders DSTextInput widgets', (tester) async {
      await pumpScreen(tester, const InputsScreen());

      expect(find.byType(DSTextInput), findsAtLeastNWidgets(1));
    });

    testWidgets('renders input state labels', (tester) async {
      await pumpScreen(tester, const InputsScreen());

      expect(find.text('Default'), findsAtLeastNWidgets(1));
      expect(find.text('Filled'), findsAtLeastNWidgets(1));
      expect(find.text('Error'), findsAtLeastNWidgets(1));
      expect(find.text('Disabled'), findsAtLeastNWidgets(1));
      expect(find.text('Loading'), findsAtLeastNWidgets(1));
    });

    testWidgets('error input renders its error message', (tester) async {
      await pumpScreen(tester, const InputsScreen());

      expect(find.text('This field contains invalid input'), findsOneWidget);
    });

    testWidgets('helper text is visible on default input', (tester) async {
      await pumpScreen(tester, const InputsScreen());

      expect(find.text('Helper text below the field'), findsOneWidget);
    });

    testWidgets('typing into default DSTextInput updates the value', (tester) async {
      await pumpScreen(tester, const InputsScreen());

      final defaultInput = find.byType(DSTextInput).first;
      await tester.tap(defaultInput);
      await tester.enterText(defaultInput, 'Hello world');
      await tester.pump();

      expect(find.text('Hello world'), findsOneWidget);
    });
  });

  group('InputsScreen – specialised inputs', () {
    testWidgets('DSSearchInput renders', (tester) async {
      await pumpScreen(tester, const InputsScreen());

      expect(find.byType(DSSearchInput), findsOneWidget);
    });

    testWidgets('DSUrlInput renders with label', (tester) async {
      await pumpScreen(tester, const InputsScreen());

      expect(find.byType(DSUrlInput), findsOneWidget);
      expect(find.text('Website URL'), findsOneWidget);
    });

    testWidgets('DSPhoneInput renders with label', (tester) async {
      await pumpScreen(tester, const InputsScreen());

      expect(find.byType(DSPhoneInput), findsOneWidget);
      expect(find.text('Phone number'), findsOneWidget);
    });

    testWidgets('DSAmountInput renders with label', (tester) async {
      await pumpScreen(tester, const InputsScreen());

      expect(find.byType(DSAmountInput), findsOneWidget);
      expect(find.text('Set budget'), findsOneWidget);
    });

    testWidgets('DSPasswordInput renders with label', (tester) async {
      await pumpScreen(tester, const InputsScreen());

      expect(find.byType(DSPasswordInput), findsOneWidget);
      expect(find.text('Confirm password'), findsOneWidget);
    });

    testWidgets('DSReferralInput renders with pre-filled value WELCOME25', (tester) async {
      await pumpScreen(tester, const InputsScreen());

      expect(find.byType(DSReferralInput), findsOneWidget);
      expect(find.text('WELCOME25'), findsOneWidget);
    });

    testWidgets('DSTagsInput renders with label', (tester) async {
      await pumpScreen(tester, const InputsScreen());

      expect(find.byType(DSTagsInput), findsOneWidget);
      expect(find.text('Enter tags'), findsAtLeastNWidgets(1));
    });
  });

  group('InputsScreen – DSTextArea', () {
    testWidgets('renders DSTextArea widgets', (tester) async {
      await pumpScreen(tester, const InputsScreen());

      expect(find.byType(DSTextArea), findsAtLeastNWidgets(1));
    });

    testWidgets('textarea error state shows character-limit message', (tester) async {
      await pumpScreen(tester, const InputsScreen());

      expect(find.textContaining('Please shorten your message'), findsOneWidget);
    });

    testWidgets('filled textarea has pre-populated content', (tester) async {
      await pumpScreen(tester, const InputsScreen());

      expect(find.textContaining('I am reaching out to inquire'), findsOneWidget);
    });
  });

  group('InputsScreen – DSInputGroup', () {
    testWidgets('renders DSInputGroup with newsletter label and Subscribe button', (tester) async {
      await pumpScreen(tester, const InputsScreen());

      expect(find.byType(DSInputGroup), findsOneWidget);
      expect(find.text('Subscribe to Newsletter'), findsOneWidget);
      expect(find.text('Subscribe'), findsOneWidget);
    });

    testWidgets('tapping Subscribe button fires without error', (tester) async {
      await pumpScreen(tester, const InputsScreen());

      await tester.tap(find.text('Subscribe'));
      await tester.pump();
    });
  });

  group('InputsScreen – DSCombobox', () {
    testWidgets('DSCombobox renders with "Diet preference" label', (tester) async {
      await pumpScreen(tester, const InputsScreen());

      expect(find.byType(DSCombobox<String>), findsOneWidget);
      expect(find.text('Diet preference'), findsOneWidget);
    });

    testWidgets('DSMultiCombobox renders with "Enter tags" label', (tester) async {
      await pumpScreen(tester, const InputsScreen());

      expect(find.byType(DSMultiCombobox<String>), findsOneWidget);
      // label appears twice: section title + input label
      expect(find.text('Enter tags'), findsAtLeastNWidgets(1));
    });
  });
}
