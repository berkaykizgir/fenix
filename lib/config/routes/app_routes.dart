/// Central place for all route path definitions.
///
/// This file prevents hard-coded strings from being
/// scattered across the app and makes route changes
/// easier and safer.
abstract class AppRoutes {
  /// Splash / initial route
  static const splash = '/';

  /// Home page route
  static const home = '/home';

  /// Movie detail page route
  static const movieDetail = '/movie-detail';

  /// Favorites page route
  static const favorites = '/favorites';
}
