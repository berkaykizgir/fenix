import 'package:fenix/core/error/exceptions.dart';
import 'package:fenix/core/network/api_client.dart';
import 'package:fenix/core/network/api_endpoints.dart';
import 'package:fenix/features/movies/data/models/movie_model.dart';
import 'package:injectable/injectable.dart';

/// Remote data source for movies.
abstract class MovieRemoteDataSource {
  Future<List<MovieModel>> getTopRatedMovies({int page = 1});
  Future<List<MovieModel>> searchMovies(String query, {int page = 1});
}

@LazySingleton(as: MovieRemoteDataSource)
class MovieRemoteDataSourceImpl implements MovieRemoteDataSource {
  MovieRemoteDataSourceImpl(this._apiClient);

  final ApiClient _apiClient;

  @override
  Future<List<MovieModel>> getTopRatedMovies({int page = 1}) async {
    final result = await _apiClient.get<Map<String, dynamic>>(
      path: ApiEndpoints.topRatedMovies,
      queryParameters: {'page': page.toString()},
      parser: (json) => json,
    );

    return result.fold(
      (failure) => throw ServerException(failure.message),
      (data) {
        final results = data['results'] as List<dynamic>;
        return results.map((json) => MovieModel.fromJson(json as Map<String, dynamic>)).toList();
      },
    );
  }

  @override
  Future<List<MovieModel>> searchMovies(String query, {int page = 1}) async {
    final result = await _apiClient.get<Map<String, dynamic>>(
      path: ApiEndpoints.searchMovies,
      queryParameters: {
        'query': query,
        'page': page.toString(), // ⬅️ Page parametresi
      },
      parser: (json) => json,
    );

    return result.fold(
      (failure) => throw ServerException(failure.message),
      (data) {
        final results = data['results'] as List<dynamic>;
        return results.map((json) => MovieModel.fromJson(json as Map<String, dynamic>)).toList();
      },
    );
  }
}
