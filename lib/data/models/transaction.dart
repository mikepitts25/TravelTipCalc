class Transaction {
  final int? id;
  final DateTime date;
  final String countryId;
  final String serviceType;
  final double billAmount;
  final double tipPercent;
  final double tipAmount;
  final double totalAmount;
  final int splitCount;
  final String currencyCode;
  final String? note;

  const Transaction({
    this.id,
    required this.date,
    required this.countryId,
    required this.serviceType,
    required this.billAmount,
    required this.tipPercent,
    required this.tipAmount,
    required this.totalAmount,
    required this.splitCount,
    required this.currencyCode,
    this.note,
  });

  factory Transaction.fromMap(Map<String, dynamic> map) {
    return Transaction(
      id: map['id'] as int?,
      date: DateTime.parse(map['date'] as String),
      countryId: map['country_id'] as String,
      serviceType: map['service_type'] as String,
      billAmount: (map['bill_amount'] as num).toDouble(),
      tipPercent: (map['tip_percent'] as num).toDouble(),
      tipAmount: (map['tip_amount'] as num).toDouble(),
      totalAmount: (map['total_amount'] as num).toDouble(),
      splitCount: map['split_count'] as int,
      currencyCode: map['currency_code'] as String,
      note: map['note'] as String?,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      if (id != null) 'id': id,
      'date': date.toIso8601String(),
      'country_id': countryId,
      'service_type': serviceType,
      'bill_amount': billAmount,
      'tip_percent': tipPercent,
      'tip_amount': tipAmount,
      'total_amount': totalAmount,
      'split_count': splitCount,
      'currency_code': currencyCode,
      'note': note,
    };
  }
}
