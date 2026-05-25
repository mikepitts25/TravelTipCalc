import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  final tippingData = jsonDecode(
    File('assets/data/tipping_data.json').readAsStringSync(),
  ) as Map<String, dynamic>;

  group('hotel service tipping data', () {
    test('includes housekeeping and valet wherever bellhop data exists', () {
      final missing = <String>[];

      for (final country in tippingData['countries'] as List<dynamic>) {
        final countryMap = country as Map<String, dynamic>;
        final serviceTypes = {
          for (final rule in countryMap['rules'] as List<dynamic>)
            (rule as Map<String, dynamic>)['service_type'] as String,
        };

        if (!serviceTypes.contains('hotel_bellhop')) {
          continue;
        }

        for (final hotelService in ['hotel_housekeeping', 'valet']) {
          if (!serviceTypes.contains(hotelService)) {
            missing.add('${countryMap['id']}:$hotelService');
          }
        }
      }

      expect(missing, isEmpty);
    });
  });
}
