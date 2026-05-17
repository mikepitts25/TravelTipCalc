import 'package:flutter/foundation.dart';

class AdConfig {
  static const String _testIOSBannerAdUnitId =
      'ca-app-pub-3940256099942544/2934735716';
  static const String _testAndroidBannerAdUnitId =
      'ca-app-pub-3940256099942544/6300978111';

  // Supply production units at release build time:
  // --dart-define=ADMOB_IOS_BANNER_AD_UNIT_ID=ca-app-pub-.../...
  // --dart-define=ADMOB_ANDROID_BANNER_AD_UNIT_ID=ca-app-pub-.../...
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
      productionIOSAdUnitId: _productionIOSBannerAdUnitId,
      productionAndroidAdUnitId: _productionAndroidBannerAdUnitId,
    );
  }

  static bool get canShowBannerAds => bannerAdUnitId.isNotEmpty;

  static String resolveBannerAdUnitId({
    required bool isIOS,
    required bool isRelease,
    required String productionIOSAdUnitId,
    required String productionAndroidAdUnitId,
  }) {
    if (!isRelease) {
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
