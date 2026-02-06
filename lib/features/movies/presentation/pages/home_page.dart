import 'dart:async';

import 'package:auto_route/auto_route.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:fenix/config/localization/language_manager.dart';
import 'package:fenix/config/routes/app_router.dart';
import 'package:fenix/config/theme/theme_manager.dart';
import 'package:fenix/core/di/injection.dart';
import 'package:fenix/features/movies/domain/entities/movie.dart';
import 'package:fenix/features/movies/presentation/bloc/movie_bloc.dart';
import 'package:fenix/features/movies/presentation/bloc/movie_event.dart';
import 'package:fenix/features/movies/presentation/bloc/movie_state.dart';
import 'package:fenix/features/movies/presentation/widgets/movie_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/util/widgets/premium_prompt_sheet.dart';

@RoutePage()
class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    debugPrint(getIt<MovieBloc>().hashCode.toString());
    return BlocProvider(
      create: (_) => getIt<MovieBloc>()..add(const MovieEvent.getTopRatedMovies()),
      child: const _HomePageContent(),
    );
  }
}

class _HomePageContent extends StatefulWidget {
  const _HomePageContent();

  @override
  State<_HomePageContent> createState() => _HomePageContentState();
}

class _HomePageContentState extends State<_HomePageContent> {
  Timer? _debounce;
  final _searchController = TextEditingController();
  final _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _searchController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_isBottom) {
      final bloc = context.read<MovieBloc>();

      // Premium kontrolü BLoC'ta yapılıyor, sadece event gönder
      if (_searchController.text.trim().isNotEmpty) {
        bloc.add(MovieEvent.loadMoreSearchResults(_searchController.text));
      } else {
        bloc.add(const MovieEvent.loadMoreMovies());
      }
    }
  }

  bool get _isBottom {
    if (!_scrollController.hasClients) return false;
    final maxScroll = _scrollController.position.maxScrollExtent;
    final currentScroll = _scrollController.offset;
    return currentScroll >= (maxScroll * 0.9);
  }

  Future<void> _changeLanguage(BuildContext context, Locale locale) async {
    await getIt<LanguageManager>().saveSelectedLocale(locale);

    if (context.mounted) {
      await context.setLocale(locale);
    }
  }

  Future<void> _changeTheme(ThemeMode themeMode) async {
    await getIt<ThemeManager>().changeThemeMode(themeMode);
  }

  void _onSearchChanged(String query) {
    _debounce?.cancel();

    if (query.trim().isEmpty) {
      context.read<MovieBloc>().add(const MovieEvent.getTopRatedMovies());
      return;
    }

    if (query.length < 2) return;

    _debounce = Timer(const Duration(milliseconds: 500), () {
      context.read<MovieBloc>().add(MovieEvent.searchMovies(query));
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('home.title'.tr()),
        actions: [
          IconButton(
            icon: const Icon(Icons.favorite),
            onPressed: () async {
              await context.router.push(const FavoritesRoute());
            },
          ),
          PopupMenuButton<Locale>(
            icon: const Icon(Icons.language),
            onSelected: (locale) => _changeLanguage(context, locale),
            itemBuilder: (_) => const [
              PopupMenuItem(value: Locale('en'), child: Text('English')),
              PopupMenuItem(value: Locale('tr'), child: Text('Türkçe')),
            ],
          ),
          PopupMenuButton<ThemeMode>(
            icon: const Icon(Icons.brightness_6),
            onSelected: _changeTheme,
            itemBuilder: (_) => const [
              PopupMenuItem(value: ThemeMode.light, child: Text('Light')),
              PopupMenuItem(value: ThemeMode.dark, child: Text('Dark')),
              PopupMenuItem(value: ThemeMode.system, child: Text('System')),
            ],
          ),
        ],
      ),
      body: BlocListener<MovieBloc, MovieState>(
        listener: (context, state) async {
          if (state is MoviePremiumRequired) {
            await showPremiumPrompt(context);
          }
        },
        child: Column(
          children: [
            // Offline banner - State'ten isOffline flag'ini kontrol et
            BlocBuilder<MovieBloc, MovieState>(
              builder: (context, state) {
                // State'ten offline flag'ini al
                final isOffline = state.maybeWhen(
                  loaded: (movies, currentPage, hasMore, isOffline) => isOffline,
                  loadingMore: (movies, currentPage, isOffline) => isOffline,
                  orElse: () => false,
                );

                if (isOffline) {
                  return Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(12),
                    color: Colors.orange.withValues(alpha: 0.2),
                    child: Row(
                      children: [
                        const Icon(Icons.cloud_off, size: 20, color: Colors.orange),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            'home.offline_mode'.tr(),
                            style: const TextStyle(color: Colors.orange, fontSize: 14),
                          ),
                        ),
                      ],
                    ),
                  );
                }
                return const SizedBox.shrink();
              },
            ),
            // Search bar
            Padding(
              padding: const EdgeInsets.all(16),
              child: TextField(
                controller: _searchController,
                onChanged: _onSearchChanged,
                decoration: InputDecoration(
                  hintText: 'home.search_hint'.tr(),
                  prefixIcon: const Icon(Icons.search),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),
            // Movie list
            Expanded(
              child: BlocBuilder<MovieBloc, MovieState>(
                key: UniqueKey(),
                builder: (context, state) {
                  return state.when(
                    initial: () => Center(child: Text('home.search_prompt'.tr())),
                    loading: () => const Center(child: CircularProgressIndicator()),
                    loaded: (movies, currentPage, hasMore, isOffline) => _buildMovieGrid(
                      movies: movies,
                      showLoadingIndicator: hasMore,
                    ),
                    loadingMore: (movies, currentPage, isOffline) => _buildMovieGrid(
                      movies: movies,
                      showLoadingIndicator: true,
                    ),
                    premiumRequired: (movies, currentPage) => _buildMovieGrid(
                      movies: movies,
                      showLoadingIndicator: false,
                    ),
                    error: _buildErrorWidget,
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Helper methods
  Widget _buildMovieGrid({
    required List<Movie> movies,
    required bool showLoadingIndicator,
  }) {
    if (movies.isEmpty) {
      return Center(child: Text('home.no_movies'.tr()));
    }

    return GridView.builder(
      controller: _scrollController,
      padding: const EdgeInsets.all(16),
      addAutomaticKeepAlives: false,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 0.7,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
      ),
      itemCount: movies.length + (showLoadingIndicator ? 1 : 0),
      itemBuilder: (context, index) {
        if (index >= movies.length) {
          return const Center(
            child: Padding(
              padding: EdgeInsets.all(16),
              child: CircularProgressIndicator(),
            ),
          );
        }
        return MovieCard(key: ValueKey('${movies[index].id}_${movies[index].isFavorite}'), movie: movies[index]);
      },
    );
  }

  Widget _buildErrorWidget(String message) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(message),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () => context.read<MovieBloc>().add(const MovieEvent.getTopRatedMovies()),
            child: Text('home.retry'.tr()),
          ),
        ],
      ),
    );
  }
}
