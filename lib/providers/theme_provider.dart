import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Modos disponibles para el tema
enum AppThemeMode {
  system,  // Sigue el sistema operativo
  light,   // Siempre claro
  dark,    // Siempre oscuro
}

class ThemeProvider extends ChangeNotifier {
  static const _prefKey = 'theme_mode';

  AppThemeMode _mode = AppThemeMode.system;
  bool _isInitializing = true;

  AppThemeMode get mode => _mode;
  bool get isInitializing => _isInitializing;

  ThemeProvider() {
    _loadFromPrefs();
  }

  // ──────────────────────────────────────────────────────
  // ThemeMode que le pasamos a MaterialApp
  // ──────────────────────────────────────────────────────
  ThemeMode get themeMode {
    switch (_mode) {
      case AppThemeMode.system:
        return ThemeMode.system;
      case AppThemeMode.light:
        return ThemeMode.light;
      case AppThemeMode.dark:
        return ThemeMode.dark;
    }
  }

  // ──────────────────────────────────────────────────────
  // Cambiar modo
  // ──────────────────────────────────────────────────────
  Future<void> setMode(AppThemeMode mode) async {
    if (_mode == mode) return;
    _mode = mode;
    notifyListeners();
    await _saveToPrefs();
  }

  // Shortcut para el toggle simple dark/light desde cualquier lugar
  Future<void> toggleDarkLight() async {
    if (_mode == AppThemeMode.dark) {
      await setMode(AppThemeMode.light);
    } else {
      await setMode(AppThemeMode.dark);
    }
  }

  // ──────────────────────────────────────────────────────
  // Persistencia
  // ──────────────────────────────────────────────────────
  Future<void> _loadFromPrefs() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final saved = prefs.getString(_prefKey);
      _mode = _modeFromString(saved);
    } catch (_) {
      _mode = AppThemeMode.system;
    } finally {
      _isInitializing = false;
      notifyListeners();
    }
  }

  Future<void> _saveToPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_prefKey, _modeToString(_mode));
  }

  // ──────────────────────────────────────────────────────
  // Helpers
  // ──────────────────────────────────────────────────────
  static String _modeToString(AppThemeMode mode) {
    switch (mode) {
      case AppThemeMode.system:
        return 'system';
      case AppThemeMode.light:
        return 'light';
      case AppThemeMode.dark:
        return 'dark';
    }
  }

  static AppThemeMode _modeFromString(String? value) {
    switch (value) {
      case 'light':
        return AppThemeMode.light;
      case 'dark':
        return AppThemeMode.dark;
      default:
        return AppThemeMode.system;
    }
  }

  /// Label legible para mostrar en UI
  String get modeLabel {
    switch (_mode) {
      case AppThemeMode.system:
        return 'Automático';
      case AppThemeMode.light:
        return 'Claro';
      case AppThemeMode.dark:
        return 'Oscuro';
    }
  }

  IconData get modeIcon {
    switch (_mode) {
      case AppThemeMode.system:
        return Icons.brightness_auto;
      case AppThemeMode.light:
        return Icons.light_mode_outlined;
      case AppThemeMode.dark:
        return Icons.dark_mode_outlined;
    }
  }
}