import 'package:flutter/material.dart';

import 'data/asset_repository.dart';
import 'screens/app_shell.dart';

void main() {
  runApp(MyApp(repository: AssetRepository()));
}

class MyApp extends StatelessWidget {
  const MyApp({
    super.key,
    required this.repository,
  });

  final AssetRepository repository;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: '我的资产',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.teal),
        useMaterial3: true,
      ),
      home: AppShell(repository: repository),
    );
  }
}
