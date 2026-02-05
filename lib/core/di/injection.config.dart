// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format width=80

// **************************************************************************
// InjectableConfigGenerator
// **************************************************************************

// ignore_for_file: type=lint
// coverage:ignore-file

// ignore_for_file: no_leading_underscores_for_library_prefixes
import 'package:connectivity_plus/connectivity_plus.dart' as _i895;
import 'package:fenix/config/localization/language_manager.dart' as _i570;
import 'package:fenix/config/localization/language_storage.dart' as _i788;
import 'package:fenix/config/localization/language_storage_impl.dart' as _i678;
import 'package:fenix/config/theme/theme_manager.dart' as _i723;
import 'package:fenix/config/theme/theme_storage.dart' as _i509;
import 'package:fenix/config/theme/theme_storage_impl.dart' as _i274;
import 'package:fenix/core/di/injection.dart' as _i459;
import 'package:fenix/core/network/api_client.dart' as _i107;
import 'package:fenix/core/network/network_info.dart' as _i764;
import 'package:fenix/features/movies/data/datasources/movie_local_data_source.dart'
    as _i746;
import 'package:fenix/features/movies/data/datasources/movie_remote_data_source.dart'
    as _i528;
import 'package:fenix/features/movies/data/repositories/movie_repository_impl.dart'
    as _i867;
import 'package:fenix/features/movies/domain/repositories/movie_repository.dart'
    as _i133;
import 'package:fenix/features/movies/domain/usecases/get_top_rated_movies.dart'
    as _i873;
import 'package:fenix/features/movies/domain/usecases/search_movies.dart'
    as _i876;
import 'package:fenix/features/movies/presentation/bloc/movie_bloc.dart'
    as _i100;
import 'package:get_it/get_it.dart' as _i174;
import 'package:injectable/injectable.dart' as _i526;

extension GetItInjectableX on _i174.GetIt {
  // initializes the registration of main-scope dependencies inside of GetIt
  _i174.GetIt init({
    String? environment,
    _i526.EnvironmentFilter? environmentFilter,
  }) {
    final gh = _i526.GetItHelper(this, environment, environmentFilter);
    final coreModule = _$CoreModule();
    gh.lazySingleton<_i895.Connectivity>(() => coreModule.connectivity);
    gh.lazySingleton<_i788.LanguageStorage>(() => _i678.LanguageStorageImpl());
    gh.lazySingleton<_i746.MovieLocalDataSource>(
      () => _i746.MovieLocalDataSourceImpl(),
    );
    gh.lazySingleton<_i764.NetworkInfo>(
      () => _i764.NetworkInfoImpl(gh<_i895.Connectivity>()),
    );
    gh.lazySingleton<_i509.ThemeStorage>(() => _i274.ThemeStorageImpl());
    gh.lazySingleton<_i107.ApiClient>(
      () => _i107.ApiClientImpl(gh<_i764.NetworkInfo>()),
    );
    gh.lazySingleton<_i570.LanguageManager>(
      () => _i570.LanguageManager(gh<_i788.LanguageStorage>()),
    );
    gh.lazySingleton<_i528.MovieRemoteDataSource>(
      () => _i528.MovieRemoteDataSourceImpl(gh<_i107.ApiClient>()),
    );
    gh.lazySingleton<_i723.ThemeManager>(
      () => _i723.ThemeManager(gh<_i509.ThemeStorage>()),
    );
    gh.lazySingleton<_i133.MovieRepository>(
      () => _i867.MovieRepositoryImpl(
        gh<_i528.MovieRemoteDataSource>(),
        gh<_i746.MovieLocalDataSource>(),
        gh<_i764.NetworkInfo>(),
      ),
    );
    gh.lazySingleton<_i873.GetTopRatedMovies>(
      () => _i873.GetTopRatedMovies(gh<_i133.MovieRepository>()),
    );
    gh.lazySingleton<_i876.SearchMovies>(
      () => _i876.SearchMovies(gh<_i133.MovieRepository>()),
    );
    gh.factory<_i100.MovieBloc>(
      () => _i100.MovieBloc(
        gh<_i873.GetTopRatedMovies>(),
        gh<_i876.SearchMovies>(),
        gh<_i764.NetworkInfo>(),
        gh<_i746.MovieLocalDataSource>(),
      ),
    );
    return this;
  }
}

class _$CoreModule extends _i459.CoreModule {}
