import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';

@RoutePage()
class MovieDetailPage extends StatelessWidget {
  const MovieDetailPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Movie Detail')),
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
