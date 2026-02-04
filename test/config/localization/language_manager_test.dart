import 'package:fenix/config/localization/language_manager.dart';
import 'package:fenix/config/localization/language_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class MockLanguageStorage extends Mock implements LanguageStorage {}

void main() {
  late LanguageManager languageManager;
  late MockLanguageStorage mockStorage;

  setUp(() {
    mockStorage = MockLanguageStorage();
    languageManager = LanguageManager(mockStorage);
  });

  group('LanguageManager', () {
    group('getInitialLocale', () {
      test('should return saved locale when storage has language code', () {
        // Arrange
        when(() => mockStorage.getSavedLanguageCode()).thenReturn('tr');

        // Act
        final result = languageManager.getInitialLocale();

        // Assert
        expect(result, const Locale('tr'));
        verify(() => mockStorage.getSavedLanguageCode()).called(1);
      });

      test('should return English when storage has no language code', () {
        // Arrange
        when(() => mockStorage.getSavedLanguageCode()).thenReturn(null);

        // Act
        final result = languageManager.getInitialLocale();

        // Assert
        expect(result, const Locale('en'));
        verify(() => mockStorage.getSavedLanguageCode()).called(1);
      });

      test('should return English when storage returns empty string', () {
        // Arrange
        when(() => mockStorage.getSavedLanguageCode()).thenReturn('');

        // Act
        final result = languageManager.getInitialLocale();

        // Assert
        expect(result, const Locale('en'));
      });
    });

    group('saveSelectedLocale', () {
      test('should save language code to storage', () async {
        // Arrange
        const locale = Locale('tr');
        when(() => mockStorage.saveLanguageCode(any())).thenAnswer((_) async => {});

        // Act
        await languageManager.saveSelectedLocale(locale);

        // Assert
        verify(() => mockStorage.saveLanguageCode('tr')).called(1);
      });
    });
  });
}
