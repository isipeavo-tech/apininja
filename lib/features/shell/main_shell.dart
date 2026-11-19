import 'package:flutter/material.dart';

import '../../core/storage/local_storage.dart';
import '../../data/repositories/api_ninjas_repository.dart';
import '../../state/auth_store.dart';
import '../../state/favorites_store.dart';
import '../../state/settings_controller.dart';
import '../dictionary/dictionary_page.dart';
import '../facts/facts_page.dart';
import '../jokes/jokes_page.dart';
import '../quotes/quotes_page.dart';
import '../settings/settings_page.dart';

class MainShell extends StatefulWidget {
  const MainShell({
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
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  static const List<String> _titles = <String>[
    'Цитаты',
    'Шутки',
    'Факты',
    'Словарь',
    'Настройки',
  ];

  int _index = 0;
  final Set<int> _visited = <int>{0};

  void _selectTab(int index) {
    if (_index == index) {
      return;
    }
    setState(() {
      _index = index;
      _visited.add(index);
    });
  }

  Widget _pageAt(int index) {
    return switch (index) {
      0 => QuotesPage(
        repository: widget.repository,
        favoritesStore: widget.favoritesStore,
      ),
      1 => JokesPage(repository: widget.repository),
      2 => FactsPage(repository: widget.repository),
      3 => DictionaryPage(
        repository: widget.repository,
        storage: widget.storage,
      ),
      4 => SettingsPage(
        authStore: widget.authStore,
        settingsController: widget.settingsController,
        favoritesStore: widget.favoritesStore,
        storage: widget.storage,
        repository: widget.repository,
      ),
      _ => const SizedBox.shrink(),
    };
  }

  @override
  Widget build(BuildContext context) {
    return PopScope<Object?>(
      canPop: _index == 0,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop && _index != 0) {
          _selectTab(0);
        }
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text(_titles[_index]),
          actions: <Widget>[
            Padding(
              padding: const EdgeInsets.only(right: 8),
              child: Builder(
                builder: (context) {
                  final scheme = Theme.of(context).colorScheme;
                  return Chip(
                    visualDensity: VisualDensity.compact,
                    avatar: Icon(
                      Icons.auto_awesome_rounded,
                      size: 16,
                      color: scheme.onSecondaryContainer,
                    ),
                    label: Text(
                      'API Ninjas',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        color: scheme.onSecondaryContainer,
                      ),
                    ),
                    backgroundColor: scheme.secondaryContainer,
                  );
                },
              ),
            ),
          ],
        ),
        body: SafeArea(
          top: false,
          child: IndexedStack(
            index: _index,
            children: List<Widget>.generate(
              5,
              (index) => _visited.contains(index)
                  ? _pageAt(index)
                  : const SizedBox.shrink(),
            ),
          ),
        ),
        bottomNavigationBar: NavigationBar(
          selectedIndex: _index,
          onDestinationSelected: _selectTab,
          destinations: const <NavigationDestination>[
            NavigationDestination(
              icon: Icon(Icons.format_quote_outlined),
              selectedIcon: Icon(Icons.format_quote_rounded),
              label: 'Цитаты',
            ),
            NavigationDestination(
              icon: Icon(Icons.sentiment_very_satisfied_outlined),
              selectedIcon: Icon(Icons.sentiment_very_satisfied_rounded),
              label: 'Шутки',
            ),
            NavigationDestination(
              icon: Icon(Icons.science_outlined),
              selectedIcon: Icon(Icons.science_rounded),
              label: 'Факты',
            ),
            NavigationDestination(
              icon: Icon(Icons.menu_book_outlined),
              selectedIcon: Icon(Icons.menu_book_rounded),
              label: 'Словарь',
            ),
            NavigationDestination(
              icon: Icon(Icons.settings_outlined),
              selectedIcon: Icon(Icons.settings_rounded),
              label: 'Настройки',
            ),
          ],
        ),
      ),
    );
  }
}
