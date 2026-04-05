import 'dart:io';

class AdConfig {
  // Replace these with your real AdMob unit IDs before release.
  // These are Google's official test ad unit IDs for development.

  static String get bannerAdUnitId {
    if (Platform.isAndroid) {
      return 'ca-app-pub-3940256099942544/6300978111'; // Android test
    } else if (Platform.isIOS) {
      return 'ca-app-pub-3940256099942544/2934735716'; // iOS test
    }
    return '';
  }

  // Ad placement: only on these screens
  static const bool showAdOnCalculator = true;
  static const bool showAdOnCountryPicker = true;
  static const bool showAdOnSettings = false;
  static const bool showAdOnCountryDetail = false;
}
