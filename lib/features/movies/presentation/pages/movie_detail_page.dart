import 'package:auto_route/auto_route.dart';
import 'package:fenix/core/di/injection.dart';
import 'package:fenix/features/favorites/presentation/bloc/favorites_bloc.dart';
import 'package:fenix/features/favorites/presentation/bloc/favorites_event.dart';
import 'package:fenix/features/movies/domain/entities/movie.dart';
import 'package:flutter/material.dart';

@RoutePage()
class MovieDetailPage extends StatefulWidget {
  final Movie movie;

  const MovieDetailPage({
    required this.movie,
    super.key,
  });

  @override
  State<MovieDetailPage> createState() => _MovieDetailPageState();
}

class _MovieDetailPageState extends State<MovieDetailPage> {
  late bool _isFavorite;

  @override
  void initState() {
    super.initState();
    _isFavorite = widget.movie.isFavorite;
  }

  void _toggleFavorite() {
    setState(() => _isFavorite = !_isFavorite);

    getIt<FavoritesBloc>().add(
      FavoritesEvent.toggleFavorite(
        widget.movie,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Artık 'widget.movie' diyerek objeye erişebilirsiniz.
    final movie = widget.movie;
    final theme = Theme.of(context);

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            pinned: true,
            expandedHeight: 280,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back),
              onPressed: () => context.router.pop(), // AutoRoute pop işlemi
            ),
            actions: [
              IconButton(
                icon: Icon(_isFavorite ? Icons.favorite : Icons.favorite_border),
                color: _isFavorite ? Colors.red : Colors.white,
                onPressed: _toggleFavorite,
              ),
            ],
            flexibleSpace: FlexibleSpaceBar(
              background: movie.posterPath != null
                  ? Image.network(
                      movie.posterUrl!,
                      fit: BoxFit.cover,
                      errorBuilder: (_, _, _) => const ColoredBox(
                        color: Colors.black12,
                        child: Center(child: Icon(Icons.broken_image, size: 48)),
                      ),
                    )
                  : const ColoredBox(
                      color: Colors.black12,
                      child: Center(child: Icon(Icons.movie, size: 48)),
                    ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    movie.title,
                    style: theme.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      const Icon(Icons.star, color: Colors.amber, size: 20),
                      const SizedBox(width: 6),
                      Text(movie.voteAverage.toStringAsFixed(1), style: theme.textTheme.titleMedium),
                      const Spacer(),
                      Text('Çıkış: ${movie.releaseDate}', style: theme.textTheme.bodyMedium),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    movie.overview,
                    style: theme.textTheme.bodyLarge,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
