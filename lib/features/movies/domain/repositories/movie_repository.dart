import 'package:dartz/dartz.dart';
import 'package:fenix/core/error/failures.dart';
import 'package:fenix/features/movies/domain/entities/movie.dart';

/// Repository interface for movie operations.
abstract class MovieRepository {
  /// Fetches top rated movies with pagination.
  Future<Either<Failure, List<Movie>>> getTopRatedMovies({int page = 1});

  /// Searches movies by query with pagination.
  Future<Either<Failure, List<Movie>>> searchMovies(String query, {int page = 1});
}
