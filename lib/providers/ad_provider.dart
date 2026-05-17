import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../config/ad_config.dart';

/// Whether the current app build can show banner ads.
final showAdsProvider = Provider<bool>((ref) {
  return AdConfig.canShowBannerAds;
});
