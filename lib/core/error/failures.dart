import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';

/// Base failure class for domain layer.
///
/// All failures must extend this class.
/// Failures represent business logic errors, not technical exceptions.
@immutable
abstract class Failure extends Equatable {
  const Failure(this.message);

  final String message;

  @override
  List<Object?> get props => [message];
}

/// Server-related failures (5xx, 4xx errors).
@immutable
class ServerFailure extends Failure {
  const ServerFailure([super.message = 'Server error occurred']);
}

/// Network connectivity failures.
@immutable
class NetworkFailure extends Failure {
  const NetworkFailure([super.message = 'No internet connection']);
}

/// Local storage failures (Hive errors).
@immutable
class CacheFailure extends Failure {
  const CacheFailure([super.message = 'Cache error occurred']);
}

/// Unexpected/unknown failures.
@immutable
class UnexpectedFailure extends Failure {
  const UnexpectedFailure([super.message = 'Unexpected error occurred']);
}
