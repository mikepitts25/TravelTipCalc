class AppConstants {
  static const String appName = 'TravelTipCalc';
  static const String appVersion = '1.0.0';
  static const String appStoreReviewUrl =
      'https://apps.apple.com/app/id6767832527?action=write-review';

  // Default values
  static const double defaultTipPercent = 15.0;
  static const int defaultSplitCount = 1;
  static const int maxSplitCount = 20;
  static const int minSplitCount = 1;
  static const String defaultCountry = 'US';

  // Quick tip percentages shown as presets
  static const List<double> quickTipPresets = [5, 10, 15, 20];
}
