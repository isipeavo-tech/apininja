import 'package:flutter/material.dart';

import 'core/config/app_config.dart';
import 'core/di/injection.dart';
import 'core/storage/local_storage.dart';
import 'core/theme/app_theme.dart';
import 'data/repositories/api_ninjas_repository.dart';
import 'features/root/root_screen.dart';
import 'state/auth_store.dart';
import 'state/favorites_store.dart';
import 'state/settings_controller.dart';

class ApiNinjasApp extends StatelessWidget {
  const ApiNinjasApp({super.key});

  @override
  Widget build(BuildContext context) {
    final settings = getIt<SettingsController>();
    return ListenableBuilder(
      listenable: settings,
      builder: (context, _) {
        return MaterialApp(
          title: AppConfig.appName,
          debugShowCheckedModeBanner: false,
          theme: AppTheme.light,
          darkTheme: AppTheme.dark,
          themeMode: settings.themeMode,
          home: RootScreen(
            authStore: getIt<AuthStore>(),
            favoritesStore: getIt<FavoritesStore>(),
            settingsController: settings,
            storage: getIt<LocalStorage>(),
            repository: getIt<ApiNinjasRepository>(),
          ),
        );
      },
    );
  }
}
