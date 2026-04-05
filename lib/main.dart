import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'app.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Lock to portrait orientation
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  // Note: AdMob initialization is deferred to when ads are first needed.
  // You must add your AdMob App ID to ios/Runner/Info.plist and
  // android/app/src/main/AndroidManifest.xml before enabling ads.

  runApp(
    const ProviderScope(
      child: TravelTipCalcApp(),
    ),
  );
}
