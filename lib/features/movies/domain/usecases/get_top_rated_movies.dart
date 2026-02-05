import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:fenix/core/error/failures.dart';
import 'package:fenix/core/usecases/usecase.dart';
import 'package:fenix/features/movies/domain/entities/movie.dart';
import 'package:fenix/features/movies/domain/repositories/movie_repository.dart';
import 'package:flutter/foundation.dart';
import 'package:injectable/injectable.dart';

@lazySingleton
class GetTopRatedMovies extends UseCase<List<Movie>, GetTopRatedMoviesParams> {
  GetTopRatedMovies(this._repository);

  final MovieRepository _repository;

  @override
  Future<Either<Failure, List<Movie>>> call(GetTopRatedMoviesParams params) {
    return _repository.getTopRatedMovies(page: params.page);
  }
}

/// Parameters for GetTopRatedMovies use case.
@immutable
class GetTopRatedMoviesParams extends Equatable {
  const GetTopRatedMoviesParams({this.page = 1});

  final int page;

  @override
  List<Object?> get props => [page];
}
