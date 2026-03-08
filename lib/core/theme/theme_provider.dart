import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Theme Provider sederhana tanpa Riverpod
class ThemeProvider extends ChangeNotifier {
  static const String _keyThemeMode = 'theme_mode';

  ThemeMode _themeMode = ThemeMode.system;

  ThemeMode get themeMode => _themeMode;

  bool get isDarkMode {
    if (_themeMode == ThemeMode.dark) return true;
    if (_themeMode == ThemeMode.light) return false;
    // System mode - fallback ke false (light)
    return false;
  }

  ThemeProvider() {
    _loadThemeMode();
  }

  Future<void> _loadThemeMode() async {
    final prefs = await SharedPreferences.getInstance();
    // Handle potential type mismatch from previous versions
    final themeModeIndex = prefs.getInt(_keyThemeMode) ?? 2;
    _themeMode = ThemeMode.values[themeModeIndex.clamp(0, 2)];
    notifyListeners();
  }

  Future<void> setThemeMode(ThemeMode mode) async {
    _themeMode = mode;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_keyThemeMode, mode.index);
    notifyListeners();
  }

  Future<void> toggleDarkMode(bool isDark) async {
    _themeMode = isDark ? ThemeMode.dark : ThemeMode.light;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_keyThemeMode, _themeMode.index);
    notifyListeners();
  }
}
