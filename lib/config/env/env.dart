import 'package:envied/envied.dart';

part 'env.g.dart';

/// Environment configuration via Envied (`.env` at repo root).
@Envied(path: '.env')
abstract class Env {
  @EnviedField(varName: 'API_BASE_URL')
  static const String apiBaseUrl = _Env.apiBaseUrl;

  @EnviedField(varName: 'API_KEY', obfuscate: true)
  static String apiKey = _Env.apiKey;

  @EnviedField(varName: 'IMAGE_BASE_URL')
  static const String imageBaseUrl = _Env.imageBaseUrl;
}
