import 'package:flutter/material.dart';

import '../../core/network/api_exception.dart';
import '../../data/models/fact.dart';
import '../../data/repositories/api_ninjas_repository.dart';
import '../../widgets/app_feedback.dart';
import '../../widgets/section_header.dart';

class FactsPage extends StatefulWidget {
  const FactsPage({super.key, required this.repository});

  final ApiNinjasRepository repository;

  @override
  State<FactsPage> createState() => _FactsPageState();
}

class _FactsPageState extends State<FactsPage> {
  final List<Fact> _facts = <Fact>[];
  Fact? _factOfDay;
  bool _feedLoading = false;
  bool _dailyLoading = false;
  ApiException? _feedError;
  ApiException? _dailyError;

  @override
  void initState() {
    super.initState();
    _loadFactOfDay();
    _loadFact();
  }

  Future<void> _loadFactOfDay() async {
    setState(() {
      _dailyLoading = true;
      _dailyError = null;
    });
    try {
      final fact = await widget.repository.getFactOfTheDay();
      if (mounted) {
        setState(() => _factOfDay = fact);
      }
    } on ApiException catch (error) {
      if (mounted) {
        setState(() => _dailyError = error);
      }
    } catch (_) {
      if (mounted) {
        setState(
          () =>
              _dailyError = const ApiException('Не удалось получить факт дня.'),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _dailyLoading = false);
      }
    }
  }

  Future<void> _loadFact() async {
    if (_feedLoading) {
      return;
    }
    setState(() {
      _feedLoading = true;
      _feedError = null;
    });
    try {
      final fact = await widget.repository.getRandomFact();
      if (mounted) {
        setState(() => _facts.insert(0, fact));
      }
    } on ApiException catch (error) {
      if (mounted) {
        setState(() => _feedError = error);
      }
    } catch (_) {
      if (mounted) {
        setState(
          () => _feedError = const ApiException('Не удалось получить факт.'),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _feedLoading = false);
      }
    }
  }

  Future<void> _refreshAll() async {
    await Future.wait(<Future<void>>[_loadFactOfDay(), _loadFact()]);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final dailyFact = _factOfDay;

    return RefreshIndicator(
      onRefresh: _refreshAll,
      child: ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
        children: <Widget>[
          Row(
            children: <Widget>[
              Expanded(
                child: Text(
                  'Факт дня',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
              IconButton(
                tooltip: 'Обновить факт дня',
                onPressed: _dailyLoading ? null : _loadFactOfDay,
                icon: const Icon(Icons.refresh_rounded),
              ),
            ],
          ),
          if (_dailyLoading && dailyFact == null)
            const InlineLoader(label: 'Получаем факт дня...')
          else if (_dailyError != null && dailyFact == null)
            ErrorView(
              error: _dailyError!,
              onRetry: _loadFactOfDay,
              compact: true,
            )
          else if (dailyFact != null)
            _FactCard(
              fact: dailyFact,
              highlighted: true,
              onCopy: () =>
                  copyText(context, dailyFact.text, message: 'Факт скопирован'),
            ),
          const SizedBox(height: 24),
          SectionHeader(
            title: 'Случайные факты',
            subtitle: _facts.isEmpty
                ? 'Пополняйте коллекцию интересных фактов'
                : 'В ленте: ${_facts.length}',
            trailing: IconButton(
              tooltip: 'Ещё факт',
              onPressed: _feedLoading ? null : _loadFact,
              icon: const Icon(Icons.shuffle_rounded),
            ),
          ),
          if (_feedError != null)
            Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: ErrorView(
                error: _feedError!,
                onRetry: _feedLoading ? null : _loadFact,
                compact: true,
              ),
            ),
          if (_feedLoading && _facts.isEmpty)
            const InlineLoader(label: 'Загружаем факт...')
          else if (_facts.isEmpty && _feedError == null)
            const EmptyState(
              icon: Icons.science_outlined,
              title: 'Фактов пока нет',
              message: 'Нажмите «Ещё факт», чтобы добавить первый.',
            ),
          for (int index = 0; index < _facts.length; index++) ...<Widget>[
            _FactCard(
              fact: _facts[index],
              onCopy: () => copyText(
                context,
                _facts[index].text,
                message: 'Факт скопирован',
              ),
            ),
            if (index != _facts.length - 1) const SizedBox(height: 12),
          ],
          const SizedBox(height: 18),
          FilledButton.icon(
            onPressed: _feedLoading ? null : _loadFact,
            icon: _feedLoading
                ? const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Icon(Icons.add_rounded),
            label: Text(_feedLoading ? 'Загружаем...' : 'Ещё факт'),
          ),
          const SizedBox(height: 12),
          Text(
            'Факты приходят на английском языке. Потяните список вниз, '
            'чтобы обновить факт дня и ленту.',
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

class _FactCard extends StatelessWidget {
  const _FactCard({
    required this.fact,
    required this.onCopy,
    this.highlighted = false,
  });

  final Fact fact;
  final VoidCallback onCopy;
  final bool highlighted;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final foreground = highlighted
        ? scheme.onSecondaryContainer
        : scheme.onSurface;
    final muted = highlighted
        ? scheme.onSecondaryContainer.withValues(alpha: 0.72)
        : scheme.onSurfaceVariant;

    return Card(
      color: highlighted ? scheme.secondaryContainer : null,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 16, 12, 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Row(
              children: <Widget>[
                Icon(Icons.science_rounded, size: 20, color: muted),
                const SizedBox(width: 8),
                Text(
                  highlighted ? 'FACT OF THE DAY' : 'FACT',
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: muted,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 1.1,
                  ),
                ),
                const Spacer(),
                IconButton(
                  tooltip: 'Копировать факт',
                  onPressed: onCopy,
                  icon: Icon(Icons.copy_rounded, size: 20, color: muted),
                ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.only(right: 8),
              child: Text(
                fact.text,
                style: theme.textTheme.bodyLarge?.copyWith(
                  height: 1.55,
                  fontWeight: FontWeight.w500,
                  color: foreground,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
