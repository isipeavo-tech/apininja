import 'package:dio/dio.dart';
import 'package:get_it/get_it.dart';
import 'package:pretty_dio_logger/pretty_dio_logger.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../data/repositories/api_ninjas_repository.dart';
import '../../state/auth_store.dart';
import '../../state/favorites_store.dart';
import '../../state/settings_controller.dart';
import '../network/api_key_interceptor.dart';
import '../network/dio_factory.dart';
import '../storage/local_storage.dart';

final GetIt getIt = GetIt.instance;

void configureDependencies(SharedPreferences preferences) {
  getIt
    ..registerLazySingleton<LocalStorage>(() => LocalStorage(preferences))
    ..registerLazySingleton<AuthStore>(() => AuthStore(getIt<LocalStorage>()))
    ..registerLazySingleton<FavoritesStore>(
      () => FavoritesStore(getIt<LocalStorage>()),
    )
    ..registerLazySingleton<SettingsController>(
      () => SettingsController(getIt<LocalStorage>()),
    )
    ..registerLazySingleton<ApiKeyInterceptor>(
      () => ApiKeyInterceptor(getIt<AuthStore>()),
    )
    ..registerLazySingleton<PrettyDioLogger>(createDioLogger)
    ..registerLazySingleton<Dio>(
      () => createDio(getIt<ApiKeyInterceptor>(), getIt<PrettyDioLogger>()),
    )
    ..registerLazySingleton<ApiNinjasRepository>(
      () => ApiNinjasRepository(getIt<Dio>()),
    );
}
