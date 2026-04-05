class AdConfig {
  // Replace these with your real AdMob unit IDs before release.
  // These are Google's official test ad unit IDs for development.

  static String get bannerAdUnitId {
    // Stubbed until google_mobile_ads is re-enabled in pubspec.yaml
    return '';
  }

  // Ad placement: only on these screens
  static const bool showAdOnCalculator = true;
  static const bool showAdOnCountryPicker = true;
  static const bool showAdOnSettings = false;
  static const bool showAdOnCountryDetail = false;
}
