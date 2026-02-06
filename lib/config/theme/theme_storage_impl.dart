import 'package:fenix/config/theme/theme_storage.dart';
import 'package:fenix/core/util/constants/hive_constants.dart';
import 'package:flutter/material.dart';
import 'package:hive_ce/hive.dart';
import 'package:injectable/injectable.dart';

/// Hive-backed implementation of [ThemeStorage].
@LazySingleton(as: ThemeStorage)
class ThemeStorageImpl implements ThemeStorage {
  Box<String>? _box;

  /// Ensures Hive box is open before operations.
  Future<void> _ensureBoxOpen() async {
    if (_box == null || !_box!.isOpen) {
      _box = await Hive.openBox<String>(HiveConstants.settingsBox);
    }
  }

  @override
  Future<void> saveThemeMode(ThemeMode themeMode) async {
    await _ensureBoxOpen();
    await _box!.put(HiveConstants.themeKey, themeMode.name);
    debugPrint('✅ Theme saved: ${themeMode.name}');
  }

  @override
  Future<ThemeMode?> getSavedThemeMode() async {
    await _ensureBoxOpen();

    final savedMode = _box!.get(HiveConstants.themeKey);
    debugPrint('📖 Theme loaded: $savedMode');

    if (savedMode == null) return null;

    return ThemeMode.values.firstWhere(
      (mode) => mode.name == savedMode,
      orElse: () => ThemeMode.system,
    );
  }
}
