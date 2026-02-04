import 'package:auto_route/auto_route.dart';
import 'package:fenix/config/routes/app_routes.dart';
import 'package:fenix/features/splash/presentation/pages/splash_page.dart';
import 'package:fenix/features/movies/presentation/pages/home_page.dart';
import 'package:fenix/features/movies/presentation/pages/movie_detail_page.dart';
import 'package:fenix/features/favorites/presentation/pages/favorites_page.dart';

/// Generated router file.
///
/// This file will be created automatically by `auto_route_generator`.
/// Do not modify it manually.
part 'app_router.gr.dart';

/// Application router configuration.
///
/// All app routes are defined here to keep navigation
/// centralized and independent from feature logic.
@AutoRouterConfig(replaceInRouteName: 'Page,Route')
class AppRouter extends RootStackRouter {
  @override
  List<AutoRoute> get routes => [
        /// Splash is the initial route.
        AutoRoute(
          path: AppRoutes.splash,
          page: SplashRoute.page,
          initial: true,
        ),

        /// Home page route.
        AutoRoute(
          path: AppRoutes.home,
          page: HomeRoute.page,
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
