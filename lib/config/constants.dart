class AppConstants {
  static const String appName = 'TravelTipCalc';
  static const String appVersion = '1.0.0';

  // Default values
  static const double defaultTipPercent = 18.0;
  static const int defaultSplitCount = 1;
  static const int maxSplitCount = 20;
  static const int minSplitCount = 1;
  static const String defaultCountry = 'US';

  // Quick tip percentages shown as presets
  static const List<double> quickTipPresets = [10, 15, 18, 20, 25];

  // IAP product ID
  static const String proProductId = 'travel_tip_calc_pro';
  static const double proPrice = 4.99;
}
