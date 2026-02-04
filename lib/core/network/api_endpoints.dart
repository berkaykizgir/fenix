/// API endpoint paths.
///
/// All API routes are defined here to avoid hardcoded strings.
abstract class ApiEndpoints {
  // Base version path
  static const String version = '/3';

  // Movies
  static const String topRatedMovies = '$version/movie/top_rated';
  static String movieDetails(int movieId) => '$version/movie/$movieId';

  // Search
  static const String searchMovies = '$version/search/movie';
}
