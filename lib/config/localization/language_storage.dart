/// Abstraction for persisting selected language.
abstract class LanguageStorage {
  /// Save selected language code (e.g. "en", "tr").
  Future<void> saveLanguageCode(String languageCode);

  /// Return saved language code if it exists.
  String? getSavedLanguageCode();
}
