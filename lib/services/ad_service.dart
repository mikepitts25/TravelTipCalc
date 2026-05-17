import 'package:google_mobile_ads/google_mobile_ads.dart';

/// Manages AdMob initialization and lifecycle.
class AdService {
  static Future<void> initialize() async {
    await MobileAds.instance.initialize();
  }
}
