import 'package:easy_localization/easy_localization.dart';
import 'package:fenix/fenix_app.dart';
import 'package:flutter/material.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

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
