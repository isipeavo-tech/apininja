import 'package:flutter/material.dart';

import '../../core/network/api_exception.dart';
import '../../data/models/quote.dart';
import '../../data/repositories/api_ninjas_repository.dart';
import '../../state/favorites_store.dart';
import '../../widgets/app_feedback.dart';
import '../../widgets/section_header.dart';
import 'quote_card.dart';

class QuotesPage extends StatefulWidget {
  const QuotesPage({
    super.key,
    required this.repository,
    required this.favoritesStore,
  });

  final ApiNinjasRepository repository;
  final FavoritesStore favoritesStore;

  @override
  State<QuotesPage> createState() => _QuotesPageState();
}

class _QuotesPageState extends State<QuotesPage> {
  static const List<({String value, String label})> _categories =
      <({String value, String label})>[
        (value: 'all', label: 'Все'),
        (value: 'wisdom', label: 'Мудрость'),
        (value: 'life', label: 'Жизнь'),
        (value: 'success', label: 'Успех'),
        (value: 'love', label: 'Любовь'),
        (value: 'happiness', label: 'Счастье'),
        (value: 'motivational', label: 'Мотивация'),
        (value: 'humor', label: 'Юмор'),
        (value: 'friendship', label: 'Дружба'),
        (value: 'leadership', label: 'Лидерство'),
        (value: 'time', label: 'Время'),
        (value: 'education', label: 'Образование'),
      ];

  Quote? _dailyQuote;
  Quote? _randomQuote;
  ApiException? _dailyError;
  ApiException? _randomError;
  bool _dailyLoading = false;
  bool _randomLoading = false;
  bool _showFavorites = false;
  String _category = 'all';

  @override
  void initState() {
    super.initState();
    _loadDaily();
    _loadRandom();
  }

  Future<void> _loadDaily() async {
    setState(() {
      _dailyLoading = true;
      _dailyError = null;
    });
    try {
      final quote = await widget.repository.getQuoteOfTheDay();
      if (mounted) {
        setState(() => _dailyQuote = quote);
      }
    } on ApiException catch (error) {
      if (mounted) {
        setState(() => _dailyError = error);
      }
    } catch (_) {
      if (mounted) {
        setState(
          () => _dailyError = const ApiException(
            'Не удалось получить цитату дня.',
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _dailyLoading = false);
      }
    }
  }

  Future<void> _loadRandom() async {
    setState(() {
      _randomLoading = true;
      _randomError = null;
    });
    try {
      final quote = await widget.repository.getRandomQuote(category: _category);
      if (mounted) {
        setState(() => _randomQuote = quote);
      }
    } on ApiException catch (error) {
      if (mounted) {
        setState(() => _randomError = error);
      }
    } catch (_) {
      if (mounted) {
        setState(
          () => _randomError = const ApiException(
            'Не удалось получить случайную цитату.',
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _randomLoading = false);
      }
    }
  }

  Future<void> _refreshAll() async {
    await Future.wait(<Future<void>>[_loadDaily(), _loadRandom()]);
  }

  void _selectCategory(String value) {
    if (_category == value) {
      return;
    }
    setState(() {
      _category = value;
      _randomQuote = null;
      _randomError = null;
    });
    _loadRandom();
  }

  Future<void> _toggleFavorite(Quote quote) async {
    final added = await widget.favoritesStore.toggle(quote);
    if (mounted) {
      showAppSnackBar(
        context,
        added ? 'Цитата добавлена в избранное' : 'Цитата удалена из избранного',
      );
    }
  }

  Future<void> _clearFavorites() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Очистить избранное?'),
        content: const Text(
          'Все сохранённые цитаты будут удалены с этого устройства.',
        ),
        actions: <Widget>[
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('Отмена'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            child: const Text('Очистить'),
          ),
        ],
      ),
    );
    if (confirmed == true) {
      await widget.favoritesStore.clear();
      if (mounted) {
        showAppSnackBar(context, 'Избранное очищено');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: widget.favoritesStore,
      builder: (context, _) {
        final count = widget.favoritesStore.count;
        return Column(
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
              child: SizedBox(
                width: double.infinity,
                child: SegmentedButton<bool>(
                  showSelectedIcon: false,
                  segments: <ButtonSegment<bool>>[
                    const ButtonSegment<bool>(
                      value: false,
                      icon: Icon(Icons.explore_outlined),
                      label: Text('Лента'),
                    ),
                    ButtonSegment<bool>(
                      value: true,
                      icon: const Icon(Icons.favorite_border_rounded),
                      label: Text('Избранное ($count)'),
                    ),
                  ],
                  selected: <bool>{_showFavorites},
                  onSelectionChanged: (selection) {
                    setState(() => _showFavorites = selection.first);
                  },
                ),
              ),
            ),
            Expanded(
              child: _showFavorites
                  ? _buildFavorites(context)
                  : _buildExplore(context),
            ),
          ],
        );
      },
    );
  }

  Widget _buildExplore(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final dailyQuote = _dailyQuote;
    final randomQuote = _randomQuote;

    return RefreshIndicator(
      onRefresh: _refreshAll,
      child: ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
        children: <Widget>[
          Row(
            children: <Widget>[
              Expanded(
                child: Text(
                  'Цитата дня',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
              IconButton(
                tooltip: 'Обновить цитату дня',
                onPressed: _dailyLoading ? null : _loadDaily,
                icon: const Icon(Icons.refresh_rounded),
              ),
            ],
          ),
          if (_dailyLoading && dailyQuote == null)
            const InlineLoader(label: 'Получаем цитату дня...')
          else if (_dailyError != null && dailyQuote == null)
            ErrorView(error: _dailyError!, onRetry: _loadDaily, compact: true)
          else if (dailyQuote != null)
            QuoteCard(
              quote: dailyQuote,
              highlighted: true,
              label: 'Цитата дня',
              isFavorite: widget.favoritesStore.isFavorite(dailyQuote),
              onFavorite: () => _toggleFavorite(dailyQuote),
              onCopy: () => copyText(
                context,
                '«${dailyQuote.text}» — ${dailyQuote.author}',
              ),
            ),
          const SizedBox(height: 24),
          SectionHeader(
            title: 'Случайная цитата',
            subtitle: 'Выберите тему или обновите подборку',
            trailing: IconButton(
              tooltip: 'Другая цитата',
              onPressed: _randomLoading ? null : _loadRandom,
              icon: const Icon(Icons.shuffle_rounded),
            ),
          ),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: _categories.map((category) {
                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: ChoiceChip(
                    label: Text(category.label),
                    selected: _category == category.value,
                    showCheckmark: false,
                    onSelected: (_) => _selectCategory(category.value),
                  ),
                );
              }).toList(),
            ),
          ),
          const SizedBox(height: 14),
          if (_randomLoading)
            const InlineLoader(label: 'Подбираем цитату...')
          else if (_randomError != null)
            ErrorView(error: _randomError!, onRetry: _loadRandom, compact: true)
          else if (randomQuote != null)
            QuoteCard(
              quote: randomQuote,
              isFavorite: widget.favoritesStore.isFavorite(randomQuote),
              onFavorite: () => _toggleFavorite(randomQuote),
              onCopy: () => copyText(
                context,
                '«${randomQuote.text}» — ${randomQuote.author}',
              ),
            ),
          if (randomQuote != null) ...<Widget>[
            const SizedBox(height: 14),
            FilledButton.icon(
              onPressed: _randomLoading ? null : _loadRandom,
              icon: const Icon(Icons.auto_awesome_rounded),
              label: const Text('Другая цитата'),
            ),
          ],
          const SizedBox(height: 16),
          Text(
            'Подсказка: смахните список вниз, чтобы обновить обе цитаты.',
            textAlign: TextAlign.center,
            style: Theme.of(
              context,
            ).textTheme.bodySmall?.copyWith(color: scheme.onSurfaceVariant),
          ),
        ],
      ),
    );
  }

  Widget _buildFavorites(BuildContext context) {
    final quotes = widget.favoritesStore.quotes;
    if (quotes.isEmpty) {
      return EmptyState(
        icon: Icons.favorite_border_rounded,
        title: 'Пока пусто',
        message: 'Нажмите на сердечко у цитаты, и она появится здесь.',
        action: OutlinedButton.icon(
          onPressed: () => setState(() => _showFavorites = false),
          icon: const Icon(Icons.explore_outlined),
          label: const Text('Перейти к цитатам'),
        ),
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
      itemCount: quotes.length + 1,
      separatorBuilder: (_, index) => SizedBox(height: index == 0 ? 4 : 12),
      itemBuilder: (context, index) {
        if (index == 0) {
          return SectionHeader(
            title: 'Избранные цитаты',
            subtitle: '${quotes.length} сохранено на устройстве',
            trailing: TextButton.icon(
              onPressed: _clearFavorites,
              icon: const Icon(Icons.delete_outline_rounded, size: 18),
              label: const Text('Очистить'),
            ),
          );
        }
        final quote = quotes[index - 1];
        return Dismissible(
          key: ValueKey<String>(quote.id),
          direction: DismissDirection.endToStart,
          background: Container(
            alignment: Alignment.centerRight,
            padding: const EdgeInsets.only(right: 24),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.errorContainer,
              borderRadius: BorderRadius.circular(24),
            ),
            child: Icon(
              Icons.delete_outline_rounded,
              color: Theme.of(context).colorScheme.onErrorContainer,
            ),
          ),
          onDismissed: (_) => _toggleFavorite(quote),
          child: QuoteCard(
            quote: quote,
            isFavorite: true,
            onFavorite: () => _toggleFavorite(quote),
            onCopy: () =>
                copyText(context, '«${quote.text}» — ${quote.author}'),
          ),
        );
      },
    );
  }
}
