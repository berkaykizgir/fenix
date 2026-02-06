import 'package:fenix/config/env/env.dart';

/// Application-level constants.
abstract class AppConstants {
  // API
  static const int connectionTimeout = 30000;
  static const int receiveTimeout = 30000;

  // Pagination
  static const int defaultPageSize = 20;

  // Image sizes
  static const String posterSize = 'w220_and_h330_face';

  // Builds full poster image URL.
  static String getPosterUrl(String posterPath) => '${Env.imageBaseUrl}/$posterSize$posterPath';
}
