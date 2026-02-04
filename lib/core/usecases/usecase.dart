import 'package:dartz/dartz.dart';
import 'package:fenix/core/error/failures.dart';

/// Base class for all use cases.
///
/// Every use case must return `Either<Failure, Data>`.
/// [Params] is the input type, [T] is the return type.
abstract class UseCase<T, Params> {
  Future<Either<Failure, T>> call(Params params);
}
