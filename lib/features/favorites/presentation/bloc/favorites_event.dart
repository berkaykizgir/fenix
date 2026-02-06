import 'package:fenix/features/movies/domain/entities/movie.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'favorites_event.freezed.dart';

@freezed
sealed class FavoritesEvent with _$FavoritesEvent {
  const factory FavoritesEvent.getFavorites() = GetFavoritesEvent;
  const factory FavoritesEvent.toggleFavorite(Movie movie) = ToggleFavoriteEvent;
}
