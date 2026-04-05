import 'package:flutter_test/flutter_test.dart';
import 'package:travel_tip_calc/utils/tip_calculator.dart';

void main() {
  group('TipCalculator.calculateTip', () {
    test('calculates 15% tip on \$100 bill', () {
      expect(TipCalculator.calculateTip(100, 15), 15.0);
    });

    test('calculates 20% tip on \$50 bill', () {
      expect(TipCalculator.calculateTip(50, 20), 10.0);
    });

    test('calculates 18% tip on \$75.50 bill', () {
      expect(TipCalculator.calculateTip(75.50, 18), closeTo(13.59, 0.001));
    });

    test('calculates 10% tip on \$23.47 bill', () {
      expect(TipCalculator.calculateTip(23.47, 10), closeTo(2.347, 0.001));
    });

    test('calculates 25% tip on \$200 bill', () {
      expect(TipCalculator.calculateTip(200, 25), 50.0);
    });

    test('returns 0 for zero bill amount', () {
      expect(TipCalculator.calculateTip(0, 20), 0.0);
    });

    test('returns 0 for zero tip percent', () {
      expect(TipCalculator.calculateTip(100, 0), 0.0);
    });

    test('returns 0 for negative bill amount', () {
      expect(TipCalculator.calculateTip(-50, 15), 0.0);
    });

    test('returns 0 for negative tip percent', () {
      expect(TipCalculator.calculateTip(100, -10), 0.0);
    });

    test('returns 0 when both are negative', () {
      expect(TipCalculator.calculateTip(-50, -15), 0.0);
    });

    test('handles very large bill amount', () {
      expect(TipCalculator.calculateTip(999999.99, 20), closeTo(199999.998, 0.001));
    });

    test('handles very small tip percent', () {
      expect(TipCalculator.calculateTip(100, 0.5), closeTo(0.5, 0.001));
    });

    test('handles 100% tip', () {
      expect(TipCalculator.calculateTip(85.0, 100), 85.0);
    });

    test('floating point precision: 33.33 bill at 15%', () {
      expect(TipCalculator.calculateTip(33.33, 15), closeTo(4.9995, 0.001));
    });

    test('floating point precision: 19.99 bill at 18%', () {
      expect(TipCalculator.calculateTip(19.99, 18), closeTo(3.5982, 0.001));
    });
  });

  group('TipCalculator.calculateTotal', () {
    test('adds bill and tip correctly', () {
      expect(TipCalculator.calculateTotal(100, 15), 115.0);
    });

    test('works with zero tip', () {
      expect(TipCalculator.calculateTotal(50, 0), 50.0);
    });

    test('works with zero bill', () {
      expect(TipCalculator.calculateTotal(0, 10), 10.0);
    });

    test('handles fractional amounts', () {
      expect(TipCalculator.calculateTotal(33.47, 5.02), closeTo(38.49, 0.001));
    });

    test('handles large values', () {
      expect(TipCalculator.calculateTotal(500000, 100000), 600000.0);
    });
  });

  group('TipCalculator.calculatePerPerson', () {
    test('splits total between 2 people', () {
      expect(TipCalculator.calculatePerPerson(100, 2), 50.0);
    });

    test('splits total between 3 people', () {
      expect(TipCalculator.calculatePerPerson(100, 3), closeTo(33.333, 0.001));
    });

    test('splits total between 4 people', () {
      expect(TipCalculator.calculatePerPerson(100, 4), 25.0);
    });

    test('splits total between 10 people', () {
      expect(TipCalculator.calculatePerPerson(250, 10), 25.0);
    });

    test('splits total between 20 people', () {
      expect(TipCalculator.calculatePerPerson(400, 20), 20.0);
    });

    test('split count of 1 returns full total', () {
      expect(TipCalculator.calculatePerPerson(115.0, 1), 115.0);
    });

    test('split count of 0 returns full total', () {
      expect(TipCalculator.calculatePerPerson(115.0, 0), 115.0);
    });

    test('negative split count returns full total', () {
      expect(TipCalculator.calculatePerPerson(115.0, -2), 115.0);
    });

    test('handles uneven split', () {
      expect(TipCalculator.calculatePerPerson(100, 3), closeTo(33.3333, 0.001));
    });

    test('handles large split count', () {
      expect(TipCalculator.calculatePerPerson(1000, 7), closeTo(142.857, 0.01));
    });
  });

  group('TipCalculator.calculateTipPerPerson', () {
    test('splits tip between 2 people', () {
      expect(TipCalculator.calculateTipPerPerson(20, 2), 10.0);
    });

    test('splits tip between 3 people', () {
      expect(TipCalculator.calculateTipPerPerson(15, 3), 5.0);
    });

    test('splits tip between 4 people', () {
      expect(TipCalculator.calculateTipPerPerson(20, 4), 5.0);
    });

    test('splits tip between 10 people', () {
      expect(TipCalculator.calculateTipPerPerson(30, 10), 3.0);
    });

    test('splits tip between 20 people', () {
      expect(TipCalculator.calculateTipPerPerson(100, 20), 5.0);
    });

    test('split count of 1 returns full tip', () {
      expect(TipCalculator.calculateTipPerPerson(15.0, 1), 15.0);
    });

    test('split count of 0 returns full tip', () {
      expect(TipCalculator.calculateTipPerPerson(15.0, 0), 15.0);
    });

    test('negative split count returns full tip', () {
      expect(TipCalculator.calculateTipPerPerson(15.0, -3), 15.0);
    });

    test('handles uneven split', () {
      expect(TipCalculator.calculateTipPerPerson(10, 3), closeTo(3.3333, 0.001));
    });
  });

  group('TipCalculator.calculate (full method)', () {
    test('standard calculation: \$100 bill at 15%', () {
      final result = TipCalculator.calculate(billAmount: 100, tipPercent: 15);
      expect(result.billAmount, 100.0);
      expect(result.tipPercent, 15.0);
      expect(result.tipAmount, 15.0);
      expect(result.totalAmount, 115.0);
      expect(result.splitCount, 1);
      expect(result.perPersonTotal, 115.0);
      expect(result.perPersonTip, 15.0);
    });

    test('standard calculation: \$50 bill at 20%', () {
      final result = TipCalculator.calculate(billAmount: 50, tipPercent: 20);
      expect(result.tipAmount, 10.0);
      expect(result.totalAmount, 60.0);
      expect(result.perPersonTotal, 60.0);
      expect(result.perPersonTip, 10.0);
    });

    test('with split count of 2', () {
      final result = TipCalculator.calculate(
        billAmount: 100,
        tipPercent: 20,
        splitCount: 2,
      );
      expect(result.tipAmount, 20.0);
      expect(result.totalAmount, 120.0);
      expect(result.splitCount, 2);
      expect(result.perPersonTotal, 60.0);
      expect(result.perPersonTip, 10.0);
    });

    test('with split count of 3', () {
      final result = TipCalculator.calculate(
        billAmount: 90,
        tipPercent: 15,
        splitCount: 3,
      );
      expect(result.tipAmount, closeTo(13.5, 0.001));
      expect(result.totalAmount, closeTo(103.5, 0.001));
      expect(result.perPersonTotal, closeTo(34.5, 0.001));
      expect(result.perPersonTip, closeTo(4.5, 0.001));
    });

    test('with split count of 4', () {
      final result = TipCalculator.calculate(
        billAmount: 200,
        tipPercent: 18,
        splitCount: 4,
      );
      expect(result.tipAmount, 36.0);
      expect(result.totalAmount, 236.0);
      expect(result.perPersonTotal, 59.0);
      expect(result.perPersonTip, 9.0);
    });

    test('with split count of 10', () {
      final result = TipCalculator.calculate(
        billAmount: 500,
        tipPercent: 20,
        splitCount: 10,
      );
      expect(result.tipAmount, 100.0);
      expect(result.totalAmount, 600.0);
      expect(result.perPersonTotal, 60.0);
      expect(result.perPersonTip, 10.0);
    });

    test('with split count of 20', () {
      final result = TipCalculator.calculate(
        billAmount: 1000,
        tipPercent: 15,
        splitCount: 20,
      );
      expect(result.tipAmount, 150.0);
      expect(result.totalAmount, 1150.0);
      expect(result.perPersonTotal, 57.5);
      expect(result.perPersonTip, 7.5);
    });

    test('zero bill amount', () {
      final result = TipCalculator.calculate(billAmount: 0, tipPercent: 15);
      expect(result.tipAmount, 0.0);
      expect(result.totalAmount, 0.0);
      expect(result.perPersonTotal, 0.0);
    });

    test('zero tip percent', () {
      final result = TipCalculator.calculate(billAmount: 100, tipPercent: 0);
      expect(result.tipAmount, 0.0);
      expect(result.totalAmount, 100.0);
      expect(result.perPersonTotal, 100.0);
    });

    test('negative bill amount returns safe values', () {
      final result = TipCalculator.calculate(billAmount: -50, tipPercent: 15);
      expect(result.tipAmount, 0.0);
    });

    test('default split count is 1', () {
      final result = TipCalculator.calculate(billAmount: 100, tipPercent: 20);
      expect(result.splitCount, 1);
    });

    test('very large bill amount', () {
      final result = TipCalculator.calculate(
        billAmount: 10000,
        tipPercent: 25,
        splitCount: 5,
      );
      expect(result.tipAmount, 2500.0);
      expect(result.totalAmount, 12500.0);
      expect(result.perPersonTotal, 2500.0);
      expect(result.perPersonTip, 500.0);
    });

    test('fractional bill with split produces correct per-person amounts', () {
      final result = TipCalculator.calculate(
        billAmount: 87.63,
        tipPercent: 18,
        splitCount: 3,
      );
      expect(result.tipAmount, closeTo(15.7734, 0.001));
      expect(result.totalAmount, closeTo(103.4034, 0.001));
      expect(result.perPersonTotal, closeTo(34.4678, 0.001));
      expect(result.perPersonTip, closeTo(5.2578, 0.001));
    });

    test('floating point: 0.1 + 0.2 style precision', () {
      final result = TipCalculator.calculate(billAmount: 33.33, tipPercent: 15);
      expect(result.tipAmount, closeTo(4.9995, 0.001));
      expect(result.totalAmount, closeTo(38.3295, 0.001));
    });
  });

  group('TipResult', () {
    test('stores all fields correctly', () {
      const result = TipResult(
        billAmount: 100,
        tipPercent: 18,
        tipAmount: 18,
        totalAmount: 118,
        splitCount: 2,
        perPersonTotal: 59,
        perPersonTip: 9,
      );
      expect(result.billAmount, 100);
      expect(result.tipPercent, 18);
      expect(result.tipAmount, 18);
      expect(result.totalAmount, 118);
      expect(result.splitCount, 2);
      expect(result.perPersonTotal, 59);
      expect(result.perPersonTip, 9);
    });
  });
}
