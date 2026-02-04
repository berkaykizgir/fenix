import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';

import 'config/routes/app_router.dart';
import 'config/theme/app_theme.dart';
import 'config/theme/theme_manager.dart';
import 'core/di/injection.dart';

class FenixApp extends StatelessWidget {
  const FenixApp({super.key});

  static final _appRouter = AppRouter();

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<ThemeMode>(
      valueListenable: getIt<ThemeManager>().themeModeNotifier,
      builder: (context, themeMode, _) {
        return MaterialApp.router(
          title: 'Fenix',
          debugShowCheckedModeBanner: false,

          /// Localization
          locale: context.locale,
          supportedLocales: context.supportedLocales,
          localizationsDelegates: context.localizationDelegates,

          /// Routing
          routerConfig: _appRouter.config(),

          /// Theme
          theme: AppTheme.lightTheme,
          darkTheme: AppTheme.darkTheme,
          themeMode: themeMode,
        );
      },
    );
  }
}
