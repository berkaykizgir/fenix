import 'package:auto_route/auto_route.dart';
import 'package:fenix/config/routes/app_router.dart';
import 'package:flutter/material.dart';

@RoutePage()
class SplashPage extends StatelessWidget {
  const SplashPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: ElevatedButton(
          onPressed: () async {
            await context.router.replace(const HomeRoute());
          },
          child: const Text('Go to Home'),
        ),
      ),
    );
  }
}
