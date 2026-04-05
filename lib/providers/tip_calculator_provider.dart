import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../config/constants.dart';
import '../data/models/tipping_rule.dart';
import '../utils/rounding.dart';
import '../utils/tip_calculator.dart';

/// State for the main tip calculator.
class TipCalculatorState {
  final double billAmount;
  final double tipPercent;
  final int splitCount;
  final RoundingMode roundingMode;
  final ServiceType serviceType;
  final String countryId;
  final String currencySymbol;
  final TipResult result;

  const TipCalculatorState({
    this.billAmount = 0,
    this.tipPercent = AppConstants.defaultTipPercent,
    this.splitCount = 1,
    this.roundingMode = RoundingMode.none,
    this.serviceType = ServiceType.restaurant,
    this.countryId = AppConstants.defaultCountry,
    this.currencySymbol = '\$',
    required this.result,
  });

  factory TipCalculatorState.initial() {
    return TipCalculatorState(
      result: TipCalculator.calculate(
        billAmount: 0,
        tipPercent: AppConstants.defaultTipPercent,
      ),
    );
  }

  TipCalculatorState copyWith({
    double? billAmount,
    double? tipPercent,
    int? splitCount,
    RoundingMode? roundingMode,
    ServiceType? serviceType,
    String? countryId,
    String? currencySymbol,
    TipResult? result,
  }) {
    return TipCalculatorState(
      billAmount: billAmount ?? this.billAmount,
      tipPercent: tipPercent ?? this.tipPercent,
      splitCount: splitCount ?? this.splitCount,
      roundingMode: roundingMode ?? this.roundingMode,
      serviceType: serviceType ?? this.serviceType,
      countryId: countryId ?? this.countryId,
      currencySymbol: currencySymbol ?? this.currencySymbol,
      result: result ?? this.result,
    );
  }
}

class TipCalculatorNotifier extends StateNotifier<TipCalculatorState> {
  TipCalculatorNotifier() : super(TipCalculatorState.initial());

  void _recalculate() {
    var tipAmount = TipCalculator.calculateTip(
      state.billAmount,
      state.tipPercent,
    );

    // Apply rounding
    tipAmount = Rounding.applyRounding(
      billAmount: state.billAmount,
      tipAmount: tipAmount,
      mode: state.roundingMode,
    );

    final totalAmount = TipCalculator.calculateTotal(
      state.billAmount,
      tipAmount,
    );
    final perPersonTotal = TipCalculator.calculatePerPerson(
      totalAmount,
      state.splitCount,
    );
    final perPersonTip = TipCalculator.calculateTipPerPerson(
      tipAmount,
      state.splitCount,
    );

    // Calculate effective tip percent after rounding
    final effectivePercent = state.billAmount > 0
        ? (tipAmount / state.billAmount) * 100
        : state.tipPercent;

    state = state.copyWith(
      result: TipResult(
        billAmount: state.billAmount,
        tipPercent: effectivePercent,
        tipAmount: tipAmount,
        totalAmount: totalAmount,
        splitCount: state.splitCount,
        perPersonTotal: perPersonTotal,
        perPersonTip: perPersonTip,
      ),
    );
  }

  void setBillAmount(double amount) {
    state = state.copyWith(billAmount: amount);
    _recalculate();
  }

  void setTipPercent(double percent) {
    state = state.copyWith(tipPercent: percent);
    _recalculate();
  }

  void setSplitCount(int count) {
    if (count < AppConstants.minSplitCount ||
        count > AppConstants.maxSplitCount) return;
    state = state.copyWith(splitCount: count);
    _recalculate();
  }

  void setRoundingMode(RoundingMode mode) {
    state = state.copyWith(roundingMode: mode);
    _recalculate();
  }

  void setServiceType(ServiceType type) {
    state = state.copyWith(serviceType: type);
  }

  void setCountry(String countryId, String currencySymbol) {
    state = state.copyWith(
      countryId: countryId,
      currencySymbol: currencySymbol,
    );
  }

  void reset() {
    state = TipCalculatorState.initial();
  }
}

final tipCalculatorProvider =
    StateNotifierProvider<TipCalculatorNotifier, TipCalculatorState>(
  (ref) => TipCalculatorNotifier(),
);
