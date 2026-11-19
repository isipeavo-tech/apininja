import 'package:flutter/material.dart';

import '../../core/network/api_exception.dart';
import '../../data/models/joke.dart';
import '../../data/repositories/api_ninjas_repository.dart';
import '../../widgets/app_feedback.dart';
import '../../widgets/section_header.dart';

class JokesPage extends StatefulWidget {
  const JokesPage({super.key, required this.repository});

  final ApiNinjasRepository repository;

  @override
  State<JokesPage> createState() => _JokesPageState();
}

class _JokesPageState extends State<JokesPage> {
  final List<Joke> _jokes = <Joke>[];
  bool _loading = false;
  ApiException? _error;

  @override
  void initState() {
    super.initState();
    _loadJoke();
  }

  Future<void> _loadJoke() async {
    if (_loading) {
      return;
    }
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final joke = await widget.repository.getRandomJoke();
      if (mounted) {
        setState(() => _jokes.insert(0, joke));
      }
    } on ApiException catch (error) {
      if (mounted) {
        setState(() => _error = error);
      }
    } catch (_) {
      if (mounted) {
        setState(
          () => _error = const ApiException('Не удалось получить шутку.'),
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
    final theme = Theme.of(context);

    return RefreshIndicator(
      onRefresh: _loadJoke,
      child: ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
        children: <Widget>[
          Card(
            color: scheme.tertiaryContainer,
            child: Padding(
              padding: const EdgeInsets.all(18),
              child: Row(
                children: <Widget>[
                  Icon(
                    Icons.sentiment_very_satisfied_rounded,
                    size: 36,
                    color: scheme.onTertiaryContainer,
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Text(
                          'Шутки API Ninjas',
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w800,
                            color: scheme.onTertiaryContainer,
                          ),
                        ),
                        const SizedBox(height: 3),
                        Text(
                          'Свежая шутка добавляется в начало ленты.',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: scheme.onTertiaryContainer.withValues(
                              alpha: 0.78,
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
          SectionHeader(
            title: 'Лента шуток',
            subtitle: _jokes.isEmpty
                ? 'Пока ничего не загружено'
                : 'В ленте: ${_jokes.length}',
            trailing: IconButton(
              tooltip: 'Обновить',
              onPressed: _loading ? null : _loadJoke,
              icon: const Icon(Icons.refresh_rounded),
            ),
          ),
          if (_error != null)
            Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: ErrorView(
                error: _error!,
                onRetry: _loading ? null : _loadJoke,
                compact: true,
              ),
            ),
          if (_loading && _jokes.isEmpty)
            const InlineLoader(label: 'Загружаем шутку...')
          else if (_jokes.isEmpty && _error == null)
            const EmptyState(
              icon: Icons.sentiment_dissatisfied_rounded,
              title: 'Шуток пока нет',
              message: 'Нажмите «Ещё шутку», чтобы начать.',
            ),
          for (int index = 0; index < _jokes.length; index++) ...<Widget>[
            _JokeCard(
              joke: _jokes[index],
              onCopy: () => copyText(
                context,
                _jokes[index].text,
                message: 'Шутка скопирована',
              ),
            ),
            if (index != _jokes.length - 1) const SizedBox(height: 12),
          ],
          const SizedBox(height: 18),
          FilledButton.icon(
            onPressed: _loading ? null : _loadJoke,
            icon: _loading
                ? const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Icon(Icons.add_rounded),
            label: Text(_loading ? 'Загружаем...' : 'Ещё шутку'),
          ),
          const SizedBox(height: 12),
          Text(
            'Шутки приходят на английском языке. Потяните ленту вниз, '
            'чтобы добавить новую.',
            textAlign: TextAlign.center,
            style: theme.textTheme.bodySmall?.copyWith(
              color: scheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }
}

class _JokeCard extends StatelessWidget {
  const _JokeCard({required this.joke, required this.onCopy});

  final Joke joke;
  final VoidCallback onCopy;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    return Card(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 16, 12, 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Row(
              children: <Widget>[
                Icon(
                  Icons.tag_faces_rounded,
                  size: 20,
                  color: scheme.onSurfaceVariant,
                ),
                const SizedBox(width: 8),
                Text(
                  'JOKE',
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: scheme.onSurfaceVariant,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 1.2,
                  ),
                ),
                const Spacer(),
                IconButton(
                  tooltip: 'Копировать шутку',
                  onPressed: onCopy,
                  icon: const Icon(Icons.copy_rounded, size: 20),
                ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.only(right: 8),
              child: Text(
                joke.text,
                style: theme.textTheme.bodyLarge?.copyWith(
                  height: 1.55,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
