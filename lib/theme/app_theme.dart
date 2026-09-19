import 'package:flutter/material.dart';

class AppRadii {
  AppRadii._();

  static const sm = 16.0;
  static const md = 24.0;
  static const lg = 28.0;
  static const xl = 32.0;

  static BorderRadius get smBorder => BorderRadius.circular(sm);
  static BorderRadius get mdBorder => BorderRadius.circular(md);
  static BorderRadius get lgBorder => BorderRadius.circular(lg);
  static BorderRadius get xlBorder => BorderRadius.circular(xl);
}

class AppTheme {
  AppTheme._();

  static ThemeData build(Brightness brightness) {
    const seed = Colors.teal;
    final colorScheme = ColorScheme.fromSeed(
      seedColor: seed,
      brightness: brightness,
    );

    final inputBorder = OutlineInputBorder(
      borderRadius: AppRadii.lgBorder,
      borderSide: BorderSide(
        color: colorScheme.outlineVariant.withValues(alpha: 0.35),
      ),
    );

    return ThemeData(
      colorScheme: colorScheme,
      useMaterial3: true,
      scaffoldBackgroundColor: colorScheme.surface,
      appBarTheme: AppBarTheme(
        centerTitle: false,
        elevation: 0,
        scrolledUnderElevation: 0,
        surfaceTintColor: Colors.transparent,
        backgroundColor: colorScheme.surface,
        foregroundColor: colorScheme.onSurface,
      ),
      cardTheme: CardThemeData(
        elevation: 0,
        color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.45),
        shape: RoundedRectangleBorder(borderRadius: AppRadii.mdBorder),
        margin: EdgeInsets.zero,
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: colorScheme.surfaceContainerHighest.withValues(alpha: 0.35),
        border: inputBorder,
        enabledBorder: inputBorder,
        focusedBorder: inputBorder.copyWith(
          borderSide: BorderSide(color: colorScheme.primary, width: 1.5),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          shape: RoundedRectangleBorder(borderRadius: AppRadii.lgBorder),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          shape: RoundedRectangleBorder(borderRadius: AppRadii.lgBorder),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
          side: BorderSide(
            color: colorScheme.outlineVariant.withValues(alpha: 0.4),
          ),
        ),
      ),
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        shape: RoundedRectangleBorder(borderRadius: AppRadii.lgBorder),
        elevation: 2,
      ),
      navigationDrawerTheme: NavigationDrawerThemeData(
        indicatorShape: RoundedRectangleBorder(borderRadius: AppRadii.mdBorder),
      ),
      bottomSheetTheme: BottomSheetThemeData(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(AppRadii.xl)),
        ),
      ),
      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: AppRadii.mdBorder),
      ),
      dividerTheme: DividerThemeData(
        color: colorScheme.outlineVariant.withValues(alpha: 0.25),
      ),
    );
  }

  static BoxDecoration softPanel(ColorScheme colorScheme) {
    return BoxDecoration(
      borderRadius: AppRadii.mdBorder,
      color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
    );
  }

  static BoxDecoration softPanelPrimary(ColorScheme colorScheme) {
    return BoxDecoration(
      borderRadius: AppRadii.mdBorder,
      color: colorScheme.primaryContainer.withValues(alpha: 0.35),
    );
  }
}
