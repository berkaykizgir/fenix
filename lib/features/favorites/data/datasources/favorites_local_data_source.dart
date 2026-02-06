import 'package:fenix/core/error/exceptions.dart';
import 'package:fenix/core/util/constants/hive_constants.dart';
import 'package:fenix/features/movies/data/models/movie_model.dart';
import 'package:flutter/foundation.dart';
import 'package:hive_ce/hive.dart';
import 'package:injectable/injectable.dart';

/// Local data source for favorite movies using Hive.
abstract class FavoritesLocalDataSource {
  Future<List<MovieModel>> getFavorites();
  Future<void> addFavorite(MovieModel movie);
  Future<void> removeFavorite(int movieId);
  Future<bool> isFavorite(int movieId);

  Stream<List<MovieModel>> watchFavorites();
}

@LazySingleton(as: FavoritesLocalDataSource)
class FavoritesLocalDataSourceImpl implements FavoritesLocalDataSource {
  Box<MovieModel>? _box;

  Future<void> _ensureBoxOpen() async {
    if (_box == null || !_box!.isOpen) {
      _box = await Hive.openBox<MovieModel>(HiveConstants.favoritesBox);
      debugPrint('⭐ Favorites box opened: ${_box!.length} favorites');
    }
  }

  @override
  Future<List<MovieModel>> getFavorites() async {
    try {
      await _ensureBoxOpen();
      final favorites = _box!.values.toList();
      debugPrint('⭐ Loaded ${favorites.length} favorite movies');
      return favorites;
    } catch (e) {
      debugPrint('❌ Failed to get favorites: $e');
      throw CacheException('Failed to get favorites: $e');
    }
  }

  @override
  Future<void> addFavorite(MovieModel movie) async {
    try {
      await _ensureBoxOpen();

      // Check if already exists
      final exists = _box!.values.any((m) => m.id == movie.id);

      if (!exists) {
        await _box!.add(movie);
        debugPrint('⭐ Added favorite: ${movie.title} (total: ${_box!.length})');
      } else {
        debugPrint('⭐ Already favorite: ${movie.title}');
      }
    } catch (e) {
      debugPrint('❌ Failed to add favorite: $e');
      throw CacheException('Failed to add favorite: $e');
    }
  }

  @override
  Future<void> removeFavorite(int movieId) async {
    try {
      await _ensureBoxOpen();

      final key = _box!.keys.firstWhere(
        (k) {
          final movie = _box!.get(k);
          return movie?.id == movieId;
        },
        orElse: () => null,
      );

      if (key != null) {
        final movie = _box!.get(key);
        await _box!.delete(key);
        debugPrint('⭐ Removed favorite: ${movie?.title} (total: ${_box!.length})');
      } else {
        debugPrint('⭐ Not in favorites: $movieId');
      }
    } catch (e) {
      debugPrint('❌ Failed to remove favorite: $e');
      throw CacheException('Failed to remove favorite: $e');
    }
  }

  @override
  Future<bool> isFavorite(int movieId) async {
    try {
      await _ensureBoxOpen();
      return _box!.values.any((movie) => movie.id == movieId);
    } catch (e) {
      debugPrint('❌ Failed to check favorite: $e');
      return false;
    }
  }

  @override
  Stream<List<MovieModel>> watchFavorites() async* {
    yield await getFavorites(); // initial
    await _ensureBoxOpen();
    yield* _box!.watch().asyncMap((_) async {
      return getFavorites();
    });
  }
}
