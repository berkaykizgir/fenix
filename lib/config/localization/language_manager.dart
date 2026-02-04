import 'package:fenix/config/localization/language_storage.dart';
import 'package:flutter/material.dart';

class LanguageManager {
  LanguageManager(this._storage);

  final LanguageStorage _storage;

  /// Returns initial locale for the application.
  ///
  /// Priority:
  /// 1. Saved language in local storage
  /// 2. Fallback locale (English)
  Locale getInitialLocale() {
    final savedLanguageCode = _storage.getSavedLanguageCode();

    if (savedLanguageCode == null || savedLanguageCode.isEmpty) {
      return const Locale('en');
    }

    return Locale(savedLanguageCode);
  }

  /// Persists selected language.
  ///
  /// UI layer is responsible for calling `context.setLocale`.
  Future<void> saveSelectedLocale(Locale locale) async {
    await _storage.saveLanguageCode(locale.languageCode);
  }
}
