import 'package:freezed_annotation/freezed_annotation.dart';

part 'movie_event.freezed.dart';

@freezed
sealed class MovieEvent with _$MovieEvent {
  const factory MovieEvent.getTopRatedMovies() = GetTopRatedMoviesEvent;
  const factory MovieEvent.loadMoreMovies() = LoadMoreMoviesEvent;
  const factory MovieEvent.searchMovies(String query) = SearchMoviesEvent;
  const factory MovieEvent.loadMoreSearchResults(String query) = LoadMoreSearchResultsEvent;
  const factory MovieEvent.networkStatusChanged({required bool isOnline}) = NetworkStatusChangedEvent;
  const factory MovieEvent.updateMovieFavoriteStatus({
    required int movieId,
    required bool isFavorite,
  }) = UpdateMovieFavoriteStatusEvent;
}
