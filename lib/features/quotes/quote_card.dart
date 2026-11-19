import 'package:flutter/material.dart';

import '../../data/models/quote.dart';

class QuoteCard extends StatelessWidget {
  const QuoteCard({
    super.key,
    required this.quote,
    this.isFavorite = false,
    this.onFavorite,
    this.onCopy,
    this.label,
    this.highlighted = false,
  });

  final Quote quote;
  final bool isFavorite;
  final VoidCallback? onFavorite;
  final VoidCallback? onCopy;
  final String? label;
  final bool highlighted;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final background = highlighted
        ? scheme.primaryContainer
        : scheme.surfaceContainerLow;
    final foreground = highlighted
        ? scheme.onPrimaryContainer
        : scheme.onSurface;
    final muted = highlighted
        ? scheme.onPrimaryContainer.withValues(alpha: 0.72)
        : scheme.onSurfaceVariant;

    return Card(
      color: background,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Row(
              children: <Widget>[
                Icon(Icons.format_quote_rounded, color: muted, size: 22),
                if (label != null) ...<Widget>[
                  const SizedBox(width: 8),
                  Text(
                    label!,
                    style: textTheme.labelLarge?.copyWith(
                      color: muted,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 0.2,
                    ),
                  ),
                ],
                const Spacer(),
                if (onFavorite != null)
                  IconButton(
                    tooltip: isFavorite
                        ? 'Убрать из избранного'
                        : 'Добавить в избранное',
                    onPressed: onFavorite,
                    icon: Icon(
                      isFavorite
                          ? Icons.favorite_rounded
                          : Icons.favorite_border_rounded,
                      color: isFavorite ? scheme.error : muted,
                    ),
                  ),
              ],
            ),
            Text(
              '«${quote.text}»',
              style: textTheme.titleMedium?.copyWith(
                color: foreground,
                fontWeight: FontWeight.w600,
                height: 1.5,
              ),
            ),
            const SizedBox(height: 14),
            Text(
              '— ${quote.author}',
              style: textTheme.bodyMedium?.copyWith(
                color: foreground,
                fontWeight: FontWeight.w700,
              ),
            ),
            if (quote.work.isNotEmpty) ...<Widget>[
              const SizedBox(height: 2),
              Text(
                quote.work,
                style: textTheme.bodySmall?.copyWith(color: muted),
              ),
            ],
            if (quote.categories.isNotEmpty) ...<Widget>[
              const SizedBox(height: 12),
              Wrap(
                spacing: 6,
                runSpacing: 6,
                children: quote.categories.take(5).map((category) {
                  return Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 9,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: muted.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      category,
                      style: textTheme.labelSmall?.copyWith(color: muted),
                    ),
                  );
                }).toList(),
              ),
            ],
            if (onCopy != null) ...<Widget>[
              const SizedBox(height: 6),
              Row(
                children: <Widget>[
                  TextButton.icon(
                    style: TextButton.styleFrom(foregroundColor: foreground),
                    onPressed: onCopy,
                    icon: const Icon(Icons.copy_rounded, size: 18),
                    label: const Text('Копировать'),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }
}
