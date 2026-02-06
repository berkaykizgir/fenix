import 'package:dartz/dartz.dart';
import 'package:fenix/core/error/failures.dart';

/// Base class for use cases returning `Either<Failure, T>`.
/// [Params] is the input type, [T] is the output type.
abstract class UseCase<T, Params> {
  Future<Either<Failure, T>> call(Params params);
}
