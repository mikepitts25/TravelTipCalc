enum ServiceType {
  restaurant,
  taxi,
  hotelBellhop,
  hotelHousekeeping,
  barber,
  tourGuide,
  delivery,
  bar,
  spa,
  valet;

  String get displayName {
    switch (this) {
      case ServiceType.restaurant:
        return 'Restaurant';
      case ServiceType.taxi:
        return 'Taxi';
      case ServiceType.hotelBellhop:
        return 'Hotel Bellhop';
      case ServiceType.hotelHousekeeping:
        return 'Housekeeping';
      case ServiceType.barber:
        return 'Barber / Salon';
      case ServiceType.tourGuide:
        return 'Tour Guide';
      case ServiceType.delivery:
        return 'Delivery';
      case ServiceType.bar:
        return 'Bar';
      case ServiceType.spa:
        return 'Spa';
      case ServiceType.valet:
        return 'Valet';
    }
  }

  String get icon {
    switch (this) {
      case ServiceType.restaurant:
        return '🍽️';
      case ServiceType.taxi:
        return '🚕';
      case ServiceType.hotelBellhop:
        return '🛎️';
      case ServiceType.hotelHousekeeping:
        return '🛏️';
      case ServiceType.barber:
        return '💈';
      case ServiceType.tourGuide:
        return '🗺️';
      case ServiceType.delivery:
        return '📦';
      case ServiceType.bar:
        return '🍸';
      case ServiceType.spa:
        return '💆';
      case ServiceType.valet:
        return '🚗';
    }
  }

  String get dbValue {
    switch (this) {
      case ServiceType.restaurant:
        return 'restaurant';
      case ServiceType.taxi:
        return 'taxi';
      case ServiceType.hotelBellhop:
        return 'hotel_bellhop';
      case ServiceType.hotelHousekeeping:
        return 'hotel_housekeeping';
      case ServiceType.barber:
        return 'barber';
      case ServiceType.tourGuide:
        return 'tour_guide';
      case ServiceType.delivery:
        return 'delivery';
      case ServiceType.bar:
        return 'bar';
      case ServiceType.spa:
        return 'spa';
      case ServiceType.valet:
        return 'valet';
    }
  }

  static ServiceType fromDbValue(String value) {
    return ServiceType.values.firstWhere(
      (e) => e.dbValue == value,
      orElse: () => ServiceType.restaurant,
    );
  }
}

class TippingRule {
  final int? id;
  final String countryId;
  final ServiceType serviceType;
  final double minPercent;
  final double maxPercent;
  final double suggestedPercent;
  final String note;

  const TippingRule({
    this.id,
    required this.countryId,
    required this.serviceType,
    required this.minPercent,
    required this.maxPercent,
    required this.suggestedPercent,
    required this.note,
  });

  factory TippingRule.fromMap(Map<String, dynamic> map) {
    return TippingRule(
      id: map['id'] as int?,
      countryId: map['country_id'] as String,
      serviceType: ServiceType.fromDbValue(map['service_type'] as String),
      minPercent: (map['min_percent'] as num).toDouble(),
      maxPercent: (map['max_percent'] as num).toDouble(),
      suggestedPercent: (map['suggested_percent'] as num).toDouble(),
      note: map['note'] as String,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      if (id != null) 'id': id,
      'country_id': countryId,
      'service_type': serviceType.dbValue,
      'min_percent': minPercent,
      'max_percent': maxPercent,
      'suggested_percent': suggestedPercent,
      'note': note,
    };
  }
}
