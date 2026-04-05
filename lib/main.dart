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

  // Note: AdMob initialization is deferred until google_mobile_ads is
  // re-enabled in pubspec.yaml and App IDs are configured natively.

  runApp(
    const ProviderScope(
      child: TravelTipCalcApp(),
    ),
  );
}
