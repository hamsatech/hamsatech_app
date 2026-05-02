import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hamsatech_design_system_example/main.dart';
import 'package:hamsatech_design_system_example/screens/colors_screen.dart';
import 'package:hamsatech_design_system_example/screens/typography_screen.dart';
import 'package:hamsatech_design_system_example/screens/button_showcase_screen.dart';
import 'package:hamsatech_design_system_example/screens/checkbox_screen.dart';
import 'package:hamsatech_design_system_example/screens/otp_showcase_screen.dart';
import 'package:hamsatech_design_system_example/screens/list_select_screen.dart';
import 'package:hamsatech_design_system_example/screens/misc_screen.dart';

void main() {
  // Use a wide surface so the sidebar + content both fit comfortably.
  setUp(() {
    TestWidgetsFlutterBinding.ensureInitialized();
  });

  Future<void> pumpApp(WidgetTester tester) async {
    tester.view.physicalSize = const Size(1400, 900);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() => tester.view.reset());

    await tester.pumpWidget(const DSExampleApp());
    await tester.pump();
  }

  group('ShellScreen – initial render', () {
    testWidgets('app launches and shows sidebar brand name', (tester) async {
      await pumpApp(tester);
      expect(find.text('HamsaTech'), findsOneWidget);
      expect(find.text('Design System'), findsOneWidget);
    });

    testWidgets('sidebar shows all 8 nav labels', (tester) async {
      await pumpApp(tester);
      for (final label in [
        'Colors', 'Typography', 'Buttons', 'Inputs',
        'OTP Input', 'Checkbox', 'List / Select', 'Misc',
      ]) {
        expect(find.text(label), findsOneWidget, reason: '"$label" nav item missing');
      }
    });

    testWidgets('sidebar shows section group headers', (tester) async {
      await pumpApp(tester);
      expect(find.text('FOUNDATION'), findsOneWidget);
      expect(find.text('COMPONENTS'), findsOneWidget);
    });

    testWidgets('default tab is Colors', (tester) async {
      await pumpApp(tester);
      expect(find.byType(ColorsScreen), findsOneWidget);
    });

    testWidgets('version footer is visible', (tester) async {
      await pumpApp(tester);
      expect(find.textContaining('v1.0.0'), findsOneWidget);
    });
  });

  group('ShellScreen – sidebar navigation', () {
    testWidgets('tapping Typography shows TypographyScreen', (tester) async {
      await pumpApp(tester);
      await tester.tap(find.text('Typography'));
      await tester.pump();
      expect(find.byType(TypographyScreen), findsOneWidget);
    });

    testWidgets('tapping Buttons shows ButtonShowcaseScreen', (tester) async {
      await pumpApp(tester);
      await tester.tap(find.text('Buttons'));
      await tester.pump();
      expect(find.byType(ButtonShowcaseScreen), findsOneWidget);
    });

    testWidgets('tapping Checkbox shows CheckboxScreen', (tester) async {
      await pumpApp(tester);
      await tester.tap(find.text('Checkbox'));
      await tester.pump();
      expect(find.byType(CheckboxScreen), findsOneWidget);
    });

    testWidgets('tapping OTP Input shows OtpShowcaseScreen', (tester) async {
      await pumpApp(tester);
      await tester.tap(find.text('OTP Input'));
      await tester.pump();
      expect(find.byType(OtpShowcaseScreen), findsOneWidget);
    });

    testWidgets('tapping List / Select shows ListSelectScreen', (tester) async {
      await pumpApp(tester);
      await tester.tap(find.text('List / Select'));
      await tester.pump();
      expect(find.byType(ListSelectScreen), findsOneWidget);
    });

    testWidgets('tapping Misc shows MiscScreen', (tester) async {
      await pumpApp(tester);
      await tester.tap(find.text('Misc'));
      await tester.pump();
      expect(find.byType(MiscScreen), findsOneWidget);
    });

    testWidgets('navigation back to Colors restores ColorsScreen', (tester) async {
      await pumpApp(tester);
      await tester.tap(find.text('Typography'));
      await tester.pump();
      await tester.tap(find.text('Colors'));
      await tester.pump();
      expect(find.byType(ColorsScreen), findsOneWidget);
    });
  });

  group('ShellScreen – theme toggle', () {
    testWidgets('theme toggle button is present', (tester) async {
      await pumpApp(tester);
      // Light mode shows a dark_mode icon to switch to dark
      expect(find.byIcon(Icons.dark_mode_outlined), findsOneWidget);
    });

    testWidgets('tapping theme toggle switches to dark mode icon', (tester) async {
      await pumpApp(tester);
      await tester.tap(find.byIcon(Icons.dark_mode_outlined));
      // Use pump with duration rather than pumpAndSettle because InputsScreen's
      // loading DSTextInput renders a CircularProgressIndicator that never settles.
      await tester.pump(const Duration(milliseconds: 500));
      expect(find.byIcon(Icons.light_mode_outlined), findsOneWidget);
    });

    testWidgets('tapping theme toggle twice returns to light mode', (tester) async {
      await pumpApp(tester);
      await tester.tap(find.byIcon(Icons.dark_mode_outlined));
      await tester.pump(const Duration(milliseconds: 500));
      await tester.tap(find.byIcon(Icons.light_mode_outlined));
      await tester.pump(const Duration(milliseconds: 500));
      expect(find.byIcon(Icons.dark_mode_outlined), findsOneWidget);
    });
  });
}
