import 'package:dartz/dartz.dart';
import 'package:fenix/core/network/network_info.dart';
import 'package:fenix/features/favorites/data/datasources/favorites_local_data_source.dart';
import 'package:fenix/features/movies/data/datasources/movie_local_data_source.dart';
import 'package:fenix/features/movies/data/models/movie_model.dart';
import 'package:fenix/features/movies/domain/entities/movie.dart';
import 'package:fenix/features/movies/domain/usecases/get_top_rated_movies.dart';
import 'package:fenix/features/movies/domain/usecases/search_movies.dart';
import 'package:fenix/features/movies/presentation/bloc/movie_bloc.dart';
import 'package:fenix/features/movies/presentation/bloc/movie_event.dart';
import 'package:fenix/features/movies/presentation/bloc/movie_state.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'dart:async';

// Mocks
class MockGetTopRatedMovies extends Mock implements GetTopRatedMovies {}

class MockSearchMovies extends Mock implements SearchMovies {}

class MockNetworkInfo extends Mock implements NetworkInfo {}

class MockMovieLocalDataSource extends Mock implements MovieLocalDataSource {}

class MockFavoritesLocalDataSource extends Mock implements FavoritesLocalDataSource {}

void main() {
  late MovieBloc bloc;
  late MockGetTopRatedMovies mockGetTopRatedMovies;
  late MockSearchMovies mockSearchMovies;
  late MockNetworkInfo mockNetworkInfo;
  late MockMovieLocalDataSource mockLocalDataSource;
  late MockFavoritesLocalDataSource mockFavoritesLocalDataSource;
  late StreamController<bool> networkStreamController;

  // Test data
  final tMoviesList = [
    const Movie(
      id: 1,
      title: 'Test Movie 1',
      overview: 'Test Overview 1',
      posterPath: '/test1.jpg',

      voteAverage: 8.5,
      releaseDate: '2024-01-01',
    ),
    const Movie(
      id: 2,
      title: 'Test Movie 2',
      overview: 'Test Overview 2',
      posterPath: '/test2.jpg',

      voteAverage: 7.5,
      releaseDate: '2024-01-02',
    ),
  ];

  setUp(() {
    mockGetTopRatedMovies = MockGetTopRatedMovies();
    mockSearchMovies = MockSearchMovies();
    mockNetworkInfo = MockNetworkInfo();
    mockLocalDataSource = MockMovieLocalDataSource();
    mockFavoritesLocalDataSource = MockFavoritesLocalDataSource();
    networkStreamController = StreamController<bool>.broadcast();

    // Setup network stream mock
    when(() => mockNetworkInfo.connectionStream).thenAnswer(
      (_) => networkStreamController.stream,
    );

    // Default: online
    when(() => mockNetworkInfo.isConnected).thenAnswer((_) async => true);

    // Default favorites
    when(() => mockFavoritesLocalDataSource.getFavorites()).thenAnswer((_) async => <MovieModel>[]);
    when(() => mockFavoritesLocalDataSource.watchFavorites()).thenAnswer((_) => Stream.value(<MovieModel>[]));

    // Register fallback values for Mocktail
    registerFallbackValue(const GetTopRatedMoviesParams());
    registerFallbackValue(const SearchMoviesParams(query: ''));
  });

  tearDown(() async {
    await networkStreamController.close();
    await bloc.close();
  });

  group('Network Status Changes', () {
    test('should refresh data when switching from offline to online', () async {
      // Arrange - Start offline
      when(() => mockNetworkInfo.isConnected).thenAnswer((_) async => false);
      when(() => mockGetTopRatedMovies(any())).thenAnswer(
        (_) async => Right(tMoviesList),
      );

      bloc =
          MovieBloc(
              mockGetTopRatedMovies,
              mockSearchMovies,
              mockNetworkInfo,
              mockLocalDataSource,
              mockFavoritesLocalDataSource,
            )
            // Load initial data (offline, cache)
            ..add(const MovieEvent.getTopRatedMovies());
      await Future<void>.delayed(const Duration(milliseconds: 100));

      // Act - Switch to online
      when(() => mockNetworkInfo.isConnected).thenAnswer((_) async => true);
      networkStreamController.add(true);

      await Future<void>.delayed(const Duration(milliseconds: 200));

      // Assert - Should call getTopRatedMovies again
      verify(() => mockGetTopRatedMovies(any())).called(equals(1));
    });

    test('should set hasMore to false when offline', () async {
      // Arrange
      when(() => mockNetworkInfo.isConnected).thenAnswer((_) async => false);
      when(() => mockGetTopRatedMovies(any())).thenAnswer(
        (_) async => Right(tMoviesList),
      );

      bloc =
          MovieBloc(
              mockGetTopRatedMovies,
              mockSearchMovies,
              mockNetworkInfo,
              mockLocalDataSource,
              mockFavoritesLocalDataSource,
            )
            // Act
            ..add(const MovieEvent.getTopRatedMovies());
      await Future<void>.delayed(const Duration(milliseconds: 100));

      // Assert
      expect(
        bloc.state,
        isA<MovieLoaded>().having((s) => s.hasMore, 'hasMore', false).having((s) => s.movies.length, 'movies length', 2),
      );
    });

    test('should set hasMore to true when online and has 20+ movies', () async {
      // Arrange
      when(() => mockNetworkInfo.isConnected).thenAnswer((_) async => true);
      when(() => mockGetTopRatedMovies(any())).thenAnswer(
        (_) async => Right(
          List.generate(
            20,
            (i) => Movie(
              id: i,
              title: 'Movie $i',
              overview: 'Overview $i',
              posterPath: '/test$i.jpg',

              voteAverage: 8,
              releaseDate: '2024-01-01',
            ),
          ),
        ),
      );

      bloc =
          MovieBloc(
              mockGetTopRatedMovies,
              mockSearchMovies,
              mockNetworkInfo,
              mockLocalDataSource,
              mockFavoritesLocalDataSource,
            )
            // Act
            ..add(const MovieEvent.getTopRatedMovies());
      await Future<void>.delayed(const Duration(milliseconds: 100));

      // Assert
      expect(
        bloc.state,
        isA<MovieLoaded>().having((s) => s.hasMore, 'hasMore', true).having((s) => s.movies.length, 'movies length', 20),
      );
    });
  });

  group('LoadMoreMovies - Offline Behavior', () {
    test('should not load more when offline', () async {
      // Arrange
      when(() => mockNetworkInfo.isConnected).thenAnswer((_) async => false);
      when(() => mockGetTopRatedMovies(any())).thenAnswer(
        (_) async => Right(tMoviesList),
      );

      bloc =
          MovieBloc(
              mockGetTopRatedMovies,
              mockSearchMovies,
              mockNetworkInfo,
              mockLocalDataSource,
              mockFavoritesLocalDataSource,
            )
            // Load initial data
            ..add(const MovieEvent.getTopRatedMovies());
      await Future<void>.delayed(const Duration(milliseconds: 100));

      final initialState = bloc.state as MovieLoaded;

      // Act - Try to load more while offline
      bloc.add(const MovieEvent.loadMoreMovies());
      await Future<void>.delayed(const Duration(milliseconds: 100));

      // Assert - State should not change
      expect(bloc.state, equals(initialState));
      verify(() => mockGetTopRatedMovies(any())).called(1); // Only initial call
    });

    test('should load more when online', () async {
      // Arrange
      when(() => mockNetworkInfo.isConnected).thenAnswer((_) async => true);

      // First page: 20 movies
      when(() => mockGetTopRatedMovies(const GetTopRatedMoviesParams())).thenAnswer(
        (_) async => Right(
          List.generate(
            20,
            (i) => Movie(
              id: i,
              title: 'Movie $i',
              overview: 'Overview $i',
              posterPath: '/test$i.jpg',

              voteAverage: 8,
              releaseDate: '2024-01-01',
            ),
          ),
        ),
      );

      // Second page: 20 more movies
      when(() => mockGetTopRatedMovies(const GetTopRatedMoviesParams(page: 2))).thenAnswer(
        (_) async => Right(
          List.generate(
            20,
            (i) => Movie(
              id: i + 20,
              title: 'Movie ${i + 20}',
              overview: 'Overview ${i + 20}',
              posterPath: '/test${i + 20}.jpg',

              voteAverage: 8,
              releaseDate: '2024-01-01',
            ),
          ),
        ),
      );

      bloc =
          MovieBloc(
              mockGetTopRatedMovies,
              mockSearchMovies,
              mockNetworkInfo,
              mockLocalDataSource,
              mockFavoritesLocalDataSource,
            )
            // Load initial data
            ..add(const MovieEvent.getTopRatedMovies());
      await Future<void>.delayed(const Duration(milliseconds: 100));

      // Act - Load more
      bloc.add(const MovieEvent.loadMoreMovies());
      await Future<void>.delayed(const Duration(milliseconds: 100));

      // Assert
      expect(
        bloc.state,
        isA<MovieLoaded>().having((s) => s.movies.length, 'movies length', 40).having((s) => s.currentPage, 'currentPage', 2),
      );
      verify(() => mockGetTopRatedMovies(const GetTopRatedMoviesParams())).called(1);
      verify(() => mockGetTopRatedMovies(const GetTopRatedMoviesParams(page: 2))).called(1);
    });
  });
}
