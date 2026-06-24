import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

const _kPrefKey = 'theme_mode';

final themeModeProvider =
    StateNotifierProvider<ThemeModeNotifier, ThemeMode>(
  (ref) => ThemeModeNotifier(),
);

class ThemeModeNotifier extends StateNotifier<ThemeMode> {
  ThemeModeNotifier() : super(ThemeMode.dark) {
    _load();
  }

  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    final saved = prefs.getString(_kPrefKey);
    if (saved != null) {
      state = _fromString(saved);
    }
  }

  Future<void> setMode(ThemeMode mode) async {
    state = mode;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_kPrefKey, _toString(mode));
  }

  void toggle() {
    switch (state) {
      case ThemeMode.dark:
        setMode(ThemeMode.light);
      case ThemeMode.light:
        setMode(ThemeMode.system);
      case ThemeMode.system:
        setMode(ThemeMode.dark);
    }
  }

  static String _toString(ThemeMode m) {
    return switch (m) {
      ThemeMode.dark => 'dark',
      ThemeMode.light => 'light',
      ThemeMode.system => 'system',
    };
  }

  static ThemeMode _fromString(String s) {
    return switch (s) {
      'light' => ThemeMode.light,
      'system' => ThemeMode.system,
      _ => ThemeMode.dark,
    };
  }
}
