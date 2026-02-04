import 'package:equatable/equatable.dart';

/// Base failure class for domain layer.
///
/// All failures must extend this class.
/// Failures represent business logic errors, not technical exceptions.
abstract class Failure extends Equatable {
  const Failure(this.message);

  final String message;

  @override
  List<Object?> get props => [message];
}

/// Server-related failures (5xx, 4xx errors)
class ServerFailure extends Failure {
  const ServerFailure([super.message = 'Server error occurred']);
}

/// Network connectivity failures
class NetworkFailure extends Failure {
  const NetworkFailure([super.message = 'No internet connection']);
}

/// Local storage failures (Hive errors)
class CacheFailure extends Failure {
  const CacheFailure([super.message = 'Cache error occurred']);
}

/// Unexpected/unknown failures
class UnexpectedFailure extends Failure {
  const UnexpectedFailure([super.message = 'Unexpected error occurred']);
}
