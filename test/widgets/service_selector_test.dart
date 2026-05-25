import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:travel_tip_calc/data/models/tipping_rule.dart';
import 'package:travel_tip_calc/screens/calculator/widgets/service_selector.dart';

void main() {
  testWidgets('opens a service picker with housekeeping and valet',
      (tester) async {
    ServiceType? selectedService;
    await _pumpSelector(tester, selectedService, (service) {
      selectedService = service;
    });

    expect(find.text('Restaurant'), findsOneWidget);
    expect(find.text('Housekeeping'), findsNothing);
    expect(find.text('Valet'), findsNothing);

    await tester.tap(find.text('Restaurant'));
    await tester.pumpAndSettle();

    expect(find.text('Housekeeping'), findsOneWidget);
    expect(find.text('Valet'), findsOneWidget);
    expect(find.byType(GridView), findsOneWidget);
  });

  testWidgets('selects housekeeping from the service picker', (tester) async {
    ServiceType? selectedService;
    await _pumpSelector(tester, selectedService, (service) {
      selectedService = service;
    });

    await tester.tap(find.text('Restaurant'));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Housekeeping'));
    await tester.pumpAndSettle();

    expect(selectedService, ServiceType.hotelHousekeeping);
    expect(find.text('Housekeeping'), findsNothing);
  });

  testWidgets('selects valet from the service picker', (tester) async {
    ServiceType? selectedService;
    await _pumpSelector(tester, selectedService, (service) {
      selectedService = service;
    });

    await tester.tap(find.text('Restaurant'));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Valet'));
    await tester.pumpAndSettle();

    expect(selectedService, ServiceType.valet);
    expect(find.text('Valet'), findsNothing);
  });
}

Future<void> _pumpSelector(
  WidgetTester tester,
  ServiceType? selectedService,
  ValueChanged<ServiceType> onSelected,
) async {
  await tester.binding.setSurfaceSize(const Size(390, 500));
  addTearDown(() => tester.binding.setSurfaceSize(null));

  await tester.pumpWidget(
    MaterialApp(
      home: Scaffold(
        body: ServiceSelector(
          selected: selectedService ?? ServiceType.restaurant,
          onSelected: onSelected,
        ),
      ),
    ),
  );
}
