import 'package:flutter/material.dart';

import '../../core/network/api_exception.dart';
import '../../core/storage/local_storage.dart';
import '../../data/models/dictionary_entry.dart';
import '../../data/models/thesaurus_entry.dart';
import '../../data/repositories/api_ninjas_repository.dart';
import '../../widgets/app_feedback.dart';
import '../../widgets/section_header.dart';
import '../../widgets/tag_list.dart';

enum _LookupMode { definition, thesaurus }

class DictionaryPage extends StatefulWidget {
  const DictionaryPage({
    super.key,
    required this.repository,
    required this.storage,
  });

  final ApiNinjasRepository repository;
  final LocalStorage storage;

  @override
  State<DictionaryPage> createState() => _DictionaryPageState();
}

class _DictionaryPageState extends State<DictionaryPage> {
  final TextEditingController _controller = TextEditingController();
  _LookupMode _mode = _LookupMode.definition;
  DictionaryEntry? _entry;
  ThesaurusEntry? _thesaurus;
  ApiException? _error;
  bool _loading = false;
  String? _lastQuery;
  List<String> _recent = <String>[];

  @override
  void initState() {
    super.initState();
    _recent = widget.storage.recentSearches;
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _search([String? query]) async {
    final word = (query ?? _controller.text).trim();
    if (word.isEmpty) {
      setState(() => _error = const ApiException('Введите английское слово.'));
      return;
    }
    if (query != null) {
      _controller.text = word;
    }
    FocusScope.of(context).unfocus();
    setState(() {
      _loading = true;
      _error = null;
      _lastQuery = word.toLowerCase();
      _entry = null;
      _thesaurus = null;
    });

    try {
      final mode = _mode;
      DictionaryEntry? entry;
      ThesaurusEntry? thesaurus;
      if (mode == _LookupMode.definition) {
        entry = await widget.repository.getDefinition(word);
      } else {
        thesaurus = await widget.repository.getThesaurus(word);
      }
      await widget.storage.addRecentSearch(word);
      if (!mounted) {
        return;
      }
      setState(() {
        _entry = entry;
        _thesaurus = thesaurus;
        _recent = widget.storage.recentSearches;
      });
    } on ApiException catch (error) {
      if (mounted) {
        setState(() => _error = error);
      }
    } catch (_) {
      if (mounted) {
        setState(
          () => _error = const ApiException(
            'Не удалось выполнить поиск по словарю.',
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _loading = false);
      }
    }
  }

  void _changeMode(Set<_LookupMode> selection) {
    final next = selection.first;
    if (next == _mode) {
      return;
    }
    setState(() {
      _mode = next;
      _entry = null;
      _thesaurus = null;
      _error = null;
    });
    if (_controller.text.trim().isNotEmpty) {
      _search();
    }
  }

  Future<void> _clearRecent() async {
    await widget.storage.clearRecentSearches();
    if (mounted) {
      setState(() => _recent = <String>[]);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
      children: <Widget>[
        Card(
          color: scheme.surfaceContainer,
          child: Padding(
            padding: const EdgeInsets.all(18),
            child: Row(
              children: <Widget>[
                Icon(Icons.menu_book_rounded, size: 36, color: scheme.primary),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text(
                        'Английский словарь',
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      const SizedBox(height: 3),
                      Text(
                        'Определения и синонимы из API Ninjas.',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: scheme.onSurfaceVariant,
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
        Card(
          child: Padding(
            padding: const EdgeInsets.all(18),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                SizedBox(
                  width: double.infinity,
                  child: SegmentedButton<_LookupMode>(
                    showSelectedIcon: false,
                    segments: const <ButtonSegment<_LookupMode>>[
                      ButtonSegment<_LookupMode>(
                        value: _LookupMode.definition,
                        icon: Icon(Icons.article_outlined),
                        label: Text('Определение'),
                      ),
                      ButtonSegment<_LookupMode>(
                        value: _LookupMode.thesaurus,
                        icon: Icon(Icons.swap_horiz_rounded),
                        label: Text('Синонимы'),
                      ),
                    ],
                    selected: <_LookupMode>{_mode},
                    onSelectionChanged: _changeMode,
                  ),
                ),
                const SizedBox(height: 14),
                TextField(
                  controller: _controller,
                  enabled: !_loading,
                  textInputAction: TextInputAction.search,
                  autocorrect: false,
                  onSubmitted: (_) => _search(),
                  decoration: InputDecoration(
                    labelText: 'Слово на английском',
                    hintText: 'например, serendipity',
                    prefixIcon: const Icon(Icons.search_rounded),
                    suffixIcon: IconButton(
                      tooltip: 'Очистить',
                      onPressed: () {
                        _controller.clear();
                        setState(() {
                          _entry = null;
                          _thesaurus = null;
                          _error = null;
                        });
                      },
                      icon: const Icon(Icons.close_rounded),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                FilledButton.icon(
                  onPressed: _loading ? null : _search,
                  icon: _loading
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Icon(Icons.search_rounded),
                  label: Text(_loading ? 'Ищем...' : 'Найти'),
                ),
              ],
            ),
          ),
        ),
        if (_recent.isNotEmpty) ...<Widget>[
          const SizedBox(height: 18),
          SectionHeader(
            title: 'Недавние запросы',
            subtitle: 'Нажмите на слово, чтобы повторить поиск',
            trailing: TextButton(
              onPressed: _clearRecent,
              child: const Text('Очистить'),
            ),
          ),
          TagList(
            tags: _recent,
            icon: Icons.history_rounded,
            onTagTap: (word) => _search(word),
          ),
        ],
        const SizedBox(height: 20),
        if (_loading)
          InlineLoader(
            label: _mode == _LookupMode.definition
                ? 'Ищем определение...'
                : 'Ищем синонимы...',
          )
        else if (_error != null)
          ErrorView(error: _error!, onRetry: _search, compact: true)
        else if (_mode == _LookupMode.definition && _entry != null)
          _DefinitionCard(
            entry: _entry!,
            fallbackWord: _lastQuery ?? '',
            onCopy: () {
              final entry = _entry!;
              copyText(
                context,
                '${entry.word}: ${entry.definition}',
                message: 'Определение скопировано',
              );
            },
          )
        else if (_mode == _LookupMode.thesaurus && _thesaurus != null)
          _ThesaurusCard(
            entry: _thesaurus!,
            fallbackWord: _lastQuery ?? '',
            onWordTap: (word) => _search(word),
            onCopy: () {
              final entry = _thesaurus!;
              copyText(
                context,
                [
                  if (entry.synonyms.isNotEmpty)
                    'Synonyms: ${entry.synonyms.join(', ')}',
                  if (entry.antonyms.isNotEmpty)
                    'Antonyms: ${entry.antonyms.join(', ')}',
                ].join('\n'),
                message: 'Результат скопирован',
              );
            },
          )
        else
          const EmptyState(
            icon: Icons.translate_rounded,
            title: 'Найдите английское слово',
            message: 'Введите слово и выберите режим поиска.',
          ),
        const SizedBox(height: 16),
        Text(
          'Совет: словарь API Ninjas работает только с английскими словами.',
          textAlign: TextAlign.center,
          style: theme.textTheme.bodySmall?.copyWith(
            color: scheme.onSurfaceVariant,
          ),
        ),
      ],
    );
  }
}

class _DefinitionCard extends StatelessWidget {
  const _DefinitionCard({
    required this.entry,
    required this.fallbackWord,
    required this.onCopy,
  });

  final DictionaryEntry entry;
  final String fallbackWord;
  final VoidCallback onCopy;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final word = entry.word.isNotEmpty ? entry.word : fallbackWord;
    final notFound = !entry.valid || entry.definition.trim().isEmpty;

    return Card(
      color: notFound ? scheme.errorContainer : null,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 18, 14, 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Row(
              children: <Widget>[
                Expanded(
                  child: Text(
                    word,
                    style: theme.textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.w800,
                      color: notFound ? scheme.onErrorContainer : null,
                    ),
                  ),
                ),
                if (!notFound)
                  IconButton(
                    tooltip: 'Копировать',
                    onPressed: onCopy,
                    icon: const Icon(Icons.copy_rounded),
                  ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              notFound
                  ? 'Определение не найдено. Проверьте написание слова.'
                  : entry.definition,
              style: theme.textTheme.bodyLarge?.copyWith(
                height: 1.55,
                color: notFound ? scheme.onErrorContainer : null,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ThesaurusCard extends StatelessWidget {
  const _ThesaurusCard({
    required this.entry,
    required this.fallbackWord,
    required this.onWordTap,
    required this.onCopy,
  });

  final ThesaurusEntry entry;
  final String fallbackWord;
  final ValueChanged<String> onWordTap;
  final VoidCallback onCopy;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final word = entry.word.isNotEmpty ? entry.word : fallbackWord;

    return Card(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 18, 20, 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Row(
              children: <Widget>[
                Expanded(
                  child: Text(
                    word,
                    style: theme.textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
                IconButton(
                  tooltip: 'Копировать',
                  onPressed: onCopy,
                  icon: const Icon(Icons.copy_rounded),
                ),
              ],
            ),
            if (entry.isEmpty) ...<Widget>[
              const SizedBox(height: 8),
              Text(
                'Синонимы и антонимы не найдены. Попробуйте другое слово.',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: scheme.onSurfaceVariant,
                ),
              ),
            ],
            if (entry.synonyms.isNotEmpty) ...<Widget>[
              const SizedBox(height: 16),
              Text(
                'Синонимы',
                style: theme.textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 10),
              TagList(
                tags: entry.synonyms,
                icon: Icons.add_rounded,
                onTagTap: onWordTap,
              ),
            ],
            if (entry.antonyms.isNotEmpty) ...<Widget>[
              const SizedBox(height: 18),
              Text(
                'Антонимы',
                style: theme.textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 10),
              TagList(
                tags: entry.antonyms,
                icon: Icons.remove_rounded,
                onTagTap: onWordTap,
              ),
            ],
            if (!entry.isEmpty) ...<Widget>[
              const SizedBox(height: 14),
              Text(
                'Нажмите на слово, чтобы посмотреть его синонимы.',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: scheme.onSurfaceVariant,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
