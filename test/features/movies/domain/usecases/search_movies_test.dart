import 'package:dartz/dartz.dart';
import 'package:fenix/core/error/failures.dart';
import 'package:fenix/features/movies/domain/entities/movie.dart';
import 'package:fenix/features/movies/domain/repositories/movie_repository.dart';
import 'package:fenix/features/movies/domain/usecases/search_movies.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class MockMovieRepository extends Mock implements MovieRepository {}

void main() {
  late SearchMovies useCase;
  late MockMovieRepository mockRepository;

  setUp(() {
    mockRepository = MockMovieRepository();
    useCase = SearchMovies(mockRepository);
  });

  const tQuery = 'Inception';
  const tMovies = [
    Movie(
      id: 1,
      title: 'Inception',
      overview: 'A mind-bending thriller',
      posterPath: '/inception.jpg',
      voteAverage: 8.8,
      releaseDate: '2010-07-16',
    ),
  ];

  test('should search movies from repository with query', () async {
    // Arrange
    when(() => mockRepository.searchMovies(any())).thenAnswer((_) async => const Right(tMovies));

    // Act
    final result = await useCase(const SearchMoviesParams(query: tQuery));

    // Assert
    expect(result, const Right<Failure, List<Movie>>(tMovies));
    verify(() => mockRepository.searchMovies(tQuery)).called(1);
    verifyNoMoreInteractions(mockRepository);
  });

  test('should return failure when repository fails', () async {
    // Arrange
    const tFailure = NetworkFailure();
    when(() => mockRepository.searchMovies(any())).thenAnswer((_) async => const Left(tFailure));

    // Act
    final result = await useCase(const SearchMoviesParams(query: tQuery));

    // Assert
    expect(result, const Left<Failure, List<Movie>>(tFailure));
    verify(() => mockRepository.searchMovies(tQuery)).called(1);
    verifyNoMoreInteractions(mockRepository);
  });
}
