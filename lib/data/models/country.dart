class Country {
  final String id; // ISO 3166-1 alpha-2
  final String name;
  final String flag;
  final String region;
  final String currencyCode;
  final String currencySymbol;
  final bool serviceIncluded;
  final String etiquetteNote;

  const Country({
    required this.id,
    required this.name,
    required this.flag,
    required this.region,
    required this.currencyCode,
    required this.currencySymbol,
    required this.serviceIncluded,
    required this.etiquetteNote,
  });

  factory Country.fromMap(Map<String, dynamic> map) {
    return Country(
      id: map['id'] as String,
      name: map['name'] as String,
      flag: map['flag'] as String,
      region: map['region'] as String,
      currencyCode: map['currency_code'] as String,
      currencySymbol: map['currency_symbol'] as String,
      serviceIncluded: (map['service_included'] as int) == 1,
      etiquetteNote: map['etiquette_note'] as String,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'flag': flag,
      'region': region,
      'currency_code': currencyCode,
      'currency_symbol': currencySymbol,
      'service_included': serviceIncluded ? 1 : 0,
      'etiquette_note': etiquetteNote,
    };
  }
}
