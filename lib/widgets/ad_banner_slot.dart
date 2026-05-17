import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

import '../config/ad_config.dart';
import '../providers/ad_provider.dart';

class AdBannerSlot extends ConsumerStatefulWidget {
  final bool enabled;

  const AdBannerSlot({super.key, this.enabled = true});

  @override
  ConsumerState<AdBannerSlot> createState() => _AdBannerSlotState();
}

class _AdBannerSlotState extends ConsumerState<AdBannerSlot> {
  BannerAd? _bannerAd;
  int? _requestedWidth;
  String? _requestedAdUnitId;
  bool _isLoading = false;
  bool _loadFailed = false;

  @override
  void dispose() {
    _disposeAd();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final showAds = widget.enabled && ref.watch(showAdsProvider);
    final adUnitId = AdConfig.bannerAdUnitId;

    if (!showAds || adUnitId.isEmpty) {
      _disposeAd();
      return const SizedBox.shrink();
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth.isFinite
            ? constraints.maxWidth.truncate()
            : MediaQuery.sizeOf(context).width.truncate();

        _loadAdIfNeeded(width, adUnitId);

        if (_loadFailed) {
          return const SizedBox.shrink();
        }

        final bannerAd = _bannerAd;
        final adHeight = bannerAd?.size.height.toDouble() ?? 50;

        return Container(
          width: double.infinity,
          height: adHeight + 12,
          decoration: BoxDecoration(
            color: Theme.of(context).scaffoldBackgroundColor,
            border: Border(
              top: BorderSide(
                color: Theme.of(context)
                    .colorScheme
                    .outline
                    .withValues(alpha: 0.18),
              ),
            ),
          ),
          alignment: Alignment.center,
          child: bannerAd == null
              ? const SizedBox.shrink()
              : SizedBox(
                  width: bannerAd.size.width.toDouble(),
                  height: bannerAd.size.height.toDouble(),
                  child: AdWidget(ad: bannerAd),
                ),
        );
      },
    );
  }

  void _loadAdIfNeeded(int width, String adUnitId) {
    if (_requestedWidth == width &&
        _requestedAdUnitId == adUnitId &&
        (_isLoading || _bannerAd != null || _loadFailed)) {
      return;
    }

    _disposeAd();
    _requestedWidth = width;
    _requestedAdUnitId = adUnitId;
    _isLoading = true;
    _loadFailed = false;

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      if (!mounted) return;

      final size = await AdSize.getLargeAnchoredAdaptiveBannerAdSize(width);
      if (!mounted) return;

      if (size == null) {
        setState(() {
          _isLoading = false;
          _loadFailed = true;
        });
        return;
      }

      final ad = BannerAd(
        adUnitId: adUnitId,
        size: size,
        request: const AdRequest(),
        listener: BannerAdListener(
          onAdLoaded: (ad) {
            if (!mounted) {
              ad.dispose();
              return;
            }

            setState(() {
              _bannerAd = ad as BannerAd;
              _isLoading = false;
              _loadFailed = false;
            });
          },
          onAdFailedToLoad: (ad, error) {
            ad.dispose();
            if (!mounted) return;

            setState(() {
              _bannerAd = null;
              _isLoading = false;
              _loadFailed = true;
            });
          },
        ),
      );

      await ad.load();
    });
  }

  void _disposeAd() {
    _bannerAd?.dispose();
    _bannerAd = null;
    _requestedWidth = null;
    _requestedAdUnitId = null;
    _isLoading = false;
    _loadFailed = false;
  }
}
