import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';

@RoutePage()
class FavoritesPage extends StatelessWidget {
  const FavoritesPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Favorites')),
      body: Center(
        child: ElevatedButton(
          onPressed: () {
            context.router.pop();
          },
          child: const Text('Back'),
        ),
      ),
    );
  }
}
