import 'package:fenix/config/localization/language_storage.dart';
import 'package:fenix/core/util/constants/hive_constants.dart';
import 'package:hive_ce/hive.dart';
import 'package:injectable/injectable.dart';

/// Hive implementation of LanguageStorage.
///
/// Persists language preference in local storage using Hive.
@LazySingleton(as: LanguageStorage)
class LanguageStorageImpl implements LanguageStorage {
  Box<String>? _box;

  /// Ensures Hive box is open before operations.
  Future<void> _ensureBoxOpen() async {
    if (_box == null || !_box!.isOpen) {
      _box = await Hive.openBox<String>(HiveConstants.settingsBox);
    }
  }

  @override
  Future<void> saveLanguageCode(String languageCode) async {
    await _ensureBoxOpen();
    await _box!.put(HiveConstants.languageKey, languageCode);
  }

  @override
  String? getSavedLanguageCode() {
    if (_box == null || !_box!.isOpen) {
      return null;
    }
    return _box!.get(HiveConstants.languageKey);
  }
}
