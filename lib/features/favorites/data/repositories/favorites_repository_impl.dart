import 'package:dartz/dartz.dart';
import 'package:fenix/core/error/exceptions.dart';
import 'package:fenix/core/error/failures.dart';
import 'package:fenix/features/favorites/data/datasources/favorites_local_data_source.dart';
import 'package:fenix/features/favorites/domain/repositories/favorites_repository.dart';
import 'package:fenix/features/movies/domain/entities/movie.dart';
import 'package:flutter/foundation.dart';
import 'package:injectable/injectable.dart';

import '../../../movies/data/models/movie_model.dart';

@LazySingleton(as: FavoritesRepository)
class FavoritesRepositoryImpl implements FavoritesRepository {
  FavoritesRepositoryImpl(this._localDataSource);

  final FavoritesLocalDataSource _localDataSource;

  @override
  Future<Either<Failure, List<Movie>>> getFavorites() async {
    try {
      final favoriteModels = await _localDataSource.getFavorites();
      final favorites = favoriteModels.map((model) => model.toEntity().copyWith(isFavorite: true)).toList();

      debugPrint('✅ Retrieved ${favorites.length} favorites');
      return Right(favorites);
    } on CacheException catch (e) {
      debugPrint('❌ Failed to get favorites: ${e.message}');
      return Left(CacheFailure(e.message));
    } catch (e) {
      debugPrint('❌ Unexpected error: $e');
      return Left(UnexpectedFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> addFavorite(Movie movie) async {
    try {
      // Convert entity to model (we need all fields from Movie)
      final model = _movieToModel(movie);
      await _localDataSource.addFavorite(model);

      debugPrint('✅ Added ${movie.title} to favorites');
      return const Right(null);
    } on CacheException catch (e) {
      debugPrint('❌ Failed to add favorite: ${e.message}');
      return Left(CacheFailure(e.message));
    } catch (e) {
      debugPrint('❌ Unexpected error: $e');
      return Left(UnexpectedFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> removeFavorite(int movieId) async {
    try {
      await _localDataSource.removeFavorite(movieId);

      debugPrint('✅ Removed movie $movieId from favorites');
      return const Right(null);
    } on CacheException catch (e) {
      debugPrint('❌ Failed to remove favorite: ${e.message}');
      return Left(CacheFailure(e.message));
    } catch (e) {
      debugPrint('❌ Unexpected error: $e');
      return Left(UnexpectedFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, bool>> isFavorite(int movieId) async {
    try {
      final result = await _localDataSource.isFavorite(movieId);
      return Right(result);
    } on CacheException catch (e) {
      debugPrint('❌ Failed to check favorite: ${e.message}');
      return Left(CacheFailure(e.message));
    } catch (e) {
      debugPrint('❌ Unexpected error: $e');
      return Left(UnexpectedFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, bool>> toggleFavorite(Movie movie) async {
    try {
      final isFav = await _localDataSource.isFavorite(movie.id);

      if (isFav) {
        await _localDataSource.removeFavorite(movie.id);
        debugPrint('⭐ Toggled OFF: ${movie.title}');
        return const Right(false);
      } else {
        final model = _movieToModel(movie);
        await _localDataSource.addFavorite(model);
        debugPrint('⭐ Toggled ON: ${movie.title}');
        return const Right(true);
      }
    } on CacheException catch (e) {
      debugPrint('❌ Failed to toggle favorite: ${e.message}');
      return Left(CacheFailure(e.message));
    } catch (e) {
      debugPrint('❌ Unexpected error: $e');
      return Left(UnexpectedFailure(e.toString()));
    }
  }

  // Helper to convert Movie entity to MovieModel
  MovieModel _movieToModel(Movie movie) {
    return MovieModel(
      id: movie.id,
      title: movie.title,
      overview: movie.overview,
      voteAverage: movie.voteAverage,
      releaseDate: movie.releaseDate,
      posterPath: movie.posterPath,
    );
  }
}
