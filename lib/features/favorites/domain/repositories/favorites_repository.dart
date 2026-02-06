import 'package:dartz/dartz.dart';
import 'package:fenix/core/error/failures.dart';
import 'package:fenix/features/movies/domain/entities/movie.dart';

/// Repository interface for favorites operations.
abstract class FavoritesRepository {
  /// Get all favorite movies.
  Future<Either<Failure, List<Movie>>> getFavorites();

  /// Add a movie to favorites.
  Future<Either<Failure, void>> addFavorite(Movie movie);

  /// Remove a movie from favorites.
  Future<Either<Failure, void>> removeFavorite(int movieId);

  /// Check if a movie is favorited.
  Future<Either<Failure, bool>> isFavorite(int movieId);

  /// Toggle favorite status.
  Future<Either<Failure, bool>> toggleFavorite(Movie movie);
}
