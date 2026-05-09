import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../config/ad_config.dart';
import 'preferences_provider.dart';

/// Whether to show ads (false if user is Pro).
/// Ads are disabled until AdMob App ID is configured in native projects.
final showAdsProvider = Provider<bool>((ref) {
  final isPro = ref.watch(proStatusProvider);
  final adsConfigured = AdConfig.bannerAdUnitId.isNotEmpty;
  return adsConfigured && !isPro;
});
