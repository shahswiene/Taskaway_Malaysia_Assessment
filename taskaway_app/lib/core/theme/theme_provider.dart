import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Provider for controlling the app's theme mode
/// Using light mode as the initial theme
final themeProvider = StateProvider<ThemeMode>((ref) => ThemeMode.light);

/// Store the theme preference persistently
Future<void> saveThemePreference(ThemeMode mode) async {
  final prefs = await SharedPreferences.getInstance();
  await prefs.setString('theme_mode', mode.toString());
}

/// Loads the saved theme preference
Future<ThemeMode> loadThemePreference() async {
  final prefs = await SharedPreferences.getInstance();
  final themeStr = prefs.getString('theme_mode');
  
  if (themeStr == 'ThemeMode.dark') {
    return ThemeMode.dark;
  }
  return ThemeMode.light; // default to light mode
}
