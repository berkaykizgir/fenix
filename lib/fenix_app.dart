import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';

import 'config/routes/app_router.dart';

class FenixApp extends StatelessWidget {
  const FenixApp({super.key});

  static final _appRouter = AppRouter();

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'Fenix',
      debugShowCheckedModeBanner: false,

      /// Localization
      locale: context.locale,
      supportedLocales: context.supportedLocales,
      localizationsDelegates: context.localizationDelegates,

      /// Routing
      routerConfig: _appRouter.config(),

      /// Theme (şimdilik minimal)
      theme: ThemeData(
        useMaterial3: true,
      ),
    );
  }
}
