import 'package:flutter/material.dart';

class TagList extends StatelessWidget {
  const TagList({super.key, required this.tags, this.onTagTap, this.icon});

  final List<String> tags;
  final ValueChanged<String>? onTagTap;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    if (tags.isEmpty) {
      return const SizedBox.shrink();
    }
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: tags.map((tag) {
        final content = Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              if (icon != null) ...<Widget>[
                Icon(icon, size: 14, color: scheme.onSecondaryContainer),
                const SizedBox(width: 5),
              ],
              Text(
                tag,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: scheme.onSecondaryContainer,
                ),
              ),
            ],
          ),
        );
        return Material(
          color: scheme.secondaryContainer,
          borderRadius: BorderRadius.circular(10),
          child: onTagTap == null
              ? content
              : InkWell(
                  borderRadius: BorderRadius.circular(10),
                  onTap: () => onTagTap!(tag),
                  child: content,
                ),
        );
      }).toList(),
    );
  }
}
