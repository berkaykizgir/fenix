import 'package:fenix/core/usecases/no_params.dart';
import 'package:fenix/features/favorites/domain/usecases/get_favorites.dart';
import 'package:fenix/features/favorites/domain/usecases/toggle_favorite.dart';
import 'package:fenix/features/favorites/presentation/bloc/favorites_event.dart';
import 'package:fenix/features/favorites/presentation/bloc/favorites_state.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';

@injectable
class FavoritesBloc extends Bloc<FavoritesEvent, FavoritesState> {
  FavoritesBloc(
    this._getFavorites,
    this._toggleFavorite,
  ) : super(const FavoritesState.initial()) {
    on<GetFavoritesEvent>(_onGetFavorites);
    on<ToggleFavoriteEvent>(_onToggleFavorite);
  }

  final GetFavorites _getFavorites;
  final ToggleFavorite _toggleFavorite;

  Future<void> _onGetFavorites(
    GetFavoritesEvent event,
    Emitter<FavoritesState> emit,
  ) async {
    emit(const FavoritesState.loading());

    final result = await _getFavorites(const NoParams());

    result.fold(
      (failure) {
        debugPrint('❌ Get favorites failed: ${failure.message}');
        emit(FavoritesState.error(failure.message));
      },
      (favorites) {
        debugPrint('✅ Loaded ${favorites.length} favorites');
        emit(FavoritesState.loaded(favorites: favorites));
      },
    );
  }

  Future<void> _onToggleFavorite(
    ToggleFavoriteEvent event,
    Emitter<FavoritesState> emit,
  ) async {
    final currentState = state;

    final result = await _toggleFavorite(
      ToggleFavoriteParams(movie: event.movie),
    );

    result.fold(
      (failure) {
        debugPrint('❌ Toggle favorite failed: ${failure.message}');
        emit(FavoritesState.error(failure.message));

        // Restore previous state after error
        if (currentState is FavoritesLoaded) {
          emit(currentState);
        }
      },
      (isFavorite) {
        debugPrint('⭐ Toggled ${event.movie.title}: $isFavorite');

        // Update the list
        if (currentState is FavoritesLoaded) {
          final updatedFavorites = isFavorite
              ? [...currentState.favorites, event.movie.copyWith(isFavorite: true)]
              : currentState.favorites.where((m) => m.id != event.movie.id).toList();

          emit(FavoritesState.loaded(favorites: updatedFavorites));
        } else {
          // If not in loaded state, refresh the list
          add(const FavoritesEvent.getFavorites());
        }
      },
    );
  }
}
