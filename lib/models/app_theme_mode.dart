import 'package:flutter/material.dart';

enum AppThemeMode {
  light('light', '浅色模式'),
  dark('dark', '深色模式');

  const AppThemeMode(this.value, this.label);

  final String value;
  final String label;

  ThemeMode get themeMode =>
      this == AppThemeMode.dark ? ThemeMode.dark : ThemeMode.light;

  static AppThemeMode fromValue(String? value) {
    return AppThemeMode.values.firstWhere(
      (mode) => mode.value == value,
      orElse: () => AppThemeMode.light,
    );
  }
}
