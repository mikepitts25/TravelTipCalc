import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:travel_tip_calc/config/constants.dart';
import 'package:travel_tip_calc/screens/settings/settings_screen.dart';

void main() {
  testWidgets('rate this app opens the App Store review page', (tester) async {
    Uri? launchedUrl;

    await tester.pumpWidget(
      ProviderScope(
        child: MaterialApp(
          home: SettingsScreen(
            launchReviewUrl: (url) async {
              launchedUrl = url;
              return true;
            },
          ),
        ),
      ),
    );

    await tester.tap(find.text('Rate This App'));
    await tester.pump();

    expect(launchedUrl, Uri.parse(AppConstants.appStoreReviewUrl));
  });
}
