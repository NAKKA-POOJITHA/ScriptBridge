import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:provider/provider.dart';
import 'core/theme/app_theme.dart';
import 'providers/scan_provider.dart';
import 'screens/home_screen.dart';

void main() async {
  // 1. Ensure widgets are bound
  WidgetsFlutterBinding.ensureInitialized();

  // 2. Initialize Hive Database for offline caching
  await Hive.initFlutter();

  // 3. Launch application with providers injected
  runApp(
    ChangeNotifierProvider<ScanProvider>(
      create: (_) => ScanProvider(),
      child: const ScriptBridgeApp(),
    ),
  );
}

/// The root application class defining application parameters and Material 3 design systems.
class ScriptBridgeApp extends StatelessWidget {
  const ScriptBridgeApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'ScriptBridge',
      debugShowCheckedModeBanner: false,
      themeMode: ThemeMode.dark,
      darkTheme: AppTheme.darkTheme,
      home: const HomeScreen(),
    );
  }
}
