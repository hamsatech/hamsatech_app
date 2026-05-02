import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hamsatech_design_system_example/screens/colors_screen.dart';
import '../test_helpers.dart';

void main() {
  group('ColorsScreen – section rendering', () {
    testWidgets('renders all four section headings', (tester) async {
      await pumpScreen(tester, const ColorsScreen());

      expect(find.text('BRAND & SEMANTIC'), findsOneWidget);
      expect(find.text('GRAY SCALE'), findsOneWidget);
      expect(find.text('APP SURFACES'), findsOneWidget);
      expect(find.text('TEXT'), findsOneWidget);
    });

    testWidgets('renders section descriptions', (tester) async {
      await pumpScreen(tester, const ColorsScreen());

      expect(find.text('Core palette used across all components'), findsOneWidget);
      expect(find.text('From white to black'), findsOneWidget);
      expect(find.text('Dark-theme surface tokens'), findsOneWidget);
      expect(find.text('Text colour tokens'), findsOneWidget);
    });
  });

  group('ColorsScreen – swatch tiles', () {
    testWidgets('renders brand swatch labels', (tester) async {
      await pumpScreen(tester, const ColorsScreen());

      for (final name in ['Brand', 'Coral', 'Navy', 'Error', 'Success', 'Warning', 'Info']) {
        expect(find.text(name), findsOneWidget, reason: '"$name" swatch missing');
      }
    });

    testWidgets('renders gray scale swatch labels', (tester) async {
      await pumpScreen(tester, const ColorsScreen());

      for (final name in ['Gray 50', 'Gray 100', 'Gray 900']) {
        expect(find.text(name), findsOneWidget, reason: '"$name" swatch missing');
      }
    });

    testWidgets('renders surface swatch labels', (tester) async {
      await pumpScreen(tester, const ColorsScreen());

      for (final name in ['Background', 'Surface', 'Card', 'Border', 'Divider']) {
        expect(find.text(name), findsOneWidget, reason: '"$name" swatch missing');
      }
    });

    testWidgets('renders text colour swatch labels', (tester) async {
      await pumpScreen(tester, const ColorsScreen());

      expect(find.text('Text Primary'), findsOneWidget);
      expect(find.text('Text Secondary'), findsOneWidget);
      expect(find.text('Text Muted'), findsOneWidget);
    });

    testWidgets('hex values are visible below swatch tiles', (tester) async {
      await pumpScreen(tester, const ColorsScreen());

      expect(find.textContaining('#14B8A6'), findsOneWidget);
    });
  });

  group('ColorsScreen – dark theme', () {
    testWidgets('renders correctly in dark theme', (tester) async {
      await pumpScreen(tester, const ColorsScreen(), themeMode: ThemeMode.dark);

      expect(find.text('BRAND & SEMANTIC'), findsOneWidget);
      expect(find.text('Brand'), findsOneWidget);
    });
  });
}
