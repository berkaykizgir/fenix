import 'package:fenix/config/theme/theme_manager.dart';
import 'package:fenix/config/theme/theme_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class MockThemeStorage extends Mock implements ThemeStorage {}

void main() {
  late ThemeManager themeManager;
  late MockThemeStorage mockStorage;

  setUpAll(() {
    registerFallbackValue(ThemeMode.system);
  });

  setUp(() {
    mockStorage = MockThemeStorage();
    themeManager = ThemeManager(mockStorage);
  });

  group('ThemeManager', () {
    group('init', () {
      test('should load saved theme mode when storage has value', () async {
        when(() => mockStorage.getSavedThemeMode()).thenAnswer((_) async => ThemeMode.dark);

        await themeManager.initialize();

        expect(themeManager.themeModeNotifier.value, ThemeMode.dark);
        verify(() => mockStorage.getSavedThemeMode()).called(1);
      });

      test('should fallback to system theme when storage has no value', () async {
        when(() => mockStorage.getSavedThemeMode()).thenAnswer((_) async => null);

        await themeManager.initialize();

        expect(themeManager.themeModeNotifier.value, ThemeMode.system);
        verify(() => mockStorage.getSavedThemeMode()).called(1);
      });
    });

    group('changeThemeMode', () {
      test('should update notifier and persist theme mode', () async {
        // Arrange
        // Now 'any()' will work because it has a fallback value to use internally
        when(() => mockStorage.saveThemeMode(any())).thenAnswer((_) async {});

        // Ensure initialize is called first if your logic depends on the notifier being set up
        // (Assuming initialize sets the default value, usually required before changeThemeMode)
        when(() => mockStorage.getSavedThemeMode()).thenAnswer((_) async => ThemeMode.light);
        await themeManager.initialize();

        // Act
        await themeManager.changeThemeMode(ThemeMode.dark);

        // Assert
        expect(themeManager.themeModeNotifier.value, ThemeMode.dark);
        verify(() => mockStorage.saveThemeMode(ThemeMode.dark)).called(1);
      });
    });
  });
}
