import 'dart:async';
import 'package:fenix/features/favorites/data/datasources/favorites_local_data_source.dart';
import 'package:fenix/features/movies/data/models/movie_model.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';

import '../../../../core/error/exceptions.dart';
import '../../../../core/network/network_info.dart';
import '../../data/datasources/movie_local_data_source.dart';
import '../../domain/usecases/get_top_rated_movies.dart';
import '../../domain/usecases/search_movies.dart';
import '../bloc/movie_event.dart';
import '../bloc/movie_state.dart';

@singleton
class MovieBloc extends Bloc<MovieEvent, MovieState> {
  MovieBloc(
    this._getTopRatedMovies,
    this._searchMovies,
    this._networkInfo,
    this._localDataSource,
    this._favoritesDataSource,
  ) : super(const MovieState.initial()) {
    on<GetTopRatedMoviesEvent>(_onGetTopRatedMovies);
    on<LoadMoreMoviesEvent>(_onLoadMoreMovies);
    on<SearchMoviesEvent>(_onSearchMovies);
    on<LoadMoreSearchResultsEvent>(_onLoadMoreSearchResults);
    on<NetworkStatusChangedEvent>(_onConnectionChanged);
    on<UpdateMovieFavoriteStatusEvent>(_onUpdateMovieFavoriteStatus);

    _networkSubscription = _networkInfo.connectionStream.listen(
      (isConnected) => add(MovieEvent.networkStatusChanged(isOnline: isConnected)),
    );
  }

  final GetTopRatedMovies _getTopRatedMovies;
  final SearchMovies _searchMovies;
  final NetworkInfo _networkInfo;
  final MovieLocalDataSource _localDataSource;
  final FavoritesLocalDataSource _favoritesDataSource;

  /// Stores the latest search query to restore state after connectivity changes.
  String? _currentSearchQuery;

  late final StreamSubscription<bool> _networkSubscription;
  bool _isFirstConnectionEvent = true;

  Future<void> _onConnectionChanged(
    NetworkStatusChangedEvent event,
    Emitter<MovieState> emit,
  ) async {
    if (_isFirstConnectionEvent) {
      _isFirstConnectionEvent = false;
      return;
    }

    final currentState = state;

    // OFFLINE
    if (!event.isOnline) {
      try {
        final cachedMovies = await _localDataSource.getCachedMovies();
        final entities = cachedMovies.map((m) => m.toEntity()).toList();

        if (_currentSearchQuery?.trim().isNotEmpty ?? false) {
          final query = _currentSearchQuery!.toLowerCase();
          final filtered = entities.where((movie) {
            return movie.title.toLowerCase().contains(query) || movie.overview.toLowerCase().contains(query);
          }).toList();

          emit(MovieState.loaded(movies: filtered, hasMore: false, isOffline: true));
          return;
        }

        emit(MovieState.loaded(movies: entities, hasMore: false, isOffline: true));
      } on CacheException {
        if (currentState is MovieLoaded) {
          emit(currentState.copyWith(isOffline: true, hasMore: false));
        } else {
          emit(const MovieState.error('No internet connection and cache is empty'));
        }
      }
      return;
    }

    // ONLINE → restore previous context
    if (currentState is MovieLoaded && currentState.isOffline) {
      if (_currentSearchQuery?.trim().isNotEmpty ?? false) {
        add(MovieEvent.searchMovies(_currentSearchQuery!));
      } else {
        add(const MovieEvent.getTopRatedMovies());
      }
    }
  }

  // ---------------------------------------------------------------------------
  // Initial load
  // ---------------------------------------------------------------------------

  /// Fetches the first page of top-rated movies.
  /// Falls back to offline flag if there is no internet connection.
  Future<void> _onGetTopRatedMovies(
    GetTopRatedMoviesEvent event,
    Emitter<MovieState> emit,
  ) async {
    emit(const MovieState.loading());

    final result = await _getTopRatedMovies(const GetTopRatedMoviesParams());
    final isOnline = await _networkInfo.isConnected;
    final favoriteMovies = await _favoritesDataSource.getFavorites();

    result.fold(
      (failure) => emit(MovieState.error(failure.message)),
      (movies) {
        // ⬅️ EKLE: Initial load'da da mark et
        final favoriteIds = favoriteMovies.map((m) => m.id).toSet();
        final markedMovies = movies.map((movie) {
          return movie.copyWith(isFavorite: favoriteIds.contains(movie.id));
        }).toList();
        debugPrint('⭐ Initial load: Marked ${markedMovies.length} movies with favorites');
        emit(
          MovieState.loaded(
            movies: markedMovies,
            hasMore: isOnline && markedMovies.length >= 20,
            isOffline: !isOnline,
          ),
        );
      },
    );
  }
  // ---------------------------------------------------------------------------
  // Search
  // ---------------------------------------------------------------------------

  /// Executes movie search.
  ///
  /// - Online → queries remote source
  /// - Offline → searches within cached data
  Future<void> _onSearchMovies(
    SearchMoviesEvent event,
    Emitter<MovieState> emit,
  ) async {
    emit(const MovieState.loading());
    _currentSearchQuery = event.query;

    final isOnline = await _networkInfo.isConnected;

    if (isOnline) {
      final result = await _searchMovies(SearchMoviesParams(query: event.query));
      final favoriteMovies = await _favoritesDataSource.getFavorites();
      result.fold(
        (failure) => emit(MovieState.error(failure.message)),
        (movies) async {
          // ⬅️ EKLE: Favorite flag'lerini mark et

          final favoriteIds = favoriteMovies.map((m) => m.id).toSet();

          final markedMovies = movies.map((movie) {
            return movie.copyWith(isFavorite: favoriteIds.contains(movie.id));
          }).toList();

          debugPrint('🔍 Search: Marked ${markedMovies.length} movies with favorites');

          emit(MovieState.loaded(movies: markedMovies, hasMore: markedMovies.length >= 20));
        },
      );
      return;
    }

    try {
      final cachedMovies = await _localDataSource.getCachedMovies();
      final entities = cachedMovies.map((m) => m.toEntity()).toList();

      final query = event.query.toLowerCase();
      final filtered = entities.where((movie) {
        return movie.title.toLowerCase().contains(query) || movie.overview.toLowerCase().contains(query);
      }).toList();

      // ⬅️ EKLE: Offline search'te de mark et
      final favoriteMovies = await _favoritesDataSource.getFavorites();
      final favoriteIds = favoriteMovies.map((m) => m.id).toSet();

      final markedFiltered = filtered.map((movie) {
        return movie.copyWith(isFavorite: favoriteIds.contains(movie.id));
      }).toList();

      emit(MovieState.loaded(movies: markedFiltered, hasMore: false, isOffline: true));
    } on CacheException catch (e) {
      emit(MovieState.error(e.message));
    }
  } // ---------------------------------------------------------------------------
  // Pagination – Top rated
  // ---------------------------------------------------------------------------

  /// Loads the next page of top-rated movies if:
  /// - current state is loaded
  /// - pagination is available
  /// - device is online
  Future<void> _onLoadMoreMovies(
    LoadMoreMoviesEvent event,
    Emitter<MovieState> emit,
  ) async {
    final currentState = state;

    if (currentState is! MovieLoaded) return;
    if (!currentState.hasMore || currentState.isOffline) return;
    if (!(await _networkInfo.isConnected)) return;

    if (currentState.movies.length >= 60) {
      emit(MovieState.premiumRequired(movies: currentState.movies, currentPage: currentState.currentPage));
      return;
    }

    final nextPage = currentState.currentPage + 1;

    emit(MovieState.loadingMore(movies: currentState.movies, currentPage: currentState.currentPage));

    final result = await _getTopRatedMovies(GetTopRatedMoviesParams(page: nextPage));
    final favoriteMovies = await _favoritesDataSource.getFavorites();
    result.fold(
      (_) => emit(
        MovieState.loaded(
          movies: currentState.movies,
          currentPage: currentState.currentPage,
          hasMore: false,
        ),
      ),
      (newMovies) {
        // ⬅️ EKLE: Pagination'da da mark et

        final favoriteIds = favoriteMovies.map((m) => m.id).toSet();

        final markedNewMovies = newMovies.map((movie) {
          return movie.copyWith(isFavorite: favoriteIds.contains(movie.id));
        }).toList();

        emit(
          MovieState.loaded(
            movies: [...currentState.movies, ...markedNewMovies],
            currentPage: nextPage,
            hasMore: markedNewMovies.length >= 20,
          ),
        );
      },
    );
  }
  // ---------------------------------------------------------------------------
  // Pagination – Search
  // ---------------------------------------------------------------------------

  /// Loads the next page of search results under the same constraints as top-rated pagination.
  Future<void> _onLoadMoreSearchResults(
    LoadMoreSearchResultsEvent event,
    Emitter<MovieState> emit,
  ) async {
    final currentState = state;

    if (currentState is! MovieLoaded) return;
    if (!currentState.hasMore || currentState.isOffline) return;
    if (!(await _networkInfo.isConnected)) return;

    if (currentState.movies.length >= 60) {
      emit(MovieState.premiumRequired(movies: currentState.movies, currentPage: currentState.currentPage));
      return;
    }

    final nextPage = currentState.currentPage + 1;

    emit(MovieState.loadingMore(movies: currentState.movies, currentPage: currentState.currentPage));

    final result = await _searchMovies(SearchMoviesParams(query: event.query, page: nextPage));
    final favoriteMovies = await _favoritesDataSource.getFavorites();
    result.fold(
      (_) => emit(
        MovieState.loaded(
          movies: currentState.movies,
          currentPage: currentState.currentPage,
          hasMore: false,
        ),
      ),
      (newMovies) {
        final favoriteIds = favoriteMovies.map((m) => m.id).toSet();
        final markedNewMovies = newMovies.map((movie) {
          return movie.copyWith(isFavorite: favoriteIds.contains(movie.id));
        }).toList();

        emit(
          MovieState.loaded(
            movies: [...currentState.movies, ...markedNewMovies],
            currentPage: nextPage,
            hasMore: markedNewMovies.length >= 20,
          ),
        );
      },
    );
  }
  // ---------------------------------------------------------------------------
  // Dispose
  // ---------------------------------------------------------------------------

  @override
  Future<void> close() async {
    await _networkSubscription.cancel();
    return super.close();
  }

  Future<void> _onUpdateMovieFavoriteStatus(
    UpdateMovieFavoriteStatusEvent event,
    Emitter<MovieState> emit,
  ) async {
    final currentState = state;
    debugPrint('🔄 Updating favorite status for movie ${event.movieId} to ${event.isFavorite}');
    // Only update if in loaded state
    if (currentState is! MovieLoaded) return;

    // Update the specific movie's favorite status
    final updatedMovies = currentState.movies.map((movie) {
      if (movie.id == event.movieId) {
        return movie.copyWith(isFavorite: event.isFavorite);
      }
      return movie;
    }).toList();

    debugPrint('🔄 Updated movie ${event.movieId} favorite status: ${event.isFavorite}');

    emit(MovieState.loaded(movies: updatedMovies, hasMore: currentState.hasMore, currentPage: currentState.currentPage, isOffline: currentState.isOffline));
  }
}
