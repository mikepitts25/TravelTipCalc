import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

import '../config/ad_config.dart';
import 'preferences_provider.dart';

/// Whether to show ads (false if user is Pro).
final showAdsProvider = Provider<bool>((ref) {
  final isPro = ref.watch(proStatusProvider);
  return !isPro;
});

/// Manages banner ad lifecycle.
class BannerAdNotifier extends StateNotifier<BannerAd?> {
  final bool _showAds;

  BannerAdNotifier(this._showAds) : super(null) {
    if (_showAds) {
      _loadAd();
    }
  }

  void _loadAd() {
    final ad = BannerAd(
      adUnitId: AdConfig.bannerAdUnitId,
      size: AdSize.banner,
      request: const AdRequest(),
      listener: BannerAdListener(
        onAdLoaded: (ad) {
          state = ad as BannerAd;
        },
        onAdFailedToLoad: (ad, error) {
          ad.dispose();
          state = null;
        },
      ),
    );
    ad.load();
  }

  @override
  void dispose() {
    state?.dispose();
    super.dispose();
  }
}

final bannerAdProvider =
    StateNotifierProvider.autoDispose<BannerAdNotifier, BannerAd?>(
  (ref) {
    final showAds = ref.watch(showAdsProvider);
    return BannerAdNotifier(showAds);
  },
);
