import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hamsatech_design_system/hamsatech_design_system.dart';
import 'core/di/injection.dart';
import 'core/router/app_router.dart';
import 'core/services/storage_service.dart';


void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await StorageService.init();
  setupDI();
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'Hamsa — Mental Performance',
      theme: DSTheme.darkTheme,
      routerConfig: AppRouter.router,
      debugShowCheckedModeBanner: false,
    );
  }
}
