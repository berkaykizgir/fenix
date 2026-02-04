import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:get_it/get_it.dart';
import 'package:injectable/injectable.dart';

import 'injection.config.dart';

final GetIt getIt = GetIt.instance;

@InjectableInit()
Future<void> configureDependencies() async => getIt.init();

/// Core module for manual registrations.
@module
abstract class CoreModule {
  @lazySingleton
  Connectivity get connectivity => Connectivity();
}
