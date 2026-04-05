/// Manages AdMob initialization and lifecycle.
/// Currently stubbed out - enable once AdMob App ID is configured in native projects.
class AdService {
  static Future<void> initialize() async {
    // No-op until google_mobile_ads is added back to pubspec.yaml
    // and AdMob App ID is configured in:
    //   ios/Runner/Info.plist (GADApplicationIdentifier)
    //   android/app/src/main/AndroidManifest.xml (com.google.android.gms.ads.APPLICATION_ID)
  }
}
