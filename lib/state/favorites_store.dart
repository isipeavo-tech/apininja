import 'package:flutter/foundation.dart';

import '../../core/storage/local_storage.dart';
import '../../data/models/quote.dart';

class FavoritesStore extends ChangeNotifier {
  FavoritesStore(this._storage) : _quotes = _storage.favoriteQuotes;

  final LocalStorage _storage;
  final List<Quote> _quotes;

  List<Quote> get quotes => List<Quote>.unmodifiable(_quotes);

  int get count => _quotes.length;

  bool isFavorite(Quote quote) => _quotes.any((item) => item.id == quote.id);

  Future<bool> toggle(Quote quote) async {
    final index = _quotes.indexWhere((item) => item.id == quote.id);
    final added = index < 0;
    if (added) {
      _quotes.insert(0, quote);
    } else {
      _quotes.removeAt(index);
    }
    notifyListeners();
    await _storage.saveFavoriteQuotes(_quotes);
    return added;
  }

  Future<void> remove(Quote quote) async {
    _quotes.removeWhere((item) => item.id == quote.id);
    notifyListeners();
    await _storage.saveFavoriteQuotes(_quotes);
  }

  Future<void> clear() async {
    _quotes.clear();
    notifyListeners();
    await _storage.clearFavoriteQuotes();
  }
}
