/// Pure calculation functions for tip math.
/// No side effects, no state - easy to test.
class TipCalculator {
  /// Calculate tip amount from bill and percentage.
  static double calculateTip(double billAmount, double tipPercent) {
    if (billAmount < 0 || tipPercent < 0) return 0;
    return billAmount * (tipPercent / 100);
  }

  /// Calculate total (bill + tip).
  static double calculateTotal(double billAmount, double tipAmount) {
    return billAmount + tipAmount;
  }

  /// Calculate per-person amount when splitting.
  static double calculatePerPerson(double totalAmount, int splitCount) {
    if (splitCount <= 0) return totalAmount;
    return totalAmount / splitCount;
  }

  /// Calculate tip per person when splitting.
  static double calculateTipPerPerson(double tipAmount, int splitCount) {
    if (splitCount <= 0) return tipAmount;
    return tipAmount / splitCount;
  }

  /// Full calculation returning all values at once.
  static TipResult calculate({
    required double billAmount,
    required double tipPercent,
    int splitCount = 1,
  }) {
    final tipAmount = calculateTip(billAmount, tipPercent);
    final totalAmount = calculateTotal(billAmount, tipAmount);
    final perPersonTotal = calculatePerPerson(totalAmount, splitCount);
    final perPersonTip = calculateTipPerPerson(tipAmount, splitCount);

    return TipResult(
      billAmount: billAmount,
      tipPercent: tipPercent,
      tipAmount: tipAmount,
      totalAmount: totalAmount,
      splitCount: splitCount,
      perPersonTotal: perPersonTotal,
      perPersonTip: perPersonTip,
    );
  }
}

class TipResult {
  final double billAmount;
  final double tipPercent;
  final double tipAmount;
  final double totalAmount;
  final int splitCount;
  final double perPersonTotal;
  final double perPersonTip;

  const TipResult({
    required this.billAmount,
    required this.tipPercent,
    required this.tipAmount,
    required this.totalAmount,
    required this.splitCount,
    required this.perPersonTotal,
    required this.perPersonTip,
  });
}
