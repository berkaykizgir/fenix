/// Abstraction for persisting selected language.
///
/// This layer isolates storage implementation (Hive)
/// from the rest of the application to keep the code
/// testable and flexible.
abstract class LanguageStorage {
  /// Saves selected language code (e.g. "en", "tr")
  Future<void> saveLanguageCode(String languageCode);

  /// Returns saved language code if exists
  String? getSavedLanguageCode();
}
