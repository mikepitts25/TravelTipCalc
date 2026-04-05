/// Smart rounding utilities for tip and total amounts.
enum RoundingMode {
  none,
  roundTipUp,
  roundTotalUp,
  roundTotalNearest,
}

class Rounding {
  /// Round up to the nearest whole number.
  static double roundUp(double value) {
    return value.ceilToDouble();
  }

  /// Round to the nearest whole number.
  static double roundNearest(double value) {
    return value.roundToDouble();
  }

  /// Round up to the nearest multiple (e.g., nearest $5).
  static double roundUpTo(double value, double multiple) {
    if (multiple <= 0) return value;
    return (value / multiple).ceil() * multiple;
  }

  /// Apply rounding mode and return adjusted tip amount.
  /// Returns the new tip amount after rounding is applied.
  static double applyRounding({
    required double billAmount,
    required double tipAmount,
    required RoundingMode mode,
  }) {
    switch (mode) {
      case RoundingMode.none:
        return tipAmount;
      case RoundingMode.roundTipUp:
        return roundUp(tipAmount);
      case RoundingMode.roundTotalUp:
        final roundedTotal = roundUp(billAmount + tipAmount);
        return roundedTotal - billAmount;
      case RoundingMode.roundTotalNearest:
        final roundedTotal = roundNearest(billAmount + tipAmount);
        final adjusted = roundedTotal - billAmount;
        // Don't allow negative tip from rounding
        return adjusted < 0 ? 0 : adjusted;
    }
  }
}
