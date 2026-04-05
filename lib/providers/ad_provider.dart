import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'preferences_provider.dart';

/// Whether to show ads (false if user is Pro).
/// Ads are disabled until AdMob App ID is configured in native projects.
final showAdsProvider = Provider<bool>((ref) {
  final isPro = ref.watch(proStatusProvider);
  // Disable ads until AdMob is properly configured.
  // Set this to `!isPro` once you add your AdMob App ID to
  // ios/Runner/Info.plist (GADApplicationIdentifier) and
  // android/app/src/main/AndroidManifest.xml (com.google.android.gms.ads.APPLICATION_ID).
  return false && !isPro;
});
