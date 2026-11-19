import 'package:flutter/foundation.dart';

import '../core/config/app_config.dart';
import '../core/storage/local_storage.dart';

class AuthStore extends ChangeNotifier {
  AuthStore(this._storage) : _apiKey = _storage.apiKey;

  final LocalStorage _storage;
  String _apiKey;

  String get apiKey => _apiKey;

  bool get isConfigured => _apiKey.trim().isNotEmpty;

  Future<void> saveApiKey(String value) async {
    final normalized = value.trim();
    await _storage.setApiKey(normalized);
    _apiKey = normalized.isNotEmpty
        ? normalized
        : AppConfig.apiKeyFromEnvironment;
    notifyListeners();
  }

  Future<void> clearApiKey() async {
    await _storage.clearApiKey();
    _apiKey = AppConfig.apiKeyFromEnvironment;
    notifyListeners();
  }
}
