import 'package:flutter/material.dart';

/// Einheitlicher Stil für alle Apps. Nur die Farbe ist pro App verschieden.
abstract final class AppDesign {
  static ThemeData hell(Color farbe) => _thema(farbe, Brightness.light);
  static ThemeData dunkel(Color farbe) => _thema(farbe, Brightness.dark);

  static const radius = 16.0;

  static ThemeData _thema(Color farbe, Brightness helligkeit) {
    final farben = ColorScheme.fromSeed(
      seedColor: farbe,
      brightness: helligkeit,
    );
    final rund = RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(radius),
    );
    return ThemeData(
      colorScheme: farben,
      useMaterial3: true,
      visualDensity: VisualDensity.standard,
      appBarTheme: AppBarTheme(
        centerTitle: false,
        backgroundColor: farben.surface,
        scrolledUnderElevation: 2,
      ),
      cardTheme: CardThemeData(
        shape: rund,
        elevation: 0,
        color: farben.surfaceContainerLow,
        margin: EdgeInsets.zero,
        clipBehavior: Clip.antiAlias,
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          minimumSize: const Size(64, 48),
          shape: rund,
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          minimumSize: const Size(64, 48),
          shape: rund,
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: farben.surfaceContainerHighest.withValues(alpha: 0.5),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
      ),
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        shape: rund,
      ),
      snackBarTheme: const SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
      ),
      listTileTheme: const ListTileThemeData(
        contentPadding: EdgeInsets.symmetric(horizontal: 16),
      ),
    );
  }
}
