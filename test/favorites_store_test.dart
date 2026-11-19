import 'package:api_ninjas_explorer/core/storage/local_storage.dart';
import 'package:api_ninjas_explorer/data/models/quote.dart';
import 'package:api_ninjas_explorer/state/favorites_store.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('toggles and persists favorite quotes', () async {
    SharedPreferences.setMockInitialValues(<String, Object>{});
    final preferences = await SharedPreferences.getInstance();
    final storage = LocalStorage(preferences);
    final store = FavoritesStore(storage);
    const quote = Quote(
      text: 'Knowledge is power.',
      author: 'Francis Bacon',
      categories: <String>['knowledge'],
    );

    expect(await store.toggle(quote), isTrue);
    expect(store.count, 1);
    expect(store.isFavorite(quote), isTrue);
    expect(storage.favoriteQuotes.single.text, quote.text);

    expect(await store.toggle(quote), isFalse);
    expect(store.count, 0);
    expect(storage.favoriteQuotes, isEmpty);
  });

  test('persists theme and recent searches', () async {
    SharedPreferences.setMockInitialValues(<String, Object>{});
    final preferences = await SharedPreferences.getInstance();
    final storage = LocalStorage(preferences);

    await storage.setThemeMode(ThemeMode.dark);
    await storage.addRecentSearch('Serendipity');
    await storage.addRecentSearch('serendipity');
    await storage.addRecentSearch('ephemeral');

    expect(storage.themeMode, ThemeMode.dark);
    expect(storage.recentSearches, <String>['ephemeral', 'serendipity']);

    await storage.clearRecentSearches();
    expect(storage.recentSearches, isEmpty);
  });
}
