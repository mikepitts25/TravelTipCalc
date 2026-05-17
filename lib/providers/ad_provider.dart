import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../config/ad_config.dart';
import 'preferences_provider.dart';

/// Whether to show ads (false if user is Pro).
final showAdsProvider = Provider<bool>((ref) {
  final isPro = ref.watch(proStatusProvider);
  return AdConfig.canShowBannerAds && !isPro;
});
