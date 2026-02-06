import 'package:auto_route/auto_route.dart';
import 'package:fenix/config/routes/app_routes.dart';
import 'package:fenix/features/movies/domain/entities/movie.dart';
import 'package:fenix/features/movies/presentation/pages/home_page.dart';
import 'package:fenix/features/movies/presentation/pages/movie_detail_page.dart';
import 'package:fenix/features/favorites/presentation/pages/favorites_page.dart';
import 'package:flutter/material.dart';

part 'app_router.gr.dart';

/// Application router configuration.
@AutoRouterConfig(replaceInRouteName: 'Page,Route')
class AppRouter extends RootStackRouter {
  @override
  List<AutoRoute> get routes => [
    /// Home page is the initial route.
    AutoRoute(
      path: AppRoutes.home,
      page: HomeRoute.page,
      initial: true, // ⬅️ HomePage initial
    ),

    /// Movie detail route.
    AutoRoute(
      path: AppRoutes.movieDetail,
      page: MovieDetailRoute.page,
    ),

    /// Favorites page route.
    AutoRoute(
      path: AppRoutes.favorites,
      page: FavoritesRoute.page,
    ),
  ];
}
