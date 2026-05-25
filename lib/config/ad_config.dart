import 'package:flutter/foundation.dart';

class AdConfig {
  static const String _testIOSBannerAdUnitId =
      'ca-app-pub-3940256099942544/2934735716';
  static const String _testAndroidBannerAdUnitId =
      'ca-app-pub-3940256099942544/6300978111';

  // Supply production units at release build time:
  // --dart-define=ADMOB_IOS_BANNER_AD_UNIT_ID=ca-app-pub-.../...
  // --dart-define=ADMOB_ANDROID_BANNER_AD_UNIT_ID=ca-app-pub-.../...
  // Use Google's test banner units in release builds for TestFlight/beta QA:
  // --dart-define=ADMOB_USE_TEST_ADS=true
  // Hide banner ads for App Store screenshot capture builds:
  // --dart-define=HIDE_ADS_FOR_SCREENSHOTS=true
  static const bool _useTestAds = bool.fromEnvironment(
    'ADMOB_USE_TEST_ADS',
    defaultValue: false,
  );
  static const bool _hideAdsForScreenshots = bool.fromEnvironment(
    'HIDE_ADS_FOR_SCREENSHOTS',
    defaultValue: false,
  );
  static const String _productionIOSBannerAdUnitId = String.fromEnvironment(
    'ADMOB_IOS_BANNER_AD_UNIT_ID',
    defaultValue: '',
  );
  static const String _productionAndroidBannerAdUnitId = String.fromEnvironment(
    'ADMOB_ANDROID_BANNER_AD_UNIT_ID',
    defaultValue: '',
  );

  static String get bannerAdUnitId {
    final platform = defaultTargetPlatform;
    if (platform != TargetPlatform.iOS && platform != TargetPlatform.android) {
      return '';
    }

    return resolveBannerAdUnitId(
      isIOS: platform == TargetPlatform.iOS,
      isRelease: kReleaseMode,
      useTestAds: _useTestAds,
      hideAdsForScreenshots: _hideAdsForScreenshots,
      productionIOSAdUnitId: _productionIOSBannerAdUnitId,
      productionAndroidAdUnitId: _productionAndroidBannerAdUnitId,
    );
  }

  static bool get canShowBannerAds => bannerAdUnitId.isNotEmpty;

  static String resolveBannerAdUnitId({
    required bool isIOS,
    required bool isRelease,
    required bool useTestAds,
    bool hideAdsForScreenshots = false,
    required String productionIOSAdUnitId,
    required String productionAndroidAdUnitId,
  }) {
    if (hideAdsForScreenshots) {
      return '';
    }

    if (!isRelease || useTestAds) {
      return isIOS ? _testIOSBannerAdUnitId : _testAndroidBannerAdUnitId;
    }

    return isIOS ? productionIOSAdUnitId : productionAndroidAdUnitId;
  }

  // Ad placement: only on these screens
  static const bool showAdOnCalculator = true;
  static const bool showAdOnCountryPicker = false;
  static const bool showAdOnSettings = false;
  static const bool showAdOnCountryDetail = false;
}
