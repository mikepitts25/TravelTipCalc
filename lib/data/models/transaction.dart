import 'tipping_rule.dart';

class TripTransaction {
  final int? id;
  final DateTime date;
  final String countryId;
  final String countryName;
  final String countryFlag;
  final ServiceType serviceType;
  final double billAmount;
  final double tipPercent;
  final double tipAmount;
  final double totalAmount;
  final int splitCount;
  final String currencyCode;
  final String currencySymbol;
  final String? note;

  const TripTransaction({
    this.id,
    required this.date,
    required this.countryId,
    required this.countryName,
    required this.countryFlag,
    required this.serviceType,
    required this.billAmount,
    required this.tipPercent,
    required this.tipAmount,
    required this.totalAmount,
    required this.splitCount,
    required this.currencyCode,
    required this.currencySymbol,
    this.note,
  });

  factory TripTransaction.fromMap(Map<String, dynamic> map) {
    return TripTransaction(
      id: map['id'] as int?,
      date: DateTime.parse(map['date'] as String),
      countryId: map['country_id'] as String,
      countryName: map['country_name'] as String? ?? '',
      countryFlag: map['country_flag'] as String? ?? '',
      serviceType: ServiceType.fromDbValue(map['service_type'] as String),
      billAmount: (map['bill_amount'] as num).toDouble(),
      tipPercent: (map['tip_percent'] as num).toDouble(),
      tipAmount: (map['tip_amount'] as num).toDouble(),
      totalAmount: (map['total_amount'] as num).toDouble(),
      splitCount: map['split_count'] as int,
      currencyCode: map['currency_code'] as String,
      currencySymbol: map['currency_symbol'] as String? ?? '',
      note: map['note'] as String?,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      if (id != null) 'id': id,
      'date': date.toIso8601String(),
      'country_id': countryId,
      'country_name': countryName,
      'country_flag': countryFlag,
      'service_type': serviceType.dbValue,
      'bill_amount': billAmount,
      'tip_percent': tipPercent,
      'tip_amount': tipAmount,
      'total_amount': totalAmount,
      'split_count': splitCount,
      'currency_code': currencyCode,
      'currency_symbol': currencySymbol,
      if (note != null) 'note': note,
    };
  }

  String toCsvRow() {
    final d = date.toLocal();
    final dateStr =
        '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';
    final timeStr =
        '${d.hour.toString().padLeft(2, '0')}:${d.minute.toString().padLeft(2, '0')}';
    return '"$dateStr $timeStr","$countryName","${serviceType.displayName}",'
        '"$currencyCode","$currencySymbol${billAmount.toStringAsFixed(2)}",'
        '"${tipPercent.toStringAsFixed(1)}%",'
        '"$currencySymbol${tipAmount.toStringAsFixed(2)}",'
        '"$currencySymbol${totalAmount.toStringAsFixed(2)}",'
        '"$splitCount"';
  }

  static String csvHeader() =>
      '"Date","Country","Service","Currency","Bill","Tip %","Tip Amount","Total","Split"';
}
