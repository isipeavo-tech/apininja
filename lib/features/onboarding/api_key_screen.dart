import 'package:flutter/material.dart';

import '../../core/config/app_config.dart';
import '../../core/network/api_exception.dart';
import '../../data/repositories/api_ninjas_repository.dart';
import '../../state/auth_store.dart';
import '../../widgets/app_feedback.dart';

class ApiKeyScreen extends StatefulWidget {
  const ApiKeyScreen({
    super.key,
    required this.authStore,
    required this.repository,
  });

  final AuthStore authStore;
  final ApiNinjasRepository repository;

  @override
  State<ApiKeyScreen> createState() => _ApiKeyScreenState();
}

class _ApiKeyScreenState extends State<ApiKeyScreen> {
  final TextEditingController _controller = TextEditingController();
  bool _obscure = true;
  bool _loading = false;
  String? _error;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _connect() async {
    final key = _controller.text.trim();
    if (key.isEmpty) {
      setState(() => _error = 'Введите API-ключ.');
      return;
    }
    FocusScope.of(context).unfocus();
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      await widget.repository.validateApiKey(key);
      await widget.authStore.saveApiKey(key);
    } on ApiException catch (error) {
      if (mounted) {
        setState(() => _error = error.message);
      }
    } catch (_) {
      if (mounted) {
        setState(
          () => _error = 'Не удалось проверить ключ. Попробуйте ещё раз.',
        );
      }
    } finally {
      if (mounted) {
        setState(() => _loading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: <Color>[
              scheme.primaryContainer.withValues(alpha: 0.55),
              scheme.surface,
              scheme.surface,
            ],
            stops: const <double>[0, 0.45, 1],
          ),
        ),
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 520),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: <Widget>[
                    const SizedBox(height: 16),
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Container(
                        width: 78,
                        height: 78,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: <Color>[scheme.primary, scheme.tertiary],
                          ),
                          borderRadius: BorderRadius.circular(24),
                        ),
                        child: Icon(
                          Icons.auto_awesome_rounded,
                          color: scheme.onPrimary,
                          size: 38,
                        ),
                      ),
                    ),
                    const SizedBox(height: 26),
                    Text(
                      AppConfig.appName,
                      style: textTheme.headlineMedium?.copyWith(
                        fontWeight: FontWeight.w800,
                        letterSpacing: -0.5,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      'Цитаты, шутки, факты и словарь в одном приложении. '
                      'Для работы нужен бесплатный ключ API Ninjas.',
                      style: textTheme.bodyLarge?.copyWith(
                        color: scheme.onSurfaceVariant,
                        height: 1.45,
                      ),
                    ),
                    const SizedBox(height: 28),
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.all(20),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: <Widget>[
                            Text(
                              'Подключение к API',
                              style: textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            const SizedBox(height: 14),
                            TextField(
                              controller: _controller,
                              obscureText: _obscure,
                              enabled: !_loading,
                              textInputAction: TextInputAction.done,
                              onSubmitted: (_) => _loading ? null : _connect(),
                              decoration: InputDecoration(
                                labelText: 'X-Api-Key',
                                hintText: 'Вставьте ключ API Ninjas',
                                prefixIcon: const Icon(Icons.vpn_key_outlined),
                                suffixIcon: IconButton(
                                  tooltip: _obscure
                                      ? 'Показать ключ'
                                      : 'Скрыть ключ',
                                  onPressed: () =>
                                      setState(() => _obscure = !_obscure),
                                  icon: Icon(
                                    _obscure
                                        ? Icons.visibility_outlined
                                        : Icons.visibility_off_outlined,
                                  ),
                                ),
                              ),
                            ),
                            if (_error != null) ...<Widget>[
                              const SizedBox(height: 10),
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: <Widget>[
                                  Icon(
                                    Icons.error_outline_rounded,
                                    size: 18,
                                    color: scheme.error,
                                  ),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: Text(
                                      _error!,
                                      style: textTheme.bodySmall?.copyWith(
                                        color: scheme.error,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                            const SizedBox(height: 16),
                            FilledButton.icon(
                              onPressed: _loading ? null : _connect,
                              icon: _loading
                                  ? const SizedBox(
                                      width: 18,
                                      height: 18,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                      ),
                                    )
                                  : const Icon(Icons.link_rounded),
                              label: Text(
                                _loading ? 'Проверяем ключ...' : 'Подключиться',
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Card(
                      color: scheme.surfaceContainer,
                      child: Padding(
                        padding: const EdgeInsets.all(18),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            Row(
                              children: <Widget>[
                                Icon(
                                  Icons.lightbulb_outline_rounded,
                                  color: scheme.primary,
                                ),
                                const SizedBox(width: 10),
                                Text(
                                  'Где взять ключ?',
                                  style: textTheme.titleSmall?.copyWith(
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 10),
                            Text(
                              'Зарегистрируйтесь на API Ninjas и скопируйте ключ '
                              'из личного кабинета.',
                              style: textTheme.bodyMedium?.copyWith(
                                color: scheme.onSurfaceVariant,
                                height: 1.4,
                              ),
                            ),
                            const SizedBox(height: 12),
                            Row(
                              children: <Widget>[
                                Expanded(
                                  child: SelectableText(
                                    AppConfig.registerUrl,
                                    style: textTheme.bodySmall?.copyWith(
                                      color: scheme.primary,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                                IconButton(
                                  tooltip: 'Скопировать ссылку',
                                  onPressed: () => copyText(
                                    context,
                                    AppConfig.registerUrl,
                                    message: 'Ссылка скопирована',
                                  ),
                                  icon: const Icon(Icons.copy_rounded),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                    Text(
                      'Ключ хранится только на этом устройстве и добавляется '
                      'к запросам автоматически.',
                      textAlign: TextAlign.center,
                      style: textTheme.bodySmall?.copyWith(
                        color: scheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
