import 'package:flutter/material.dart';

class AppTheme {
  static const _primaryLight = Color(0xFF6750A4);
  static const _primaryDark = Color(0xFFD0BCFF);
  static const _secondaryLight = Color(0xFF625B71);
  static const _secondaryDark = Color(0xFFCCC2DC);
  static const _errorLight = Color(0xFFB3261E);
  static const _errorDark = Color(0xFFF2B8B5);

  static final ThemeData lightTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.light,
    colorScheme: ColorScheme.light(
      primary: _primaryLight,
      secondary: _secondaryLight,
      error: _errorLight,
      surface: Colors.grey.shade50,
    ),
    appBarTheme: AppBarTheme(
      elevation: 0,
      backgroundColor: Colors.grey.shade50,
      foregroundColor: _primaryLight,
    ),
    floatingActionButtonTheme: FloatingActionButtonThemeData(
      backgroundColor: _primaryLight,
      foregroundColor: Colors.white,
      elevation: 2,
    ),
    cardTheme: CardTheme(
      elevation: 1,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    ),
    iconButtonTheme: IconButtonThemeData(
      style: ButtonStyle(
        foregroundColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.pressed)) {
            return _primaryLight.withValues(alpha: (_primaryLight.a * 0.8).toDouble());
          }
          return _primaryLight;
        }),
      ),
    ),
  );

  static final ThemeData darkTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    colorScheme: ColorScheme.dark(
      primary: _primaryDark,
      secondary: _secondaryDark,
      error: _errorDark,
      surface: const Color(0xFF1C1B1F),
    ),
    appBarTheme: const AppBarTheme(
      elevation: 0,
      backgroundColor: Color(0xFF1C1B1F),
      foregroundColor: _primaryDark,
    ),
    floatingActionButtonTheme: FloatingActionButtonThemeData(
      backgroundColor: _primaryDark,
      foregroundColor: Colors.black,
      elevation: 2,
    ),
    cardTheme: CardTheme(
      elevation: 1,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    ),
    iconButtonTheme: IconButtonThemeData(
      style: ButtonStyle(
        foregroundColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.pressed)) {
            return _primaryDark.withValues(alpha: (_primaryDark.a * 0.8).toDouble());
          }
          return _primaryDark;
        }),
      ),
    ),
  );
}
