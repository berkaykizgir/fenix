import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import 'package:fenix/config/env/env.dart';
import 'package:fenix/core/error/failures.dart';
import 'package:fenix/core/network/interceptors/api_key_interceptor.dart';
import 'package:fenix/core/network/interceptors/logging_interceptor.dart';
import 'package:fenix/core/network/network_info.dart';
import 'package:fenix/core/util/constants/app_constants.dart';
import 'package:injectable/injectable.dart';

/// API client for GET requests with parsing and failure mapping.
abstract class ApiClient {
  Future<Either<Failure, T>> get<T>({
    required String path,
    required T Function(Map<String, dynamic>) parser,
    Map<String, dynamic>? queryParameters,
  });
}

/// Dio-backed implementation of [ApiClient].
@LazySingleton(as: ApiClient)
class ApiClientImpl implements ApiClient {
  ApiClientImpl(this._networkInfo) {
    _dio = Dio(
      BaseOptions(
        baseUrl: Env.apiBaseUrl,
        connectTimeout: const Duration(milliseconds: AppConstants.connectionTimeout),
        receiveTimeout: const Duration(milliseconds: AppConstants.receiveTimeout),
      ),
    );

    _dio.interceptors.addAll([
      ApiKeyInterceptor(),
      LoggingInterceptor(),
    ]);
  }

  final NetworkInfo _networkInfo;
  late final Dio _dio;

  @override
  Future<Either<Failure, T>> get<T>({
    required String path,
    required T Function(Map<String, dynamic>) parser,
    Map<String, dynamic>? queryParameters,
  }) async {
    try {
      if (!await _networkInfo.isConnected) {
        return const Left(NetworkFailure());
      }

      final response = await _dio.get<Map<String, dynamic>>(
        path,
        queryParameters: queryParameters,
      );

      if (response.data == null) {
        return const Left(ServerFailure('Empty response from server'));
      }

      final parsedData = parser(response.data!);
      return Right(parsedData);
    } on DioException catch (e) {
      return Left(_handleDioError(e));
    } on Exception catch (e) {
      return Left(UnexpectedFailure(e.toString()));
    }
  }

  Failure _handleDioError(DioException error) {
    return switch (error.type) {
      DioExceptionType.connectionTimeout || DioExceptionType.sendTimeout || DioExceptionType.receiveTimeout => const NetworkFailure('Connection timeout'),
      DioExceptionType.connectionError => const NetworkFailure(),
      DioExceptionType.badResponse => ServerFailure('Server error: ${error.response?.statusCode}'),
      _ => UnexpectedFailure(error.message ?? 'Unknown error'),
    };
  }
}
