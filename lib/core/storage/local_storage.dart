import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../data/models/quote.dart';
import '../config/app_config.dart';

class LocalStorage {
  LocalStorage(this._preferences);

  final SharedPreferences _preferences;

  static const String _apiKeyKey = 'api_key';
  static const String _themeModeKey = 'theme_mode';
  static const String _favoritesKey = 'favorite_quotes';
  static const String _recentSearchesKey = 'recent_searches';

  String get apiKey {
    final stored = _preferences.getString(_apiKeyKey)?.trim() ?? '';
    return stored.isNotEmpty ? stored : AppConfig.apiKeyFromEnvironment;
  }

  bool get hasStoredApiKey =>
      (_preferences.getString(_apiKeyKey)?.trim() ?? '').isNotEmpty;

  Future<void> setApiKey(String value) =>
      _preferences.setString(_apiKeyKey, value.trim());

  Future<void> clearApiKey() => _preferences.remove(_apiKeyKey);

  ThemeMode get themeMode => switch (_preferences.getString(_themeModeKey)) {
    'light' => ThemeMode.light,
    'dark' => ThemeMode.dark,
    _ => ThemeMode.system,
  };

  Future<void> setThemeMode(ThemeMode mode) =>
      _preferences.setString(_themeModeKey, mode.name);

  List<Quote> get favoriteQuotes {
    final raw = _preferences.getString(_favoritesKey);
    if (raw == null || raw.isEmpty) {
      return <Quote>[];
    }
    try {
      final decoded = jsonDecode(raw);
      if (decoded is! List) {
        return <Quote>[];
      }
      return decoded
          .whereType<Map>()
          .map((item) => Quote.fromJson(Map<String, dynamic>.from(item)))
          .toList();
    } catch (_) {
      return <Quote>[];
    }
  }

  Future<void> saveFavoriteQuotes(List<Quote> quotes) => _preferences.setString(
    _favoritesKey,
    jsonEncode(quotes.map((quote) => quote.toJson()).toList()),
  );

  List<String> get recentSearches {
    final raw = _preferences.getStringList(_recentSearchesKey);
    if (raw == null) {
      return <String>[];
    }
    return raw.where((word) => word.trim().isNotEmpty).toList();
  }

  Future<void> addRecentSearch(String word) async {
    final normalized = word.trim().toLowerCase();
    if (normalized.isEmpty) {
      return;
    }
    final updated = <String>[
      normalized,
      ...recentSearches.where((item) => item != normalized),
    ].take(8).toList();
    await _preferences.setStringList(_recentSearchesKey, updated);
  }

  Future<void> clearRecentSearches() => _preferences.remove(_recentSearchesKey);

  Future<void> clearFavoriteQuotes() => _preferences.remove(_favoritesKey);
}
