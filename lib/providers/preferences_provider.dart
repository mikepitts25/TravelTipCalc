import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../data/repositories/preferences_repository.dart';

/// Async provider for SharedPreferences initialization.
final sharedPreferencesProvider = FutureProvider<SharedPreferences>(
  (ref) => SharedPreferences.getInstance(),
);

/// Provider for the preferences repository.
final preferencesRepositoryProvider = Provider<PreferencesRepository?>((ref) {
  final prefsAsync = ref.watch(sharedPreferencesProvider);
  return prefsAsync.whenOrNull(
    data: (prefs) => PreferencesRepository(prefs),
  );
});

/// Theme mode provider.
enum AppThemeMode { light, dark, system }

class ThemeNotifier extends StateNotifier<AppThemeMode> {
  final PreferencesRepository? _prefs;

  ThemeNotifier(this._prefs)
      : super(_themeFromString(_prefs?.theme ?? 'dark'));

  static AppThemeMode _themeFromString(String value) {
    switch (value) {
      case 'light':
        return AppThemeMode.light;
      case 'system':
        return AppThemeMode.system;
      default:
        return AppThemeMode.dark;
    }
  }

  void setTheme(AppThemeMode mode) {
    state = mode;
    _prefs?.setTheme(mode.name);
  }
}

final themeProvider = StateNotifierProvider<ThemeNotifier, AppThemeMode>(
  (ref) {
    final prefs = ref.watch(preferencesRepositoryProvider);
    return ThemeNotifier(prefs);
  },
);

/// Pro status provider.
class ProStatusNotifier extends StateNotifier<bool> {
  final PreferencesRepository? _prefs;

  ProStatusNotifier(this._prefs) : super(_prefs?.isPro ?? false);

  void setPro(bool value) {
    state = value;
    _prefs?.setIsPro(value);
  }
}

final proStatusProvider = StateNotifierProvider<ProStatusNotifier, bool>(
  (ref) {
    final prefs = ref.watch(preferencesRepositoryProvider);
    return ProStatusNotifier(prefs);
  },
);

/// Home currency provider (user's preferred display currency).
class HomeCurrencyNotifier extends StateNotifier<String> {
  final PreferencesRepository? _prefs;

  HomeCurrencyNotifier(this._prefs) : super(_prefs?.homeCurrency ?? 'USD');

  void setCurrency(String code) {
    state = code;
    _prefs?.setHomeCurrency(code);
  }
}

final homeCurrencyProvider =
    StateNotifierProvider<HomeCurrencyNotifier, String>(
  (ref) {
    final prefs = ref.watch(preferencesRepositoryProvider);
    return HomeCurrencyNotifier(prefs);
  },
);
