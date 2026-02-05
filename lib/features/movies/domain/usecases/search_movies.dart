import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:fenix/core/error/failures.dart';
import 'package:fenix/core/usecases/usecase.dart';
import 'package:fenix/features/movies/domain/entities/movie.dart';
import 'package:fenix/features/movies/domain/repositories/movie_repository.dart';
import 'package:flutter/foundation.dart';
import 'package:injectable/injectable.dart';

@lazySingleton
class SearchMovies extends UseCase<List<Movie>, SearchMoviesParams> {
  SearchMovies(this._repository);

  final MovieRepository _repository;

  @override
  Future<Either<Failure, List<Movie>>> call(SearchMoviesParams params) {
    return _repository.searchMovies(params.query, page: params.page);
  }
}

/// Parameters for SearchMovies use case.
@immutable
class SearchMoviesParams extends Equatable {
  const SearchMoviesParams({required this.query, this.page = 1});

  final String query;
  final int page;

  @override
  List<Object?> get props => [query, page];
}
