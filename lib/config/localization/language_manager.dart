import 'dart:ui';

import 'package:fenix/config/localization/language_storage.dart';
import 'package:flutter/material.dart';
import 'package:injectable/injectable.dart';

@lazySingleton
class LanguageManager {
  LanguageManager(this._storage);

  final LanguageStorage _storage;

  /// Returns initial locale for the application.
  ///
  /// Priority:
  /// 1. Saved language in local storage
  /// 2. Fallback locale (English)
  Locale getInitialLocale(List<Locale> supportedLocales) {
    final savedLanguageCode = _storage.getSavedLanguageCode();

    // 1️⃣ Saved locale
    if (savedLanguageCode != null && savedLanguageCode.isNotEmpty) {
      return Locale(savedLanguageCode);
    }

    // 2️⃣ System locale
    final systemLocale = PlatformDispatcher.instance.locale;

    final isSupported = supportedLocales.any(
      (locale) => locale.languageCode == systemLocale.languageCode,
    );

    if (isSupported) {
      return Locale(systemLocale.languageCode);
    }

    // 3️⃣ Final fallback → first supported (usually 'en')
    return Locale(supportedLocales.first.languageCode);
  }

  /// Persists selected language.
  ///
  /// UI layer is responsible for calling `context.setLocale`.
  Future<void> saveSelectedLocale(Locale locale) async {
    debugPrint('✅ Language saved: ${locale.languageCode}');
    await _storage.saveLanguageCode(locale.languageCode);
  }
}
