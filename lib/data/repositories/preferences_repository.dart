import 'package:shared_preferences/shared_preferences.dart';

class PreferencesRepository {
  static const _themeKey = 'theme';
  static const _defaultTipKey = 'default_tip_percent';
  static const _lastCountryKey = 'last_country';
  static const _isProKey = 'is_pro';
  static const _homeCurrencyKey = 'home_currency';

  final SharedPreferences _prefs;

  PreferencesRepository(this._prefs);

  // Theme
  String get theme => _prefs.getString(_themeKey) ?? 'dark';
  Future<void> setTheme(String value) => _prefs.setString(_themeKey, value);

  // Default tip percent
  double get defaultTipPercent =>
      _prefs.getDouble(_defaultTipKey) ?? 18.0;
  Future<void> setDefaultTipPercent(double value) =>
      _prefs.setDouble(_defaultTipKey, value);

  // Last country
  String? get lastCountry => _prefs.getString(_lastCountryKey);
  Future<void> setLastCountry(String id) =>
      _prefs.setString(_lastCountryKey, id);

  // Pro status
  bool get isPro => _prefs.getBool(_isProKey) ?? false;
  Future<void> setIsPro(bool value) => _prefs.setBool(_isProKey, value);

  // Home currency (user's preferred display currency)
  String get homeCurrency => _prefs.getString(_homeCurrencyKey) ?? 'USD';
  Future<void> setHomeCurrency(String code) =>
      _prefs.setString(_homeCurrencyKey, code);

  // Per-country/service last tip percentage
  String _lastTipKey(String countryId, String serviceType) =>
      'last_tip_${countryId}_$serviceType';

  double? getLastTip(String countryId, String serviceType) =>
      _prefs.getDouble(_lastTipKey(countryId, serviceType));

  Future<void> setLastTip(
    String countryId,
    String serviceType,
    double percent,
  ) =>
      _prefs.setDouble(_lastTipKey(countryId, serviceType), percent);
}
