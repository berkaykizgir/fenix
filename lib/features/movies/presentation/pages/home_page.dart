import 'package:auto_route/auto_route.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:fenix/config/localization/language_manager.dart';
import 'package:fenix/config/routes/app_router.dart';
import 'package:fenix/config/theme/theme_manager.dart';
import 'package:fenix/core/di/injection.dart';
import 'package:flutter/material.dart';

@RoutePage()
class HomePage extends StatelessWidget {
  const HomePage({super.key});

  Future<void> _changeLanguage(BuildContext context, Locale locale) async {
    await getIt<LanguageManager>().saveSelectedLocale(locale);

    if (context.mounted) {
      await context.setLocale(locale);
    }
  }

  Future<void> _changeTheme(ThemeMode themeMode) async {
    await getIt<ThemeManager>().changeThemeMode(themeMode);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('home.title'.tr()),
        actions: [
          // Language selector
          PopupMenuButton<Locale>(
            icon: const Icon(Icons.language),
            onSelected: (locale) => _changeLanguage(context, locale),
            itemBuilder: (_) => const [
              PopupMenuItem(
                value: Locale('en'),
                child: Text('English'),
              ),
              PopupMenuItem(
                value: Locale('tr'),
                child: Text('Türkçe'),
              ),
            ],
          ),
          // Theme selector
          PopupMenuButton<ThemeMode>(
            icon: const Icon(Icons.brightness_6),
            onSelected: _changeTheme,
            itemBuilder: (_) => const [
              PopupMenuItem(
                value: ThemeMode.light,
                child: Text('Light'),
              ),
              PopupMenuItem(
                value: ThemeMode.dark,
                child: Text('Dark'),
              ),
              PopupMenuItem(
                value: ThemeMode.system,
                child: Text('System'),
              ),
            ],
          ),
        ],
      ),
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ElevatedButton(
              onPressed: () => context.router.push(const MovieDetailRoute()),
              child: Text('home.go_to_detail'.tr()),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => context.router.push(const FavoritesRoute()),
              child: Text('home.go_to_favorites'.tr()),
            ),
          ],
        ),
      ),
    );
  }
}
