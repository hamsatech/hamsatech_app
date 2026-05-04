import 'package:flutter_test/flutter_test.dart';
import 'package:hamsatech_design_system_example/main.dart';

void main() {
  testWidgets('DSExampleApp renders without error', (WidgetTester tester) async {
    await tester.pumpWidget(const DSExampleApp());
    expect(find.byType(DSExampleApp), findsOneWidget);
  });
}
