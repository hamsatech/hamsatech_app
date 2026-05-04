import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

/// Pumps [screen] in a tall (6 000 px) viewport so that all ListView children
/// are built at once — avoids off-screen items being absent from the tree.
///
/// Also registers a teardown that unfocuses any active text field and settles
/// all pending frames before the widget tree is torn down. This prevents
/// lifecycle assertion failures caused by inline TextEditingControllers that
/// are created in build() and never explicitly disposed (e.g. InputsScreen).
Future<void> pumpScreen(
  WidgetTester tester,
  Widget screen, {
  ThemeMode themeMode = ThemeMode.light,
}) async {
  tester.view.physicalSize = const Size(900, 6000);
  tester.view.devicePixelRatio = 1.0;
  addTearDown(tester.view.reset);
  addTearDown(() async {
    FocusManager.instance.primaryFocus?.unfocus();
    await tester.pump(const Duration(seconds: 1));
  });

  await tester.pumpWidget(_wrap(screen, themeMode));
  await tester.pump();
}

Widget _wrap(Widget child, ThemeMode themeMode) {
  return MaterialApp(
    themeMode: themeMode,
    theme: ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF14B8A6)),
      scaffoldBackgroundColor: const Color(0xFFF0F9FF),
    ),
    darkTheme: ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      colorScheme: ColorScheme.fromSeed(
        seedColor: const Color(0xFF14B8A6),
        brightness: Brightness.dark,
      ),
      scaffoldBackgroundColor: const Color(0xFF040C18),
    ),
    home: Scaffold(body: child),
  );
}

/// Lightweight wrapper for tests that manage their own viewport size
/// (e.g. shell navigation tests).
Widget makeTestable(Widget child, {ThemeMode themeMode = ThemeMode.light}) =>
    _wrap(child, themeMode);
