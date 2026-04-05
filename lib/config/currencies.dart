class CurrencyInfo {
  final String code;
  final String symbol;
  final String name;

  const CurrencyInfo(this.code, this.symbol, this.name);
}

/// Currencies supported by open.er-api.com (150+ currencies).
/// Popular currencies listed first, then alphabetical by code.
const List<CurrencyInfo> supportedCurrencies = [
  // Top global currencies
  CurrencyInfo('USD', '\$', 'US Dollar'),
  CurrencyInfo('EUR', '\u20AC', 'Euro'),
  CurrencyInfo('GBP', '\u00A3', 'British Pound'),
  CurrencyInfo('JPY', '\u00A5', 'Japanese Yen'),
  CurrencyInfo('CAD', 'CA\$', 'Canadian Dollar'),
  CurrencyInfo('AUD', 'A\$', 'Australian Dollar'),
  CurrencyInfo('CHF', 'CHF', 'Swiss Franc'),
  CurrencyInfo('CNY', '\u00A5', 'Chinese Yuan'),

  // Americas
  CurrencyInfo('ARS', 'AR\$', 'Argentine Peso'),
  CurrencyInfo('BOB', 'Bs', 'Bolivian Boliviano'),
  CurrencyInfo('BRL', 'R\$', 'Brazilian Real'),
  CurrencyInfo('CLP', 'CL\$', 'Chilean Peso'),
  CurrencyInfo('COP', 'COL\$', 'Colombian Peso'),
  CurrencyInfo('CRC', '\u20A1', 'Costa Rican Colon'),
  CurrencyInfo('CUP', '\$', 'Cuban Peso'),
  CurrencyInfo('DOP', 'RD\$', 'Dominican Peso'),
  CurrencyInfo('GTQ', 'Q', 'Guatemalan Quetzal'),
  CurrencyInfo('HNL', 'L', 'Honduran Lempira'),
  CurrencyInfo('JMD', 'J\$', 'Jamaican Dollar'),
  CurrencyInfo('MXN', 'MX\$', 'Mexican Peso'),
  CurrencyInfo('NIO', 'C\$', 'Nicaraguan Cordoba'),
  CurrencyInfo('PAB', 'B/.', 'Panamanian Balboa'),
  CurrencyInfo('PEN', 'S/', 'Peruvian Sol'),
  CurrencyInfo('PYG', '\u20B2', 'Paraguayan Guarani'),
  CurrencyInfo('TTD', 'TT\$', 'Trinidad & Tobago Dollar'),
  CurrencyInfo('UYU', '\$U', 'Uruguayan Peso'),
  CurrencyInfo('VES', 'Bs.S', 'Venezuelan Bolivar'),

  // Europe
  CurrencyInfo('BGN', '\u043B\u0432', 'Bulgarian Lev'),
  CurrencyInfo('CZK', 'K\u010D', 'Czech Koruna'),
  CurrencyInfo('DKK', 'kr', 'Danish Krone'),
  CurrencyInfo('GEL', '\u20BE', 'Georgian Lari'),
  CurrencyInfo('HRK', 'kn', 'Croatian Kuna'),
  CurrencyInfo('HUF', 'Ft', 'Hungarian Forint'),
  CurrencyInfo('ISK', 'kr', 'Icelandic Krona'),
  CurrencyInfo('MDL', 'L', 'Moldovan Leu'),
  CurrencyInfo('NOK', 'kr', 'Norwegian Krone'),
  CurrencyInfo('PLN', 'z\u0142', 'Polish Zloty'),
  CurrencyInfo('RON', 'lei', 'Romanian Leu'),
  CurrencyInfo('RSD', 'din', 'Serbian Dinar'),
  CurrencyInfo('RUB', '\u20BD', 'Russian Ruble'),
  CurrencyInfo('SEK', 'kr', 'Swedish Krona'),
  CurrencyInfo('UAH', '\u20B4', 'Ukrainian Hryvnia'),

  // Asia & Pacific
  CurrencyInfo('BDT', '\u09F3', 'Bangladeshi Taka'),
  CurrencyInfo('HKD', 'HK\$', 'Hong Kong Dollar'),
  CurrencyInfo('IDR', 'Rp', 'Indonesian Rupiah'),
  CurrencyInfo('INR', '\u20B9', 'Indian Rupee'),
  CurrencyInfo('KHR', '\u17DB', 'Cambodian Riel'),
  CurrencyInfo('KRW', '\u20A9', 'South Korean Won'),
  CurrencyInfo('KZT', '\u20B8', 'Kazakhstani Tenge'),
  CurrencyInfo('LAK', '\u20AD', 'Lao Kip'),
  CurrencyInfo('LKR', 'Rs', 'Sri Lankan Rupee'),
  CurrencyInfo('MMK', 'K', 'Myanmar Kyat'),
  CurrencyInfo('MNT', '\u20AE', 'Mongolian Tugrik'),
  CurrencyInfo('MYR', 'RM', 'Malaysian Ringgit'),
  CurrencyInfo('NPR', 'Rs', 'Nepalese Rupee'),
  CurrencyInfo('NZD', 'NZ\$', 'New Zealand Dollar'),
  CurrencyInfo('PHP', '\u20B1', 'Philippine Peso'),
  CurrencyInfo('PKR', 'Rs', 'Pakistani Rupee'),
  CurrencyInfo('SGD', 'S\$', 'Singapore Dollar'),
  CurrencyInfo('THB', '\u0E3F', 'Thai Baht'),
  CurrencyInfo('TWD', 'NT\$', 'Taiwan Dollar'),
  CurrencyInfo('VND', '\u20AB', 'Vietnamese Dong'),

  // Middle East
  CurrencyInfo('AED', 'AED', 'UAE Dirham'),
  CurrencyInfo('BHD', 'BD', 'Bahraini Dinar'),
  CurrencyInfo('ILS', '\u20AA', 'Israeli Shekel'),
  CurrencyInfo('IQD', 'IQD', 'Iraqi Dinar'),
  CurrencyInfo('IRR', 'IRR', 'Iranian Rial'),
  CurrencyInfo('JOD', 'JD', 'Jordanian Dinar'),
  CurrencyInfo('KWD', 'KD', 'Kuwaiti Dinar'),
  CurrencyInfo('LBP', 'LBP', 'Lebanese Pound'),
  CurrencyInfo('OMR', 'OMR', 'Omani Rial'),
  CurrencyInfo('QAR', 'QR', 'Qatari Riyal'),
  CurrencyInfo('SAR', 'SR', 'Saudi Riyal'),
  CurrencyInfo('TRY', '\u20BA', 'Turkish Lira'),

  // Africa
  CurrencyInfo('DZD', 'DA', 'Algerian Dinar'),
  CurrencyInfo('EGP', 'E\u00A3', 'Egyptian Pound'),
  CurrencyInfo('ETB', 'Br', 'Ethiopian Birr'),
  CurrencyInfo('GHS', 'GH\u20B5', 'Ghanaian Cedi'),
  CurrencyInfo('KES', 'KSh', 'Kenyan Shilling'),
  CurrencyInfo('MAD', 'MAD', 'Moroccan Dirham'),
  CurrencyInfo('MUR', 'Rs', 'Mauritian Rupee'),
  CurrencyInfo('NGN', '\u20A6', 'Nigerian Naira'),
  CurrencyInfo('TND', 'DT', 'Tunisian Dinar'),
  CurrencyInfo('TZS', 'TSh', 'Tanzanian Shilling'),
  CurrencyInfo('UGX', 'USh', 'Ugandan Shilling'),
  CurrencyInfo('XAF', 'FCFA', 'Central African CFA Franc'),
  CurrencyInfo('XOF', 'CFA', 'West African CFA Franc'),
  CurrencyInfo('ZAR', 'R', 'South African Rand'),
  CurrencyInfo('ZMW', 'ZK', 'Zambian Kwacha'),
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
