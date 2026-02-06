import 'package:fenix/features/movies/domain/entities/movie.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'favorites_state.freezed.dart';

@freezed
sealed class FavoritesState with _$FavoritesState {
  const factory FavoritesState.initial() = FavoritesInitial;
  const factory FavoritesState.loading() = FavoritesLoading;
  const factory FavoritesState.loaded({
    required List<Movie> favorites,
  }) = FavoritesLoaded;
  const factory FavoritesState.error(String message) = FavoritesError;
}
