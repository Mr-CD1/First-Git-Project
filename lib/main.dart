import 'package:flutter/material.dart';

import 'constants/app_branding.dart';
import 'data/asset_repository.dart';
import 'models/app_theme_mode.dart';
import 'screens/app_shell.dart';
import 'services/desktop_window_service.dart';
import 'theme/app_theme.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await DesktopWindowService.configure();
  runApp(MyApp(repository: AssetRepository()));
}

class MyApp extends StatefulWidget {
  const MyApp({
    super.key,
    required this.repository,
  });

  final AssetRepository repository;

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  ThemeMode _themeMode = ThemeMode.light;

  void _applyThemeMode(AppThemeMode mode) {
    setState(() => _themeMode = mode.themeMode);
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: AppBranding.appName,
      theme: AppTheme.build(Brightness.light),
      darkTheme: AppTheme.build(Brightness.dark),
      themeMode: _themeMode,
      home: AppShell(
        repository: widget.repository,
        onThemeModeChanged: _applyThemeMode,
      ),
    );
  }
}
