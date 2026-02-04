import 'package:auto_route/auto_route.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:fenix/config/routes/app_router.dart';
import 'package:flutter/material.dart';

@RoutePage()
class HomePage extends StatelessWidget {
  const HomePage({super.key});

  Future<void> _changeLanguage(BuildContext context, Locale locale) async {
    await context.setLocale(locale);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('home.title'.tr()),
        actions: [
          PopupMenuButton<Locale>(
            icon: const Icon(Icons.language),
            onSelected: (locale) async => _changeLanguage(context, locale),
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
        ],
      ),
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ElevatedButton(
              onPressed: () async {
                await context.router.push(const MovieDetailRoute());
              },
              child: Text('home.go_to_detail'.tr()),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () async {
                await context.router.push(const FavoritesRoute());
              },
              child: Text('home.go_to_favorites'.tr()),
            ),
          ],
        ),
      ),
    );
  }
}
