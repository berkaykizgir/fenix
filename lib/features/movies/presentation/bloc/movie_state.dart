import 'package:freezed_annotation/freezed_annotation.dart';
import '../../domain/entities/movie.dart';

part 'movie_state.freezed.dart';

@freezed
class MovieState with _$MovieState {
  const factory MovieState.initial() = MovieInitial;

  const factory MovieState.loading() = MovieLoading;

  const factory MovieState.loaded({
    required List<Movie> movies,
    @Default(1) int currentPage,
    @Default(true) bool hasMore,
    @Default(false) bool isOffline,
  }) = MovieLoaded;

  const factory MovieState.loadingMore({
    required List<Movie> movies,
    required int currentPage,
    @Default(false) bool isOffline,
  }) = MovieLoadingMore;

  const factory MovieState.premiumRequired({
    required List<Movie> movies,
    required int currentPage,
  }) = MoviePremiumRequired;

  const factory MovieState.error(String message) = MovieError;
}
