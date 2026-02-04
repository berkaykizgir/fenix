/// Empty params class for use cases that don't need parameters.
///
/// Example:
/// ```dart
/// class GetMovies extends UseCase<List<Movie>, NoParams> {
///   @override
///   Future<Either<Failure, List<Movie>>> call(NoParams params) {
///     // ...
///   }
/// }
/// ```
class NoParams {
  const NoParams();
}
