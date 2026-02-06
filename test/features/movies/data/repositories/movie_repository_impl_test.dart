import 'package:dartz/dartz.dart';
import 'package:fenix/core/error/exceptions.dart';
import 'package:fenix/core/error/failures.dart';
import 'package:fenix/core/network/network_info.dart';
import 'package:fenix/features/favorites/data/datasources/favorites_local_data_source.dart';
import 'package:fenix/features/movies/data/datasources/movie_local_data_source.dart';
import 'package:fenix/features/movies/data/datasources/movie_remote_data_source.dart';
import 'package:fenix/features/movies/data/models/movie_model.dart';
import 'package:fenix/features/movies/data/repositories/movie_repository_impl.dart';
import 'package:fenix/features/movies/domain/entities/movie.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class MockMovieRemoteDataSource extends Mock implements MovieRemoteDataSource {}

class MockMovieLocalDataSource extends Mock implements MovieLocalDataSource {}

class MockNetworkInfo extends Mock implements NetworkInfo {}

class MockFavoritesLocalDataSource extends Mock implements FavoritesLocalDataSource {}

void main() {
  late MovieRepositoryImpl repository;
  late MockMovieRemoteDataSource mockRemoteDataSource;
  late MockMovieLocalDataSource mockLocalDataSource;
  late MockNetworkInfo mockNetworkInfo;
  late MockFavoritesLocalDataSource mockFavoritesLocalDataSource;

  setUp(() {
    mockRemoteDataSource = MockMovieRemoteDataSource();
    mockLocalDataSource = MockMovieLocalDataSource();
    mockNetworkInfo = MockNetworkInfo();
    mockFavoritesLocalDataSource = MockFavoritesLocalDataSource();
    repository = MovieRepositoryImpl(
      mockRemoteDataSource,
      mockLocalDataSource,
      mockNetworkInfo,
      mockFavoritesLocalDataSource,
    );

    // Default favorites stub
    when(() => mockFavoritesLocalDataSource.getFavorites()).thenAnswer((_) async => []);
  });

  const tMovieModels = [
    MovieModel(
      id: 1,
      title: 'Test Movie',
      overview: 'Test Overview',
      posterPath: '/test.jpg',
      voteAverage: 8.5,
      releaseDate: '2024-01-01',
    ),
  ];

  final tMovies = tMovieModels.map((model) => model.toEntity()).toList();

  group('getTopRatedMovies', () {
    test('should check if device is online', () async {
      // Arrange
      when(() => mockNetworkInfo.isConnected).thenAnswer((_) async => true);
      when(() => mockRemoteDataSource.getTopRatedMovies()).thenAnswer((_) async => tMovieModels);
      when(() => mockLocalDataSource.cacheMovies(any())).thenAnswer((_) async => {});

      // Act
      await repository.getTopRatedMovies();

      // Assert
      verify(() => mockNetworkInfo.isConnected).called(1);
    });

    group('device is online', () {
      setUp(() {
        when(() => mockNetworkInfo.isConnected).thenAnswer((_) async => true);
      });

      test('should return movies when remote call is successful', () async {
        // Arrange
        when(() => mockRemoteDataSource.getTopRatedMovies()).thenAnswer((_) async => tMovieModels);
        when(() => mockLocalDataSource.cacheMovies(any())).thenAnswer((_) async => {});

        // Act
        final result = await repository.getTopRatedMovies();

        // Assert
        verify(() => mockRemoteDataSource.getTopRatedMovies()).called(1);
        verify(() => mockLocalDataSource.cacheMovies(tMovieModels)).called(1);

        result.fold(
          (failure) => fail('Expected Right but got Left'),
          (movies) {
            expect(movies.length, tMovies.length);
            expect(movies.first.id, tMovies.first.id);
            expect(movies.first.title, tMovies.first.title);
          },
        );
      });

      test('should cache movies when remote call is successful', () async {
        // Arrange
        when(() => mockRemoteDataSource.getTopRatedMovies()).thenAnswer((_) async => tMovieModels);
        when(() => mockLocalDataSource.cacheMovies(any())).thenAnswer((_) async => {});

        // Act
        await repository.getTopRatedMovies();

        // Assert
        verify(() => mockRemoteDataSource.getTopRatedMovies()).called(1);
        verify(() => mockLocalDataSource.cacheMovies(tMovieModels)).called(1);
      });

      test('should return ServerFailure when remote call fails', () async {
        // Arrange
        when(() => mockRemoteDataSource.getTopRatedMovies()).thenThrow(const ServerException('Server error'));

        // Act
        final result = await repository.getTopRatedMovies();

        // Assert
        verify(() => mockRemoteDataSource.getTopRatedMovies()).called(1);
        verifyZeroInteractions(mockLocalDataSource);
        expect(
          result,
          const Left<Failure, List<Movie>>(ServerFailure('Server error')),
        );
      });
    });

    group('device is offline', () {
      setUp(() {
        when(() => mockNetworkInfo.isConnected).thenAnswer((_) async => false);
      });

      test('should return cached movies when cache is available', () async {
        // Arrange
        when(() => mockLocalDataSource.getCachedMovies()).thenAnswer((_) async => tMovieModels);

        // Act
        final result = await repository.getTopRatedMovies();

        // Assert
        verify(() => mockNetworkInfo.isConnected).called(1);
        verifyZeroInteractions(mockRemoteDataSource);
        verify(() => mockLocalDataSource.getCachedMovies()).called(1);

        result.fold(
          (failure) => fail('Expected Right but got Left'),
          (movies) {
            expect(movies.length, tMovies.length);
            expect(movies.first.id, tMovies.first.id);
            expect(movies.first.title, tMovies.first.title);
          },
        );
      });

      test('should return CacheFailure when cache is empty', () async {
        // Arrange
        when(() => mockLocalDataSource.getCachedMovies()).thenThrow(const CacheException('No cached movies found'));

        // Act
        final result = await repository.getTopRatedMovies();

        // Assert
        verify(() => mockNetworkInfo.isConnected).called(1);
        verifyZeroInteractions(mockRemoteDataSource);
        verify(() => mockLocalDataSource.getCachedMovies()).called(1);
        expect(
          result,
          const Left<Failure, List<Movie>>(
            CacheFailure('No cached movies found'),
          ),
        );
      });
    });
  });

  group('searchMovies', () {
    const tQuery = 'Inception';

    test('should return NetworkFailure when device is offline', () async {
      // Arrange
      when(() => mockNetworkInfo.isConnected).thenAnswer((_) async => false);

      // Act
      final result = await repository.searchMovies(tQuery);

      // Assert
      verifyZeroInteractions(mockRemoteDataSource);
      expect(
        result,
        const Left<Failure, List<Movie>>(
          NetworkFailure('Search requires internet connection'),
        ),
      );
    });

    test('should return movies when device is online and call succeeds', () async {
      // Arrange
      when(() => mockNetworkInfo.isConnected).thenAnswer((_) async => true);
      when(() => mockRemoteDataSource.searchMovies(any())).thenAnswer((_) async => tMovieModels);

      // Act
      final result = await repository.searchMovies(tQuery);

      // Assert
      verify(() => mockRemoteDataSource.searchMovies(tQuery)).called(1);

      result.fold(
        (failure) => fail('Expected Right but got Left'),
        (movies) {
          expect(movies.length, tMovies.length);
          expect(movies.first.id, tMovies.first.id);
          expect(movies.first.title, tMovies.first.title);
        },
      );
    });

    test('should return ServerFailure when remote call fails', () async {
      // Arrange
      when(() => mockNetworkInfo.isConnected).thenAnswer((_) async => true);
      when(() => mockRemoteDataSource.searchMovies(any())).thenThrow(const ServerException('Server error'));

      // Act
      final result = await repository.searchMovies(tQuery);

      // Assert
      expect(
        result,
        const Left<Failure, List<Movie>>(ServerFailure('Server error')),
      );
    });
  });
}
