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
    this.isFavorite = false,
  });

  final int id;
  final String title;
  final String overview;
  final String? posterPath;
  final double voteAverage;
  final String releaseDate;
  final bool isFavorite;

  /// Returns full poster image URL.
  String? get posterUrl => posterPath != null ? '${Env.imageBaseUrl}$posterPath' : null;

  Movie copyWith({
    int? id,
    String? title,
    String? overview,
    String? posterPath,
    double? voteAverage,
    String? releaseDate,
    bool? isFavorite,
  }) {
    return Movie(
      id: id ?? this.id,
      title: title ?? this.title,
      overview: overview ?? this.overview,
      posterPath: posterPath ?? this.posterPath,
      voteAverage: voteAverage ?? this.voteAverage,
      releaseDate: releaseDate ?? this.releaseDate,
      isFavorite: isFavorite ?? this.isFavorite,
    );
  }

  @override
  List<Object?> get props => [id, title, overview, posterPath, voteAverage, releaseDate, isFavorite];
}
