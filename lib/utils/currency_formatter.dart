import 'package:intl/intl.dart';

class CurrencyFormatter {
  static String format(double amount, String currencyCode) {
    try {
      final format = NumberFormat.currency(
        name: currencyCode,
        decimalDigits: 2,
      );
      return format.format(amount);
    } catch (_) {
      // Fallback if currency code not recognized
      return '${currencyCode} ${amount.toStringAsFixed(2)}';
    }
  }

  static String formatCompact(double amount, String currencySymbol) {
    return '$currencySymbol${amount.toStringAsFixed(2)}';
  }

  static String formatPercent(double percent) {
    if (percent == percent.roundToDouble()) {
      return '${percent.toInt()}%';
    }
    return '${percent.toStringAsFixed(1)}%';
  }
}
