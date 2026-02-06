import 'package:flutter/material.dart';

/// Abstraction for persisting theme mode.
abstract class ThemeStorage {
  /// Save selected theme mode.
  Future<void> saveThemeMode(ThemeMode themeMode);

  /// Load saved theme mode if it exists.
  Future<ThemeMode?> getSavedThemeMode();
}
