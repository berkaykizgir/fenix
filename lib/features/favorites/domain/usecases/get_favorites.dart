import 'package:dartz/dartz.dart';
import 'package:fenix/core/error/failures.dart';
import 'package:fenix/core/usecases/no_params.dart';
import 'package:fenix/core/usecases/usecase.dart';
import 'package:fenix/features/favorites/domain/repositories/favorites_repository.dart';
import 'package:fenix/features/movies/domain/entities/movie.dart';
import 'package:injectable/injectable.dart';

@lazySingleton
class GetFavorites extends UseCase<List<Movie>, NoParams> {
  GetFavorites(this._repository);

  final FavoritesRepository _repository;

  @override
  Future<Either<Failure, List<Movie>>> call(NoParams params) {
    return _repository.getFavorites();
  }
}
