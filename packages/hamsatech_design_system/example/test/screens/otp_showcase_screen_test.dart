import 'package:flutter_test/flutter_test.dart';
import 'package:hamsatech_design_system/hamsatech_design_system.dart';
import 'package:hamsatech_design_system_example/screens/otp_showcase_screen.dart';
import '../test_helpers.dart';

void main() {
  group('OtpShowcaseScreen – section headings', () {
    testWidgets('renders all section titles', (tester) async {
      await pumpScreen(tester, const OtpShowcaseScreen());

      expect(find.text('4-DIGIT'), findsOneWidget);
      expect(find.text('6-DIGIT'), findsOneWidget);
      expect(find.text('6-DIGIT WITH SEPARATOR'), findsOneWidget);
      expect(find.text('ERROR STATE'), findsOneWidget);
      expect(find.text('DISABLED STATE'), findsOneWidget);
      expect(find.text('CELL SIZE VARIANTS'), findsOneWidget);
    });

    testWidgets('renders section descriptions', (tester) async {
      await pumpScreen(tester, const OtpShowcaseScreen());

      expect(find.text('Default length for PIN / OTP'), findsOneWidget);
      expect(find.text('Control cell size with the cellSize property'), findsOneWidget);
    });
  });

  group('OtpShowcaseScreen – DSOtpInput instances', () {
    testWidgets('renders at least 6 DSOtpInput widgets', (tester) async {
      await pumpScreen(tester, const OtpShowcaseScreen());

      // 4-digit, 6-digit, separator, error, disabled, 3×size = 8 total
      expect(find.byType(DSOtpInput), findsAtLeastNWidgets(6));
    });

    testWidgets('renders input labels for named inputs', (tester) async {
      await pumpScreen(tester, const OtpShowcaseScreen());

      expect(find.text('Verification code'), findsOneWidget);
      expect(find.text('Auth code'), findsOneWidget);
      expect(find.text('Newsletter code'), findsOneWidget);
    });
  });

  group('OtpShowcaseScreen – error state', () {
    testWidgets('renders the error message text', (tester) async {
      await pumpScreen(tester, const OtpShowcaseScreen());

      expect(find.text('Invalid code. Please try again.'), findsOneWidget);
    });

    testWidgets('error input label "Verification" is visible', (tester) async {
      await pumpScreen(tester, const OtpShowcaseScreen());

      expect(find.text('Verification'), findsOneWidget);
    });
  });

  group('OtpShowcaseScreen – disabled state', () {
    testWidgets('disabled input label "Disabled" is visible', (tester) async {
      await pumpScreen(tester, const OtpShowcaseScreen());

      expect(find.text('Disabled'), findsOneWidget);
    });

    testWidgets('tapping disabled OTP does not throw', (tester) async {
      await pumpScreen(tester, const OtpShowcaseScreen());

      final disabledInput = find.widgetWithText(DSOtpInput, 'Disabled');
      await tester.tap(disabledInput, warnIfMissed: false);
      await tester.pump();
    });
  });

  group('OtpShowcaseScreen – cell size variants', () {
    testWidgets('renders Small, Default, Large size card labels', (tester) async {
      await pumpScreen(tester, const OtpShowcaseScreen());

      expect(find.text('Small (36px)'), findsOneWidget);
      expect(find.text('Default (52px)'), findsOneWidget);
      expect(find.text('Large (64px)'), findsOneWidget);
    });
  });

  group('OtpShowcaseScreen – helper texts', () {
    testWidgets('renders helper text for 4-digit input', (tester) async {
      await pumpScreen(tester, const OtpShowcaseScreen());

      expect(
        find.text('Enter the 4-digit code sent to your phone'),
        findsOneWidget,
      );
    });
  });
}
