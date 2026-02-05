import 'package:fenix/core/error/exceptions.dart';
import 'package:fenix/core/util/constants/hive_constants.dart';
import 'package:fenix/features/movies/data/models/movie_model.dart';
import 'package:flutter/foundation.dart';
import 'package:hive_ce/hive.dart';
import 'package:injectable/injectable.dart';

/// Local data source for movies using Hive.
abstract class MovieLocalDataSource {
  Future<List<MovieModel>> getCachedMovies();
  Future<void> cacheMovies(List<MovieModel> movies);
}

@LazySingleton(as: MovieLocalDataSource)
class MovieLocalDataSourceImpl implements MovieLocalDataSource {
  Box<MovieModel>? _box;

  Future<void> _ensureBoxOpen() async {
    if (_box == null || !_box!.isOpen) {
      _box = await Hive.openBox<MovieModel>(HiveConstants.moviesBox);
      debugPrint('📦 Hive box opened: ${_box!.length} movies in cache');
    }
  }

  @override
  Future<List<MovieModel>> getCachedMovies() async {
    try {
      await _ensureBoxOpen();

      if (_box!.isEmpty) {
        debugPrint('❌ Cache is empty - no movies found');
        throw const CacheException();
      }

      final movies = _box!.values.toList();
      debugPrint('📖 Loaded ${movies.length} movies from cache');
      return movies;
    } catch (e) {
      debugPrint('❌ Cache read error: $e');
      if (e is CacheException) rethrow;
      throw CacheException('Failed to read cache: $e');
    }
  }

  @override
  Future<void> cacheMovies(List<MovieModel> movies) async {
    try {
      await _ensureBoxOpen();
      await _box!.clear();
      await _box!.addAll(movies);
      debugPrint('💾 Cached ${movies.length} movies to local storage');
    } catch (e) {
      debugPrint('❌ Cache write error: $e');
      throw CacheException('Failed to write cache: $e');
    }
  }
}
