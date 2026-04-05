class CurrencyInfo {
  final String code;
  final String symbol;
  final String name;

  const CurrencyInfo(this.code, this.symbol, this.name);
}

/// Common currencies supported by frankfurter.app (ECB data).
/// Sorted by most commonly used first, then alphabetical.
const List<CurrencyInfo> supportedCurrencies = [
  CurrencyInfo('USD', '\$', 'US Dollar'),
  CurrencyInfo('EUR', '\u20AC', 'Euro'),
  CurrencyInfo('GBP', '\u00A3', 'British Pound'),
  CurrencyInfo('JPY', '\u00A5', 'Japanese Yen'),
  CurrencyInfo('CAD', 'CA\$', 'Canadian Dollar'),
  CurrencyInfo('AUD', 'A\$', 'Australian Dollar'),
  CurrencyInfo('CHF', 'CHF', 'Swiss Franc'),
  CurrencyInfo('CNY', '\u00A5', 'Chinese Yuan'),
  CurrencyInfo('HKD', 'HK\$', 'Hong Kong Dollar'),
  CurrencyInfo('NZD', 'NZ\$', 'New Zealand Dollar'),
  CurrencyInfo('SEK', 'kr', 'Swedish Krona'),
  CurrencyInfo('KRW', '\u20A9', 'South Korean Won'),
  CurrencyInfo('SGD', 'S\$', 'Singapore Dollar'),
  CurrencyInfo('NOK', 'kr', 'Norwegian Krone'),
  CurrencyInfo('MXN', 'MX\$', 'Mexican Peso'),
  CurrencyInfo('INR', '\u20B9', 'Indian Rupee'),
  CurrencyInfo('BRL', 'R\$', 'Brazilian Real'),
  CurrencyInfo('ZAR', 'R', 'South African Rand'),
  CurrencyInfo('THB', '\u0E3F', 'Thai Baht'),
  CurrencyInfo('TRY', '\u20BA', 'Turkish Lira'),
  CurrencyInfo('PLN', 'z\u0142', 'Polish Zloty'),
  CurrencyInfo('DKK', 'kr', 'Danish Krone'),
  CurrencyInfo('MYR', 'RM', 'Malaysian Ringgit'),
  CurrencyInfo('IDR', 'Rp', 'Indonesian Rupiah'),
  CurrencyInfo('PHP', '\u20B1', 'Philippine Peso'),
  CurrencyInfo('CZK', 'K\u010D', 'Czech Koruna'),
  CurrencyInfo('HUF', 'Ft', 'Hungarian Forint'),
  CurrencyInfo('ILS', '\u20AA', 'Israeli Shekel'),
  CurrencyInfo('ISK', 'kr', 'Icelandic Krona'),
  CurrencyInfo('RON', 'lei', 'Romanian Leu'),
  CurrencyInfo('BGN', 'лв', 'Bulgarian Lev'),
];

CurrencyInfo? getCurrencyInfo(String code) {
  try {
    return supportedCurrencies.firstWhere((c) => c.code == code);
  } catch (_) {
    return null;
  }
}

String getCurrencySymbol(String code) {
  return getCurrencyInfo(code)?.symbol ?? code;
}
