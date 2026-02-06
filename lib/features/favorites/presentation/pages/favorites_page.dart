import 'package:auto_route/auto_route.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:fenix/core/di/injection.dart';
import 'package:fenix/features/favorites/presentation/bloc/favorites_bloc.dart';
import 'package:fenix/features/favorites/presentation/bloc/favorites_event.dart';
import 'package:fenix/features/favorites/presentation/bloc/favorites_state.dart';
import 'package:fenix/features/movies/presentation/bloc/movie_bloc.dart';
import 'package:fenix/features/movies/presentation/widgets/movie_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

@RoutePage()
class FavoritesPage extends StatelessWidget {
  const FavoritesPage({super.key});

  @override
  Widget build(BuildContext context) {
    debugPrint(getIt<MovieBloc>().hashCode.toString());
    return BlocProvider(
      create: (_) => getIt<FavoritesBloc>()..add(const FavoritesEvent.getFavorites()),
      child: const _FavoritesPageContent(),
    );
  }
}

class _FavoritesPageContent extends StatelessWidget {
  const _FavoritesPageContent();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('favorites.title'.tr()),
      ),
      body: BlocBuilder<FavoritesBloc, FavoritesState>(
        builder: (context, state) {
          return state.when(
            initial: () => Center(
              child: Text('favorites.empty'.tr()),
            ),
            loading: () => const Center(
              child: CircularProgressIndicator(),
            ),
            loaded: (favorites) {
              if (favorites.isEmpty) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.favorite_border,
                        size: 64,
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'favorites.empty'.tr(),
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'favorites.empty_hint'.tr(),
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                );
              }

              return RefreshIndicator(
                onRefresh: () async {
                  context.read<FavoritesBloc>().add(
                    const FavoritesEvent.getFavorites(),
                  );
                },
                child: GridView.builder(
                  padding: const EdgeInsets.all(16),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    childAspectRatio: 0.7,
                    crossAxisSpacing: 16,
                    mainAxisSpacing: 16,
                  ),
                  itemCount: favorites.length,
                  itemBuilder: (context, index) {
                    final movie = favorites[index];
                    return MovieCard(
                      key: ValueKey('favorite_${movie.id}_${movie.isFavorite}'),
                      movie: movie,
                    );
                  },
                ),
              );
            },
            error: (message) => Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(message),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () => context.read<FavoritesBloc>().add(
                      const FavoritesEvent.getFavorites(),
                    ),
                    child: Text('favorites.retry'.tr()),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
