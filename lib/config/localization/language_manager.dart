import 'dart:ui';

import 'package:fenix/config/localization/language_storage.dart';
import 'package:flutter/material.dart';
import 'package:injectable/injectable.dart';

@lazySingleton
class LanguageManager {
  LanguageManager(this._storage);

  final LanguageStorage _storage;

  /// Returns initial locale for the app.
  ///
  /// Priority:
  /// 1) Saved language
  /// 2) System language if supported
  /// 3) First supported locale (fallback)
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
  /// UI layer should call `context.setLocale`.
  Future<void> saveSelectedLocale(Locale locale) async {
    debugPrint('✅ Language saved: ${locale.languageCode}');
    await _storage.saveLanguageCode(locale.languageCode);
  }
}
