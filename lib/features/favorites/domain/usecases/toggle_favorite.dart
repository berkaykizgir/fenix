import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:fenix/core/error/failures.dart';
import 'package:fenix/core/usecases/usecase.dart';
import 'package:fenix/features/favorites/domain/repositories/favorites_repository.dart';
import 'package:fenix/features/movies/domain/entities/movie.dart';
import 'package:flutter/foundation.dart';
import 'package:injectable/injectable.dart';

@lazySingleton
class ToggleFavorite extends UseCase<bool, ToggleFavoriteParams> {
  ToggleFavorite(this._repository);

  final FavoritesRepository _repository;

  @override
  Future<Either<Failure, bool>> call(ToggleFavoriteParams params) {
    return _repository.toggleFavorite(params.movie);
  }
}

@immutable
class ToggleFavoriteParams extends Equatable {
  const ToggleFavoriteParams({required this.movie});

  final Movie movie;

  @override
  List<Object?> get props => [movie];
}
