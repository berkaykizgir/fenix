import 'package:fenix/config/theme/theme_storage.dart';
import 'package:flutter/material.dart';
import 'package:injectable/injectable.dart';

@lazySingleton
class ThemeManager {
  ThemeManager(this._storage);

  final ThemeStorage _storage;
  ValueNotifier<ThemeMode>? _themeModeNotifier;

  /// Notifier for reactive theme changes.
  ValueNotifier<ThemeMode> get themeModeNotifier {
    assert(_themeModeNotifier != null, 'Call initialize() first');
    return _themeModeNotifier!;
  }

  /// Load saved theme and set initial notifier value.
  Future<void> initialize() async {
    final savedTheme = await _storage.getSavedThemeMode();
    _themeModeNotifier = ValueNotifier(savedTheme ?? ThemeMode.system);
  }

  /// Update theme mode and persist it.
  Future<void> changeThemeMode(ThemeMode themeMode) async {
    _themeModeNotifier?.value = themeMode;
    await _storage.saveThemeMode(themeMode);
  }

  void dispose() {
    _themeModeNotifier?.dispose();
  }
}
