import 'package:dio/dio.dart';
import 'package:fenix/config/env/env.dart';

/// Adds API key to all requests automatically.
class ApiKeyInterceptor extends Interceptor {
  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    options.queryParameters['api_key'] = Env.apiKey;
    super.onRequest(options, handler);
  }
}
