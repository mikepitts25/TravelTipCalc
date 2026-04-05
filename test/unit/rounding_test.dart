import 'package:flutter_test/flutter_test.dart';
import 'package:travel_tip_calc/utils/rounding.dart';

void main() {
  group('Rounding.roundUp', () {
    test('rounds 10.1 up to 11', () {
      expect(Rounding.roundUp(10.1), 11.0);
    });

    test('rounds 10.9 up to 11', () {
      expect(Rounding.roundUp(10.9), 11.0);
    });

    test('keeps whole number unchanged', () {
      expect(Rounding.roundUp(10.0), 10.0);
    });

    test('rounds 0.01 up to 1', () {
      expect(Rounding.roundUp(0.01), 1.0);
    });

    test('rounds 0.0 to 0', () {
      expect(Rounding.roundUp(0.0), 0.0);
    });

    test('rounds negative -1.5 up to -1', () {
      expect(Rounding.roundUp(-1.5), -1.0);
    });

    test('handles very small fractional value', () {
      expect(Rounding.roundUp(0.0001), 1.0);
    });

    test('handles large value', () {
      expect(Rounding.roundUp(9999.01), 10000.0);
    });
  });

  group('Rounding.roundNearest', () {
    test('rounds 10.4 down to 10', () {
      expect(Rounding.roundNearest(10.4), 10.0);
    });

    test('rounds 10.5 up to 11', () {
      expect(Rounding.roundNearest(10.5), 11.0);
    });

    test('rounds 10.6 up to 11', () {
      expect(Rounding.roundNearest(10.6), 11.0);
    });

    test('keeps whole number unchanged', () {
      expect(Rounding.roundNearest(10.0), 10.0);
    });

    test('rounds 0.0 to 0', () {
      expect(Rounding.roundNearest(0.0), 0.0);
    });

    test('rounds 0.49 down to 0', () {
      expect(Rounding.roundNearest(0.49), 0.0);
    });

    test('rounds 0.5 up to 1', () {
      expect(Rounding.roundNearest(0.5), 1.0);
    });

    test('handles large value', () {
      expect(Rounding.roundNearest(9999.4), 9999.0);
    });

    test('handles large value rounding up', () {
      expect(Rounding.roundNearest(9999.5), 10000.0);
    });
  });

  group('Rounding.roundUpTo', () {
    test('rounds 7 up to next multiple of 5', () {
      expect(Rounding.roundUpTo(7, 5), 10.0);
    });

    test('rounds 11 up to next multiple of 5', () {
      expect(Rounding.roundUpTo(11, 5), 15.0);
    });

    test('keeps exact multiple unchanged', () {
      expect(Rounding.roundUpTo(10, 5), 10.0);
    });

    test('rounds 0.5 up to next multiple of 1', () {
      expect(Rounding.roundUpTo(0.5, 1), 1.0);
    });

    test('rounds to next multiple of 10', () {
      expect(Rounding.roundUpTo(23, 10), 30.0);
    });

    test('rounds to next multiple of 0.25', () {
      expect(Rounding.roundUpTo(1.1, 0.25), closeTo(1.25, 0.001));
    });

    test('returns value when multiple is 0', () {
      expect(Rounding.roundUpTo(7.5, 0), 7.5);
    });

    test('returns value when multiple is negative', () {
      expect(Rounding.roundUpTo(7.5, -1), 7.5);
    });

    test('handles zero value', () {
      expect(Rounding.roundUpTo(0, 5), 0.0);
    });
  });

  group('Rounding.applyRounding - RoundingMode.none', () {
    test('returns tip unchanged', () {
      final result = Rounding.applyRounding(
        billAmount: 85.50,
        tipAmount: 12.825,
        mode: RoundingMode.none,
      );
      expect(result, 12.825);
    });

    test('returns zero tip unchanged', () {
      final result = Rounding.applyRounding(
        billAmount: 100,
        tipAmount: 0,
        mode: RoundingMode.none,
      );
      expect(result, 0.0);
    });
  });

  group('Rounding.applyRounding - RoundingMode.roundTipUp', () {
    test('rounds tip from 12.825 up to 13', () {
      final result = Rounding.applyRounding(
        billAmount: 85.50,
        tipAmount: 12.825,
        mode: RoundingMode.roundTipUp,
      );
      expect(result, 13.0);
    });

    test('rounds tip from 15.01 up to 16', () {
      final result = Rounding.applyRounding(
        billAmount: 100,
        tipAmount: 15.01,
        mode: RoundingMode.roundTipUp,
      );
      expect(result, 16.0);
    });

    test('keeps whole tip unchanged', () {
      final result = Rounding.applyRounding(
        billAmount: 100,
        tipAmount: 15.0,
        mode: RoundingMode.roundTipUp,
      );
      expect(result, 15.0);
    });

    test('rounds zero tip to zero', () {
      final result = Rounding.applyRounding(
        billAmount: 50,
        tipAmount: 0.0,
        mode: RoundingMode.roundTipUp,
      );
      expect(result, 0.0);
    });

    test('rounds very small tip up to 1', () {
      final result = Rounding.applyRounding(
        billAmount: 5,
        tipAmount: 0.1,
        mode: RoundingMode.roundTipUp,
      );
      expect(result, 1.0);
    });
  });

  group('Rounding.applyRounding - RoundingMode.roundTotalUp', () {
    test('adjusts tip so total rounds up', () {
      // bill 85.50 + tip 12.825 = 98.325, rounds up to 99
      // adjusted tip = 99 - 85.50 = 13.50
      final result = Rounding.applyRounding(
        billAmount: 85.50,
        tipAmount: 12.825,
        mode: RoundingMode.roundTotalUp,
      );
      expect(result, 13.50);
    });

    test('bill 100 + tip 15 = 115, already whole, no change', () {
      final result = Rounding.applyRounding(
        billAmount: 100,
        tipAmount: 15,
        mode: RoundingMode.roundTotalUp,
      );
      expect(result, 15.0);
    });

    test('bill 47.83 + tip 7.17 = 55.00, already whole', () {
      final result = Rounding.applyRounding(
        billAmount: 47.83,
        tipAmount: 7.17,
        mode: RoundingMode.roundTotalUp,
      );
      expect(result, closeTo(7.17, 0.001));
    });

    test('bill 99.50 + tip 14.925 = 114.425, rounds to 115', () {
      final result = Rounding.applyRounding(
        billAmount: 99.50,
        tipAmount: 14.925,
        mode: RoundingMode.roundTotalUp,
      );
      // 115 - 99.50 = 15.50
      expect(result, 15.50);
    });

    test('bill 20.01 + tip 3.00 = 23.01, rounds to 24', () {
      final result = Rounding.applyRounding(
        billAmount: 20.01,
        tipAmount: 3.00,
        mode: RoundingMode.roundTotalUp,
      );
      // 24 - 20.01 = 3.99
      expect(result, closeTo(3.99, 0.001));
    });

    test('zero tip on fractional bill rounds total up', () {
      final result = Rounding.applyRounding(
        billAmount: 42.30,
        tipAmount: 0.0,
        mode: RoundingMode.roundTotalUp,
      );
      // 43 - 42.30 = 0.70
      expect(result, closeTo(0.70, 0.001));
    });
  });

  group('Rounding.applyRounding - RoundingMode.roundTotalNearest', () {
    test('rounds total down when fraction < 0.5', () {
      // bill 85.00 + tip 12.30 = 97.30, rounds to 97
      // adjusted tip = 97 - 85 = 12
      final result = Rounding.applyRounding(
        billAmount: 85.00,
        tipAmount: 12.30,
        mode: RoundingMode.roundTotalNearest,
      );
      expect(result, 12.0);
    });

    test('rounds total up when fraction >= 0.5', () {
      // bill 85.00 + tip 12.60 = 97.60, rounds to 98
      // adjusted tip = 98 - 85 = 13
      final result = Rounding.applyRounding(
        billAmount: 85.00,
        tipAmount: 12.60,
        mode: RoundingMode.roundTotalNearest,
      );
      expect(result, 13.0);
    });

    test('exactly at .5 rounds up', () {
      // bill 85.00 + tip 12.50 = 97.50, rounds to 98
      // adjusted tip = 98 - 85 = 13
      final result = Rounding.applyRounding(
        billAmount: 85.00,
        tipAmount: 12.50,
        mode: RoundingMode.roundTotalNearest,
      );
      expect(result, 13.0);
    });

    test('already whole total stays the same', () {
      final result = Rounding.applyRounding(
        billAmount: 80.00,
        tipAmount: 20.00,
        mode: RoundingMode.roundTotalNearest,
      );
      expect(result, 20.0);
    });

    test('clamps adjusted tip to 0 when rounding would make it negative', () {
      // bill 99.80 + tip 0.05 = 99.85, rounds to 100
      // adjusted = 100 - 99.80 = 0.20 (positive, so no clamp needed)
      // But: bill 99.80 + tip 0.01 = 99.81, rounds to 100
      // adjusted = 100 - 99.80 = 0.20 (still positive)
      // For negative: bill 99.90 + tip 0.01 = 99.91, rounds to 100
      // adjusted = 100 - 99.90 = 0.10 (still positive)
      // Need: bill 100.40 + tip 0.05 = 100.45, rounds to 100
      // adjusted = 100 - 100.40 = -0.40 -> clamped to 0
      final result = Rounding.applyRounding(
        billAmount: 100.40,
        tipAmount: 0.05,
        mode: RoundingMode.roundTotalNearest,
      );
      expect(result, 0.0);
    });

    test('does not produce negative tip when rounding down significantly', () {
      // bill 100.80 + tip 0.10 = 100.90, rounds to 101
      // adjusted = 101 - 100.80 = 0.20, positive so no clamp
      final result = Rounding.applyRounding(
        billAmount: 100.80,
        tipAmount: 0.10,
        mode: RoundingMode.roundTotalNearest,
      );
      expect(result, closeTo(0.20, 0.001));
    });

    test('fractional bill with rounding', () {
      // bill 47.83 + tip 8.61 = 56.44, rounds to 56
      // adjusted = 56 - 47.83 = 8.17
      final result = Rounding.applyRounding(
        billAmount: 47.83,
        tipAmount: 8.61,
        mode: RoundingMode.roundTotalNearest,
      );
      expect(result, closeTo(8.17, 0.001));
    });

    test('large bill rounds nearest correctly', () {
      // bill 999.99 + tip 150.00 = 1149.99, rounds to 1150
      // adjusted = 1150 - 999.99 = 150.01
      final result = Rounding.applyRounding(
        billAmount: 999.99,
        tipAmount: 150.00,
        mode: RoundingMode.roundTotalNearest,
      );
      expect(result, closeTo(150.01, 0.001));
    });
  });

  group('RoundingMode enum', () {
    test('has four values', () {
      expect(RoundingMode.values.length, 4);
    });

    test('contains expected values', () {
      expect(RoundingMode.values, contains(RoundingMode.none));
      expect(RoundingMode.values, contains(RoundingMode.roundTipUp));
      expect(RoundingMode.values, contains(RoundingMode.roundTotalUp));
      expect(RoundingMode.values, contains(RoundingMode.roundTotalNearest));
    });
  });

  group('Rounding edge cases', () {
    test('roundUp with very large number', () {
      expect(Rounding.roundUp(999999.001), 1000000.0);
    });

    test('roundNearest with very large number', () {
      expect(Rounding.roundNearest(999999.4), 999999.0);
    });

    test('applyRounding with zero bill and zero tip in all modes', () {
      for (final mode in RoundingMode.values) {
        final result = Rounding.applyRounding(
          billAmount: 0,
          tipAmount: 0,
          mode: mode,
        );
        expect(result, 0.0, reason: 'Failed for mode $mode');
      }
    });

    test('floating point precision: 0.1 + 0.2 scenario in roundTotalNearest', () {
      // bill 10.10 + tip 2.02 = 12.12, rounds to 12
      // adjusted = 12 - 10.10 = 1.90
      final result = Rounding.applyRounding(
        billAmount: 10.10,
        tipAmount: 2.02,
        mode: RoundingMode.roundTotalNearest,
      );
      expect(result, closeTo(1.90, 0.01));
    });

    test('roundUpTo with very small multiple', () {
      expect(Rounding.roundUpTo(1.001, 0.01), closeTo(1.01, 0.001));
    });
  });
}
