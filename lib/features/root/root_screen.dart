import 'package:flutter/material.dart';

import '../../core/storage/local_storage.dart';
import '../../data/repositories/api_ninjas_repository.dart';
import '../../state/auth_store.dart';
import '../../state/favorites_store.dart';
import '../../state/settings_controller.dart';
import '../onboarding/api_key_screen.dart';
import '../shell/main_shell.dart';

class RootScreen extends StatelessWidget {
  const RootScreen({
    super.key,
    required this.authStore,
    required this.favoritesStore,
    required this.settingsController,
    required this.storage,
    required this.repository,
  });

  final AuthStore authStore;
  final FavoritesStore favoritesStore;
  final SettingsController settingsController;
  final LocalStorage storage;
  final ApiNinjasRepository repository;

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: authStore,
      builder: (context, _) {
        return AnimatedSwitcher(
          duration: const Duration(milliseconds: 280),
          switchInCurve: Curves.easeOut,
          switchOutCurve: Curves.easeIn,
          child: authStore.isConfigured
              ? MainShell(
                  key: const ValueKey<String>('main-shell'),
                  authStore: authStore,
                  favoritesStore: favoritesStore,
                  settingsController: settingsController,
                  storage: storage,
                  repository: repository,
                )
              : ApiKeyScreen(
                  key: const ValueKey<String>('api-key-screen'),
                  authStore: authStore,
                  repository: repository,
                ),
        );
      },
    );
  }
}
