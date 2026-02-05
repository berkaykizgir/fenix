import 'package:dartz/dartz.dart';
import 'package:fenix/core/error/failures.dart';
import 'package:fenix/features/movies/domain/entities/movie.dart';
import 'package:fenix/features/movies/domain/repositories/movie_repository.dart';
import 'package:fenix/features/movies/domain/usecases/get_top_rated_movies.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class MockMovieRepository extends Mock implements MovieRepository {}

void main() {
  late GetTopRatedMovies useCase;
  late MockMovieRepository mockRepository;

  setUp(() {
    mockRepository = MockMovieRepository();
    useCase = GetTopRatedMovies(mockRepository);
  });

  const tMovies = [
    Movie(
      id: 1,
      title: 'Test Movie',
      overview: 'Test Overview',
      posterPath: '/test.jpg',
      voteAverage: 8.5,
      releaseDate: '2024-01-01',
    ),
  ];

  test('should get top rated movies from repository', () async {
    // Arrange
    when(() => mockRepository.getTopRatedMovies()).thenAnswer((_) async => const Right(tMovies));

    // Act
    final result = await useCase(const GetTopRatedMoviesParams());

    // Assert
    expect(result, const Right<Failure, List<Movie>>(tMovies));
    verify(() => mockRepository.getTopRatedMovies()).called(1);
    verifyNoMoreInteractions(mockRepository);
  });

  test('should return failure when repository fails', () async {
    // Arrange
    const tFailure = ServerFailure('Server error');
    when(() => mockRepository.getTopRatedMovies()).thenAnswer((_) async => const Left(tFailure));

    // Act
    final result = await useCase(const GetTopRatedMoviesParams());

    // Assert
    expect(result, const Left<Failure, List<Movie>>(tFailure));
    verify(() => mockRepository.getTopRatedMovies()).called(1);
    verifyNoMoreInteractions(mockRepository);
  });
}
