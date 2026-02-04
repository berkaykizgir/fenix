/// Base exception class for data layer.
///
/// Data sources throw exceptions, repositories convert them to Failures.
abstract class AppException implements Exception {
  const AppException(this.message);

  final String message;

  @override
  String toString() => message;
}

/// Thrown when API request fails.
class ServerException extends AppException {
  const ServerException([super.message = 'Server error occurred']);
}

/// Thrown when device has no internet connection.
class NetworkException extends AppException {
  const NetworkException([super.message = 'No internet connection']);
}

/// Thrown when Hive operations fail.
class CacheException extends AppException {
  const CacheException([super.message = 'Cache error occurred']);
}

/// Thrown when JSON parsing fails.
class ParsingException extends AppException {
  const ParsingException([super.message = 'Failed to parse data']);
}
