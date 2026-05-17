import 'package:flutter_test/flutter_test.dart';
import 'package:travel_tip_calc/config/ad_config.dart';

void main() {
  group('AdConfig', () {
    test('uses Google demo banner units outside release builds', () {
      expect(
        AdConfig.resolveBannerAdUnitId(
          isIOS: true,
          isRelease: false,
          productionIOSAdUnitId: '',
          productionAndroidAdUnitId: '',
        ),
        'ca-app-pub-3940256099942544/2934735716',
      );

      expect(
        AdConfig.resolveBannerAdUnitId(
          isIOS: false,
          isRelease: false,
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
          productionIOSAdUnitId: 'ios-unit',
          productionAndroidAdUnitId: 'android-unit',
        ),
        'ios-unit',
      );

      expect(
        AdConfig.resolveBannerAdUnitId(
          isIOS: false,
          isRelease: true,
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
          productionIOSAdUnitId: '',
          productionAndroidAdUnitId: 'android-unit',
        ),
        '',
      );

      expect(
        AdConfig.resolveBannerAdUnitId(
          isIOS: false,
          isRelease: true,
          productionIOSAdUnitId: 'ios-unit',
          productionAndroidAdUnitId: '',
        ),
        '',
      );
    });
  });
}
