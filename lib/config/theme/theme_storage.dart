import 'package:flutter/material.dart';

/// Abstraction for persisting theme mode.
abstract class ThemeStorage {
  /// Saves selected theme mode
  Future<void> saveThemeMode(ThemeMode themeMode);

  /// Returns saved theme mode if exists
  Future<ThemeMode?> getSavedThemeMode();
}
