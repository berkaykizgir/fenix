import 'package:fenix/config/localization/language_storage.dart';
import 'package:hive/hive.dart';

class LanguageStorageImpl implements LanguageStorage {
  static const _boxName = 'settings';
  static const _languageKey = 'language_code';

  @override
  Future<void> saveLanguageCode(String languageCode) async {
    final box = Hive.box<String>(_boxName);
    await box.put(_languageKey, languageCode);
  }

  @override
  String? getSavedLanguageCode() {
    if (!Hive.isBoxOpen(_boxName)) {
      return null;
    }

    final box = Hive.box<String>(_boxName);
    return box.get(_languageKey);
  }
}
