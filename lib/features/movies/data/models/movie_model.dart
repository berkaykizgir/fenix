import 'package:fenix/features/movies/domain/entities/movie.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:hive_ce/hive.dart';

part 'movie_model.freezed.dart';
part 'movie_model.g.dart';

@freezed
@HiveType(typeId: 0)
sealed class MovieModel with _$MovieModel {
  const factory MovieModel({
    @HiveField(0) required int id,
    @HiveField(1) required String title,
    @HiveField(2) required String overview,
    @HiveField(3) @JsonKey(name: 'vote_average') required double voteAverage,
    @HiveField(4) @JsonKey(name: 'release_date') required String releaseDate,
    @HiveField(5) @JsonKey(name: 'poster_path') String? posterPath,
  }) = _MovieModel;

  factory MovieModel.fromJson(Map<String, dynamic> json) => _$MovieModelFromJson(json);
}

/// Converts MovieModel to Movie entity.
extension MovieModelX on MovieModel {
  Movie toEntity() {
    return Movie(
      id: id,
      title: title,
      overview: overview,
      posterPath: posterPath,
      voteAverage: voteAverage,
      releaseDate: releaseDate,
    );
  }
}
