import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../utils/tip_calculator.dart';

class GroupPerson {
  final String id;
  final String name;
  final double billAmount;

  const GroupPerson({
    required this.id,
    required this.name,
    this.billAmount = 0,
  });

  GroupPerson copyWith({String? name, double? billAmount}) {
    return GroupPerson(
      id: id,
      name: name ?? this.name,
      billAmount: billAmount ?? this.billAmount,
    );
  }

  double tipAmount(double tipPercent) =>
      TipCalculator.calculateTip(billAmount, tipPercent);

  double totalAmount(double tipPercent) =>
      TipCalculator.calculateTotal(billAmount, tipAmount(tipPercent));
}

class GroupCalculatorState {
  final List<GroupPerson> persons;
  final double tipPercent;
  final String currencySymbol;
  final String countryId;

  const GroupCalculatorState({
    this.persons = const [],
    this.tipPercent = 18.0,
    this.currencySymbol = '\$',
    this.countryId = 'US',
  });

  double get totalBill =>
      persons.fold(0, (sum, p) => sum + p.billAmount);

  double get totalTip =>
      persons.fold(0, (sum, p) => sum + p.tipAmount(tipPercent));

  double get grandTotal =>
      persons.fold(0, (sum, p) => sum + p.totalAmount(tipPercent));

  GroupCalculatorState copyWith({
    List<GroupPerson>? persons,
    double? tipPercent,
    String? currencySymbol,
    String? countryId,
  }) {
    return GroupCalculatorState(
      persons: persons ?? this.persons,
      tipPercent: tipPercent ?? this.tipPercent,
      currencySymbol: currencySymbol ?? this.currencySymbol,
      countryId: countryId ?? this.countryId,
    );
  }
}

class GroupCalculatorNotifier extends StateNotifier<GroupCalculatorState> {
  int _nextId = 1;

  GroupCalculatorNotifier() : super(const GroupCalculatorState()) {
    // Start with two people
    _addPerson();
    _addPerson();
  }

  void _addPerson() {
    final id = 'person_${_nextId++}';
    final name = 'Person ${state.persons.length + 1}';
    state = state.copyWith(
      persons: [...state.persons, GroupPerson(id: id, name: name)],
    );
  }

  void addPerson() => _addPerson();

  void removePerson(String id) {
    if (state.persons.length <= 1) return;
    state = state.copyWith(
      persons: state.persons.where((p) => p.id != id).toList(),
    );
  }

  void updatePersonName(String id, String name) {
    state = state.copyWith(
      persons: state.persons
          .map((p) => p.id == id ? p.copyWith(name: name) : p)
          .toList(),
    );
  }

  void updatePersonBill(String id, double amount) {
    state = state.copyWith(
      persons: state.persons
          .map((p) => p.id == id ? p.copyWith(billAmount: amount) : p)
          .toList(),
    );
  }

  void setTipPercent(double percent) {
    state = state.copyWith(tipPercent: percent);
  }

  void setCountryAndCurrency(String countryId, String currencySymbol) {
    state = state.copyWith(
      countryId: countryId,
      currencySymbol: currencySymbol,
    );
  }

  void reset() {
    _nextId = 1;
    state = const GroupCalculatorState();
    _addPerson();
    _addPerson();
  }
}

final groupCalculatorProvider =
    StateNotifierProvider<GroupCalculatorNotifier, GroupCalculatorState>(
  (ref) => GroupCalculatorNotifier(),
);
