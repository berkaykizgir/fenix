import 'package:equatable/equatable.dart';
import 'package:fenix/config/env/env.dart';
import 'package:flutter/foundation.dart';

/// Movie entity representing a film in the domain layer.
///
/// Pure Dart object with no external dependencies.
@immutable
class Movie extends Equatable {
  const Movie({
    required this.id,
    required this.title,
    required this.overview,
    required this.posterPath,
    required this.voteAverage,
    required this.releaseDate,
  });

  final int id;
  final String title;
  final String overview;
  final String? posterPath;
  final double voteAverage;
  final String releaseDate;

  /// Returns full poster image URL.
  String? get posterUrl => posterPath != null ? '${Env.imageBaseUrl}$posterPath' : null;

  @override
  List<Object?> get props => [
        id,
        title,
        overview,
        posterPath,
        voteAverage,
        releaseDate,
      ];
}
