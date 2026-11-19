import 'package:flutter/material.dart';

import '../core/storage/local_storage.dart';

class SettingsController extends ChangeNotifier {
  SettingsController(this._storage) : _themeMode = _storage.themeMode;

  final LocalStorage _storage;
  ThemeMode _themeMode;

  ThemeMode get themeMode => _themeMode;

  Future<void> setThemeMode(ThemeMode mode) async {
    if (_themeMode == mode) {
      return;
    }
    _themeMode = mode;
    notifyListeners();
    await _storage.setThemeMode(mode);
  }
}
