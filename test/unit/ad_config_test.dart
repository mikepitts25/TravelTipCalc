import 'package:flutter_test/flutter_test.dart';
import 'package:travel_tip_calc/config/ad_config.dart';

void main() {
  group('AdConfig', () {
    test('uses Google demo banner units outside release builds', () {
      expect(
        AdConfig.resolveBannerAdUnitId(
          isIOS: true,
          isRelease: false,
          useTestAds: false,
          productionIOSAdUnitId: '',
          productionAndroidAdUnitId: '',
        ),
        'ca-app-pub-3940256099942544/2934735716',
      );

      expect(
        AdConfig.resolveBannerAdUnitId(
          isIOS: false,
          isRelease: false,
          useTestAds: false,
          productionIOSAdUnitId: '',
          productionAndroidAdUnitId: '',
        ),
        'ca-app-pub-3940256099942544/6300978111',
      );
    });

    test('uses production banner units in release builds', () {
      expect(
        AdConfig.resolveBannerAdUnitId(
          isIOS: true,
          isRelease: true,
          useTestAds: false,
          productionIOSAdUnitId: 'ios-unit',
          productionAndroidAdUnitId: 'android-unit',
        ),
        'ios-unit',
      );

      expect(
        AdConfig.resolveBannerAdUnitId(
          isIOS: false,
          isRelease: true,
          useTestAds: false,
          productionIOSAdUnitId: 'ios-unit',
          productionAndroidAdUnitId: 'android-unit',
        ),
        'android-unit',
      );
    });

    test('does not show ads on release builds without production units', () {
      expect(
        AdConfig.resolveBannerAdUnitId(
          isIOS: true,
          isRelease: true,
          useTestAds: false,
          productionIOSAdUnitId: '',
          productionAndroidAdUnitId: 'android-unit',
        ),
        '',
      );

      expect(
        AdConfig.resolveBannerAdUnitId(
          isIOS: false,
          isRelease: true,
          useTestAds: false,
          productionIOSAdUnitId: 'ios-unit',
          productionAndroidAdUnitId: '',
        ),
        '',
      );
    });

    test('can force Google demo banner units for release QA builds', () {
      expect(
        AdConfig.resolveBannerAdUnitId(
          isIOS: true,
          isRelease: true,
          useTestAds: true,
          hideAdsForScreenshots: false,
          productionIOSAdUnitId: 'ios-unit',
          productionAndroidAdUnitId: 'android-unit',
        ),
        'ca-app-pub-3940256099942544/2934735716',
      );

      expect(
        AdConfig.resolveBannerAdUnitId(
          isIOS: false,
          isRelease: true,
          useTestAds: true,
          hideAdsForScreenshots: false,
          productionIOSAdUnitId: 'ios-unit',
          productionAndroidAdUnitId: 'android-unit',
        ),
        'ca-app-pub-3940256099942544/6300978111',
      );
    });

    test('can hide banner ads for screenshot builds', () {
      expect(
        AdConfig.resolveBannerAdUnitId(
          isIOS: true,
          isRelease: false,
          useTestAds: false,
          hideAdsForScreenshots: true,
          productionIOSAdUnitId: 'ios-unit',
          productionAndroidAdUnitId: 'android-unit',
        ),
        '',
      );

      expect(
        AdConfig.resolveBannerAdUnitId(
          isIOS: false,
          isRelease: true,
          useTestAds: true,
          hideAdsForScreenshots: true,
          productionIOSAdUnitId: 'ios-unit',
          productionAndroidAdUnitId: 'android-unit',
        ),
        '',
      );
    });
  });
}
