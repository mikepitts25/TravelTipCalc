import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:travel_tip_calc/config/constants.dart';
import 'package:travel_tip_calc/providers/group_calculator_provider.dart';
import 'package:travel_tip_calc/providers/tip_calculator_provider.dart';

void main() {
  group('tip presets', () {
    test('uses the requested quick tip percentages', () {
      expect(AppConstants.quickTipPresets, [5, 10, 15, 20]);
    });

    test('solo calculator clears the tip when selected percent is tapped again',
        () {
      final container = ProviderContainer();
      addTearDown(container.dispose);
      final notifier = container.read(tipCalculatorProvider.notifier);

      notifier.setBillAmount(100);
      notifier.toggleTipPercent(10);

      expect(container.read(tipCalculatorProvider).tipPercent, 10);
      expect(container.read(tipCalculatorProvider).result.tipAmount, 10);

      notifier.toggleTipPercent(10);

      expect(container.read(tipCalculatorProvider).tipPercent, 0);
      expect(container.read(tipCalculatorProvider).result.tipAmount, 0);
    });

    test(
        'group calculator clears the tip when selected percent is tapped again',
        () {
      final container = ProviderContainer();
      addTearDown(container.dispose);
      final notifier = container.read(groupCalculatorProvider.notifier);

      notifier.toggleTipPercent(10);
      expect(container.read(groupCalculatorProvider).tipPercent, 10);

      notifier.toggleTipPercent(10);
      expect(container.read(groupCalculatorProvider).tipPercent, 0);
    });
  });
}
