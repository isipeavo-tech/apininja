import 'package:flutter/material.dart';

import '../../core/config/app_config.dart';
import '../../core/network/api_exception.dart';
import '../../core/storage/local_storage.dart';
import '../../data/repositories/api_ninjas_repository.dart';
import '../../state/auth_store.dart';
import '../../state/favorites_store.dart';
import '../../state/settings_controller.dart';
import '../../widgets/app_feedback.dart';
import '../../widgets/tag_list.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({
    super.key,
    required this.authStore,
    required this.settingsController,
    required this.favoritesStore,
    required this.storage,
    required this.repository,
  });

  final AuthStore authStore;
  final SettingsController settingsController;
  final FavoritesStore favoritesStore;
  final LocalStorage storage;
  final ApiNinjasRepository repository;

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  late final TextEditingController _keyController;
  late final Listenable _listenables;
  bool _obscure = true;
  bool _validating = false;
  String? _keyError;

  @override
  void initState() {
    super.initState();
    _keyController = TextEditingController(text: widget.authStore.apiKey);
    _listenables = Listenable.merge(<Listenable>[
      widget.authStore,
      widget.settingsController,
      widget.favoritesStore,
    ]);
  }

  @override
  void dispose() {
    _keyController.dispose();
    super.dispose();
  }

  String get _maskedKey {
    final key = widget.authStore.apiKey;
    if (key.isEmpty) {
      return 'Ключ не задан';
    }
    if (key.length <= 4) {
      return '••••';
    }
    return '••••••••${key.substring(key.length - 4)}';
  }

  Future<void> _saveKey() async {
    final key = _keyController.text.trim();
    if (key.isEmpty) {
      setState(() => _keyError = 'Введите API-ключ.');
      return;
    }
    FocusScope.of(context).unfocus();
    setState(() {
      _validating = true;
      _keyError = null;
    });
    try {
      await widget.repository.validateApiKey(key);
      await widget.authStore.saveApiKey(key);
      if (mounted) {
        setState(() => _keyController.text = key);
        showAppSnackBar(context, 'API-ключ проверен и сохранён');
      }
    } on ApiException catch (error) {
      if (mounted) {
        setState(() => _keyError = error.message);
      }
    } catch (_) {
      if (mounted) {
        setState(
          () => _keyError = 'Не удалось проверить ключ. Попробуйте ещё раз.',
        );
      }
    } finally {
      if (mounted) {
        setState(() => _validating = false);
      }
    }
  }

  Future<void> _removeKey() async {
    final confirmed = await _confirm(
      title: 'Удалить API-ключ?',
      message:
          'Без ключа приложение вернётся к экрану подключения. '
          'Избранное и настройки сохранятся.',
      confirmLabel: 'Удалить',
    );
    if (!confirmed) {
      return;
    }
    await widget.authStore.clearApiKey();
    if (!mounted) {
      return;
    }
    _keyController.text = widget.authStore.apiKey;
    showAppSnackBar(context, 'API-ключ удалён с устройства');
  }

  Future<void> _clearFavorites() async {
    final confirmed = await _confirm(
      title: 'Очистить избранное?',
      message: 'Все сохранённые цитаты будут удалены.',
      confirmLabel: 'Очистить',
    );
    if (!confirmed) {
      return;
    }
    await widget.favoritesStore.clear();
    if (mounted) {
      showAppSnackBar(context, 'Избранное очищено');
    }
  }

  Future<void> _clearRecentSearches() async {
    final confirmed = await _confirm(
      title: 'Очистить историю поиска?',
      message: 'Недавние слова исчезнут из раздела «Словарь».',
      confirmLabel: 'Очистить',
    );
    if (!confirmed) {
      return;
    }
    await widget.storage.clearRecentSearches();
    if (mounted) {
      setState(() {});
      showAppSnackBar(context, 'История поиска очищена');
    }
  }

  Future<bool> _confirm({
    required String title,
    required String message,
    required String confirmLabel,
  }) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(title),
        content: Text(message),
        actions: <Widget>[
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('Отмена'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            child: Text(confirmLabel),
          ),
        ],
      ),
    );
    return result ?? false;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    return ListenableBuilder(
      listenable: _listenables,
      builder: (context, _) {
        final favoriteCount = widget.favoritesStore.count;
        final recentCount = widget.storage.recentSearches.length;
        return ListView(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
          children: <Widget>[
            Card(
              color: scheme.primaryContainer,
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Row(
                  children: <Widget>[
                    Container(
                      width: 52,
                      height: 52,
                      decoration: BoxDecoration(
                        color: scheme.onPrimaryContainer.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Icon(
                        widget.authStore.isConfigured
                            ? Icons.verified_user_rounded
                            : Icons.key_off_outlined,
                        color: scheme.onPrimaryContainer,
                        size: 28,
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Text(
                            widget.authStore.isConfigured
                                ? 'API подключён'
                                : 'API не подключён',
                            style: theme.textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.w800,
                              color: scheme.onPrimaryContainer,
                            ),
                          ),
                          const SizedBox(height: 3),
                          Text(
                            _maskedKey,
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: scheme.onPrimaryContainer.withValues(
                                alpha: 0.75,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 18),
            _SettingsSection(
              icon: Icons.vpn_key_outlined,
              title: 'API-ключ',
              subtitle: 'Запросы подписываются автоматически',
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: <Widget>[
                  TextField(
                    controller: _keyController,
                    obscureText: _obscure,
                    enabled: !_validating,
                    textInputAction: TextInputAction.done,
                    onSubmitted: (_) => _validating ? null : _saveKey(),
                    decoration: InputDecoration(
                      labelText: 'X-Api-Key',
                      prefixIcon: const Icon(Icons.vpn_key_outlined),
                      suffixIcon: IconButton(
                        tooltip: _obscure ? 'Показать ключ' : 'Скрыть ключ',
                        onPressed: () => setState(() => _obscure = !_obscure),
                        icon: Icon(
                          _obscure
                              ? Icons.visibility_outlined
                              : Icons.visibility_off_outlined,
                        ),
                      ),
                    ),
                  ),
                  if (_keyError != null) ...<Widget>[
                    const SizedBox(height: 8),
                    Text(
                      _keyError!,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: scheme.error,
                      ),
                    ),
                  ],
                  const SizedBox(height: 12),
                  FilledButton.icon(
                    onPressed: _validating ? null : _saveKey,
                    icon: _validating
                        ? const SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Icon(Icons.verified_outlined),
                    label: Text(
                      _validating ? 'Проверяем...' : 'Проверить и сохранить',
                    ),
                  ),
                  if (widget.storage.hasStoredApiKey) ...<Widget>[
                    const SizedBox(height: 8),
                    OutlinedButton.icon(
                      onPressed: _validating ? null : _removeKey,
                      icon: const Icon(Icons.logout_rounded),
                      label: const Text('Удалить ключ с устройства'),
                    ),
                  ],
                  const SizedBox(height: 10),
                  Text(
                    'Токен добавляется к каждому запросу через '
                    'ApiKeyInterceptor. В логах заголовки скрыты.',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: scheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 18),
            _SettingsSection(
              icon: Icons.palette_outlined,
              title: 'Оформление',
              subtitle: 'Тема применяется сразу',
              child: SizedBox(
                width: double.infinity,
                child: SegmentedButton<ThemeMode>(
                  showSelectedIcon: false,
                  segments: const <ButtonSegment<ThemeMode>>[
                    ButtonSegment<ThemeMode>(
                      value: ThemeMode.system,
                      icon: Icon(Icons.brightness_auto_rounded),
                      label: Text('Система'),
                    ),
                    ButtonSegment<ThemeMode>(
                      value: ThemeMode.light,
                      icon: Icon(Icons.light_mode_outlined),
                      label: Text('Светлая'),
                    ),
                    ButtonSegment<ThemeMode>(
                      value: ThemeMode.dark,
                      icon: Icon(Icons.dark_mode_outlined),
                      label: Text('Тёмная'),
                    ),
                  ],
                  selected: <ThemeMode>{widget.settingsController.themeMode},
                  onSelectionChanged: (selection) {
                    widget.settingsController.setThemeMode(selection.first);
                  },
                ),
              ),
            ),
            const SizedBox(height: 18),
            _SettingsSection(
              icon: Icons.storage_outlined,
              title: 'Данные на устройстве',
              subtitle: 'Favorites: $favoriteCount · Поиски: $recentCount',
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: <Widget>[
                  OutlinedButton.icon(
                    onPressed: favoriteCount == 0 ? null : _clearFavorites,
                    icon: const Icon(Icons.favorite_border_rounded),
                    label: Text('Очистить избранное ($favoriteCount)'),
                  ),
                  const SizedBox(height: 8),
                  OutlinedButton.icon(
                    onPressed: recentCount == 0 ? null : _clearRecentSearches,
                    icon: const Icon(Icons.history_rounded),
                    label: Text('Очистить историю поиска ($recentCount)'),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    'Ключ, тема, избранное и история хранятся локально '
                    'через SharedPreferences.',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: scheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 18),
            _SettingsSection(
              icon: Icons.info_outline_rounded,
              title: 'О приложении',
              subtitle: '${AppConfig.appName} · версия 1.0.0',
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    'Учебный проект на Flutter: сетевой слой на Dio, '
                    'перехватчик токена, PrettyDioLogger и внедрение '
                    'зависимостей через get_it.',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: scheme.onSurfaceVariant,
                      height: 1.45,
                    ),
                  ),
                  const SizedBox(height: 12),
                  const TagList(
                    tags: <String>[
                      'Dio',
                      'Interceptor',
                      'PrettyDioLogger',
                      'get_it',
                      'SharedPreferences',
                      'Material 3',
                    ],
                  ),
                  const SizedBox(height: 14),
                  Row(
                    children: <Widget>[
                      Expanded(
                        child: Text(
                          AppConfig.website,
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: scheme.primary,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      IconButton(
                        tooltip: 'Скопировать ссылку',
                        onPressed: () => copyText(
                          context,
                          AppConfig.website,
                          message: 'Ссылка скопирована',
                        ),
                        icon: const Icon(Icons.copy_rounded),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        );
      },
    );
  }
}

class _SettingsSection extends StatelessWidget {
  const _SettingsSection({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.child,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Row(
              children: <Widget>[
                Icon(icon, size: 22, color: scheme.primary),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text(
                        title,
                        style: theme.textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        subtitle,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: scheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            child,
          ],
        ),
      ),
    );
  }
}
