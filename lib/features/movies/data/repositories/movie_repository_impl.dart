import 'package:dartz/dartz.dart';
import 'package:fenix/core/error/exceptions.dart';
import 'package:fenix/core/error/failures.dart';
import 'package:fenix/core/network/network_info.dart';
import 'package:fenix/features/movies/data/datasources/movie_local_data_source.dart';
import 'package:fenix/features/movies/data/datasources/movie_remote_data_source.dart';
import 'package:fenix/features/movies/domain/entities/movie.dart';
import 'package:fenix/features/movies/domain/repositories/movie_repository.dart';
import 'package:flutter/foundation.dart';
import 'package:injectable/injectable.dart';

import '../models/movie_model.dart';

@LazySingleton(as: MovieRepository)
class MovieRepositoryImpl implements MovieRepository {
  MovieRepositoryImpl(
    this._remoteDataSource,
    this._localDataSource,
    this._networkInfo,
  );

  final MovieRemoteDataSource _remoteDataSource;
  final MovieLocalDataSource _localDataSource;
  final NetworkInfo _networkInfo;

  @override
  Future<Either<Failure, List<Movie>>> getTopRatedMovies({int page = 1}) async {
    if (await _networkInfo.isConnected) {
      debugPrint('🌐 Device is online - fetching page $page from API');
      try {
        final movieModels = await _remoteDataSource.getTopRatedMovies(page: page);

        // Only cache first page
        if (page == 1) {
          await _localDataSource.cacheMovies(movieModels);
          debugPrint('💾 Cached ${movieModels.length} movies from page $page');
        }

        final movies = movieModels.map((model) => model.toEntity()).toList();
        return Right(movies);
      } on ServerException catch (e) {
        debugPrint('❌ Server error: ${e.message}');
        return Left(ServerFailure(e.message));
      } on NetworkException catch (e) {
        debugPrint('❌ Network error: ${e.message}');
        return Left(NetworkFailure(e.message));
      } on Exception catch (e) {
        debugPrint('❌ Unexpected error: $e');
        return Left(UnexpectedFailure(e.toString()));
      }
    } else {
      debugPrint('📴 Device is offline - loading from cache');
      try {
        final cachedMovies = await _localDataSource.getCachedMovies();
        debugPrint('📦 Cache contains ${cachedMovies.length} movies');
        final movies = cachedMovies.map((model) => model.toEntity()).toList();
        debugPrint('✅ Successfully loaded ${movies.length} movies from cache');
        return Right(movies);
      } on CacheException catch (e) {
        debugPrint('❌ Cache error: ${e.message}');
        return Left(CacheFailure(e.message));
      } on Exception catch (e) {
        debugPrint('❌ Unexpected error: $e');
        return Left(UnexpectedFailure(e.toString()));
      }
    }
  }

  @override
  Future<Either<Failure, List<Movie>>> searchMovies(
    String query, {
    int page = 1,
  }) async {
    if (!await _networkInfo.isConnected) {
      debugPrint('📴 Search requires internet - device is offline');
      return const Left(NetworkFailure('Search requires internet connection'));
    }

    debugPrint('🔍 Searching movies with query: "$query" (page: $page)');
    try {
      final movieModels = await _remoteDataSource.searchMovies(query, page: page);
      final movies = movieModels.map((model) => model.toEntity()).toList();
      debugPrint('✅ Found ${movies.length} movies for "$query"');
      return Right(movies);
    } on ServerException catch (e) {
      debugPrint('❌ Server error: ${e.message}');
      return Left(ServerFailure(e.message));
    } on NetworkException catch (e) {
      debugPrint('❌ Network error: ${e.message}');
      return Left(NetworkFailure(e.message));
    } on Exception catch (e) {
      debugPrint('❌ Unexpected error: $e');
      return Left(UnexpectedFailure(e.toString()));
    }
  }
}
