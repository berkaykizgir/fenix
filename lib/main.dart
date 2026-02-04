import 'package:easy_localization/easy_localization.dart';
import 'package:fenix/core/di/injection.dart';
import 'package:fenix/fenix_app.dart';
import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';

import 'config/theme/theme_manager.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  /// Hive initialization
  await Hive.initFlutter();

  /// Dependency Injection setup
  await configureDependencies();
  await getIt<ThemeManager>().initialize();

  /// Localization initialization
  await EasyLocalization.ensureInitialized();
  EasyLocalization.logger.enableLevels = [];

  runApp(
    EasyLocalization(
      supportedLocales: const [
        Locale('en'),
        Locale('tr'),
      ],
      path: 'assets/translations',
      fallbackLocale: const Locale('en'),
      child: const FenixApp(),
    ),
  );
}
