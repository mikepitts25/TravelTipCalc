import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../services/exchange_rate_service.dart';

final exchangeRateServiceProvider = Provider<ExchangeRateService>(
  (ref) => ExchangeRateService(),
);

class ExchangeRateState {
  final double? rate;
  final DateTime? fetchedAt;
  final bool isLoading;
  final bool fromCache;
  final String? error;
  final String fromCurrency;
  final String toCurrency;

  const ExchangeRateState({
    this.rate,
    this.fetchedAt,
    this.isLoading = false,
    this.fromCache = false,
    this.error,
    this.fromCurrency = '',
    this.toCurrency = 'USD',
  });

  bool get hasRate => rate != null;
  bool get isSameCurrency => fromCurrency == toCurrency;

  double convert(double amount) {
    if (rate == null || isSameCurrency) return amount;
    return amount * rate!;
  }

  ExchangeRateState copyWith({
    double? rate,
    DateTime? fetchedAt,
    bool? isLoading,
    bool? fromCache,
    String? error,
    String? fromCurrency,
    String? toCurrency,
  }) {
    return ExchangeRateState(
      rate: rate ?? this.rate,
      fetchedAt: fetchedAt ?? this.fetchedAt,
      isLoading: isLoading ?? this.isLoading,
      fromCache: fromCache ?? this.fromCache,
      error: error,
      fromCurrency: fromCurrency ?? this.fromCurrency,
      toCurrency: toCurrency ?? this.toCurrency,
    );
  }
}

class ExchangeRateNotifier extends StateNotifier<ExchangeRateState> {
  final ExchangeRateService _service;

  ExchangeRateNotifier(this._service) : super(const ExchangeRateState());

  Future<void> fetchRate(String fromCurrency, String toCurrency) async {
    if (fromCurrency.isEmpty || toCurrency.isEmpty) return;
    if (fromCurrency == toCurrency) {
      state = ExchangeRateState(
        rate: 1.0,
        fetchedAt: DateTime.now(),
        fromCurrency: fromCurrency,
        toCurrency: toCurrency,
      );
      return;
    }

    // Don't refetch if we already have this pair and it's recent
    if (state.fromCurrency == fromCurrency &&
        state.toCurrency == toCurrency &&
        state.hasRate &&
        !state.isLoading) {
      return;
    }

    state = state.copyWith(
      isLoading: true,
      fromCurrency: fromCurrency,
      toCurrency: toCurrency,
      error: null,
    );

    final result = await _service.getRate(fromCurrency, toCurrency);
    if (result != null) {
      state = state.copyWith(
        rate: result.rate,
        fetchedAt: result.fetchedAt,
        isLoading: false,
        fromCache: result.fromCache,
      );
    } else {
      state = state.copyWith(
        isLoading: false,
        error: 'Could not fetch exchange rate',
      );
    }
  }

  /// Force refresh the current rate.
  Future<void> refresh() async {
    if (state.fromCurrency.isEmpty || state.toCurrency.isEmpty) return;
    // Clear so fetchRate doesn't skip
    final from = state.fromCurrency;
    final to = state.toCurrency;
    state = const ExchangeRateState();
    await fetchRate(from, to);
  }
}

final exchangeRateProvider =
    StateNotifierProvider<ExchangeRateNotifier, ExchangeRateState>(
  (ref) {
    final service = ref.watch(exchangeRateServiceProvider);
    return ExchangeRateNotifier(service);
  },
);
